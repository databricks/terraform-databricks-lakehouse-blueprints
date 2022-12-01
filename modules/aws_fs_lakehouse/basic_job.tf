data "databricks_current_user" "me" {
}

data "databricks_spark_version" "latest" {}
data "databricks_node_type" "smallest" {
  local_disk = true
}

resource "databricks_notebook" "this" {
  path     = "${data.databricks_current_user.me.home}/Terraform"
  language = "PYTHON"
  content_base64 = base64encode(<<-EOT
# Databricks notebook source
# MAGIC %md
# MAGIC # Metadata driven provisioning
# MAGIC *Given an enterprise data model, [waterbear](https://github.com/databrickslabs/waterbear) automatically converts an entity into its delta schema equivalent, extract metadata, derive tables expectations as SQL expressions and provision data pipelines that accelerate development of production workflows. Such a foundation allows financial services institutions to bootstrap their Lakehouse for Financial Services with resilient data pipelines and minimum development overhead. Adhering to strict industry data standards, waterbear supports enrterprise data models expressed as [JSON Schema](https://json-schema.org/) and was built to ensure full compatibility with recent open source initiatives like the FIRE data model for regulatory reporting*
# MAGIC
# MAGIC ___
# COMMAND ----------

config = {
  'model': {
    # where our data model is stored
    'path': '/tmp/fire/model',
  },
  'database': {
    # tables are stored on a specific mount point
    'path': '/FileStore/antoine.amend@databricks.com/waterbear/db',
    # name of the database
    'name': 'waterbear',
    # data quality column appended to each table
    'dqmc': 'waterbear'
  },
  'data': {
    # landing zone where cloud files may be received
    'path': '/FileStore/antoine.amend@databricks.com/waterbear/data',
    # checkpoint location for auto loader
    'chkp': '/FileStore/antoine.amend@databricks.com/waterbear/chkp'
  },
  # entities we want to provision from our data model
  'entities': [
    'agreement',
    'collateral',
    'derivative',
    'loan',
    'security'
  ]
}

# COMMAND ----------

def tear_down():
  import shutil
  _ = dbutils.fs.rm(config['database']['path'], True)
  _ = dbutils.fs.rm(config['data']['chkp'], True)
  _ = dbutils.fs.rm(config['data']['path'], True)
  _ = sql("DROP DATABASE IF EXISTS {} CASCADE".format(config['database']['name']))
  _ = shutil.rmtree(config['model']['path'])

def truncate():
  for entity in config['entities']:
    _ = sql("TRUNCATE TABLE {}.{}".format(config['database']['name'], entity))

# COMMAND ----------

# MAGIC %md
# MAGIC ## Access data model
# MAGIC The Financial Regulatory data standard defines a common specification for the transmission of granular data between regulatory systems in finance. The [FIRE](https://github.com/SuadeLabs/fire) data standard is supported by the European Commission, the Open Data Institute and the Open Data Incubator for Europe via the Horizon 2020 funding programme. Working with any schema expressed as JSON Schema, we use the FIRE data model for that specific example.

# COMMAND ----------

import requests, zipfile, io
import os
import shutil
import tempfile

# create directory if not exists
model_path = config['model']['path']
if not os.path.exists(model_path):

  # download latest data model to temp directory
  temp_dir = tempfile.TemporaryDirectory()
  r = requests.get('https://github.com/SuadeLabs/fire/archive/refs/heads/master.zip')
  z = zipfile.ZipFile(io.BytesIO(r.content))
  z.extractall(temp_dir.name)

  # move model to expected path
  model_tmp_dir = '{}/fire-master/v1-dev'.format(temp_dir.name)
  os.makedirs(model_path)
  for model_file in os.listdir(model_tmp_dir):
    shutil.move('{}/{}'.format(model_tmp_dir, model_file), model_path)
  temp_dir.cleanup()

# COMMAND ----------

# MAGIC %md
# MAGIC Our data model contains the following entities

# COMMAND ----------

import os
import pandas as pd

model_files = os.listdir(config['model']['path'])
entities = config['entities']
for entity in entities:
  assert '{}.json'.format(entity) in model_files, 'Defined entity must be in provided data model'

display(pd.DataFrame(['{}/{}'.format(model_path, f) for f in model_files], columns=['entity']))

# COMMAND ----------

# MAGIC %md
# MAGIC ## Provision Lakehouse

# COMMAND ----------

# MAGIC %md
# MAGIC Lets create all the relevant paths required to process files and store validated records

# COMMAND ----------

dbutils.fs.mkdirs(config['database']['path'])

# COMMAND ----------

for entity in entities:
  dbutils.fs.mkdirs('{}/{}'.format(config['data']['path'], entity))
  dbutils.fs.mkdirs('{}/{}'.format(config['data']['chkp'], entity))

# COMMAND ----------

# MAGIC %md
# MAGIC Let's register the relevant database required to store validated entities

# COMMAND ----------

_ = sql("CREATE DATABASE IF NOT EXISTS {} LOCATION '{}'".format(config['database']['name'], config['database']['path']))

# COMMAND ----------

# MAGIC %md
# MAGIC In addition to our generated schema, we will add a new column to capture violated constraints

# COMMAND ----------

def append_dq_column(schema):
  from pyspark.sql import types as T
  schema.fields.append(T.StructField(
    config['database']['dqmc'],
    T.ArrayType(T.StringType()),
    True,
    metadata={"comment": "<WATERBEAR> Automated data quality"}))

# COMMAND ----------

# MAGIC %md
# MAGIC Let's provision all the relevant tables given an entity schema and metadata defined from our data model

# COMMAND ----------

from waterbear.convertor import JsonSchemaConvertor

for entity in entities:

  # Accessing spark schema for a given model entity
  schema, _ = JsonSchemaConvertor(model_path).convert(entity)

  # Adding an extra column for data quality control
  append_dq_column(schema)

  # Creating an empty dataframe with expected schema
  empty_rdd = spark.sparkContext.emptyRDD()
  empty_frm = spark.createDataFrame(empty_rdd, schema)

  # Create a table given a structured dataframe
  _ = (
    empty_frm
      .write
      .mode('append')
      .format('delta')
      .saveAsTable('{}.{}'.format(config['database']['name'], entity))
  )

# COMMAND ----------

# MAGIC %md
# MAGIC Ensure all our tables are physically created

# COMMAND ----------

tables = [d.name.replace('/', '') for d in dbutils.fs.ls(config['database']['path'])]
assert set(tables) == set(entities), 'External tables should have been created'
display(dbutils.fs.ls(config['database']['path']))

# COMMAND ----------

# MAGIC %md
# MAGIC Ensure all our tables are successfully registered

# COMMAND ----------

def validate_table(entity):
  entity_path = 'dbfs:{}/{}'.format(config['database']['path'], entity)
  df = sql('DESCRIBE TABLE EXTENDED {}.{}'.format(config['database']['name'], entity))
  pdf = df.toPandas().set_index('col_name')
  assert config['database']['dqmc'] in pdf.index, 'Data quality column should be added'
  assert pdf.loc['Type'].data_type == 'MANAGED', 'Table should be defined as managed'
  assert pdf.loc['Provider'].data_type == 'delta', 'Table should be of type delta'
  return df

validated = [validate_table(entity) for entity in entities]
display(validated[0])

# COMMAND ----------

# MAGIC %md
# MAGIC ## Data ingest
# MAGIC In the example below, we will be generating sample data files matching our relevant schema and ingest those records to a delta table through autoloader capability.

# COMMAND ----------

from waterbear.generator import JsonRecordGenerator
import uuid

num_records = 100
num_files = 5

def generate_records(entity):
  for i in range(num_files):
    records = JsonRecordGenerator(config['model']['path'], nullable_rate=0.1).generate(entity, 100)
    file_name = str(uuid.uuid4())
    file_path = '/dbfs{path}/{entity}/{file_name}.json'.format(path=config['data']['path'], entity=entity, file_name=file_name)
    with open(file_path, 'w') as f:
      f.write('\n'.join(records))
      print('Created file [{}]'.format(file_path.replace('/dbfs', 'dbfs:')))

# COMMAND ----------

from waterbear.convertor import JsonSchemaConvertor
from pyspark.sql import functions as F

@F.udf('array<string>')
def get_violated(xs, ys):
    return [xs[i] for i, y in enumerate(ys) if not y]

def ingest(entity):

  # input parameters for our autoloader job
  model_dir = config['model']['path']
  path = '{}/{}'.format(config['data']['path'], entity)
  checkpoint = '{}/{}'.format(config['data']['chkp'], entity)
  table = '{}.{}'.format(config['database']['name'], entity)
  quality_column = config['database']['dqmc']

  # extract schema and constraints
  schema, constraints = JsonSchemaConvertor(model_dir).convert(entity)

  # schematize incoming data files
  input_df = spark \
    .readStream \
    .format('cloudFiles') \
    .option('cloudFiles.format', 'json') \
    .schema(schema) \
    .load(path)

  # validate files
  constraint_exprs = F.array([F.expr(c) for c in constraints.values()])
  constraint_names = F.array([F.lit(c) for c in constraints.keys()])
  validated_df = input_df.withColumn(
    quality_column,
    get_violated(constraint_names, constraint_exprs)
  )

  # persist validated and schematize files to delta
  validated_df \
    .writeStream \
    .format('delta') \
    .option("checkpointLocation", checkpoint) \
    .trigger(once=True) \
    .table(table)

# COMMAND ----------

for entity in entities:
  generate_records(entity)
  ingest(entity)
  df = spark.read.table('{}.{}'.format(config['database']['name'], entity))
  display(df)

# COMMAND ----------

# MAGIC %md
# MAGIC With all foundations in place, we can safely either `tear_down()` or `truncate()` or lakehouse tables.

# COMMAND ----------

truncate()

# COMMAND ----------

# MAGIC %md
# MAGIC &copy; 2022 Databricks, Inc. All rights reserved. The source in this notebook is provided subject to the Databricks License [https://databricks.com/db-license-source].  All included or referenced third party libraries are subject to the licenses set forth below.
# MAGIC
# MAGIC | library                                | description             | license    | source                                              |
# MAGIC |----------------------------------------|-------------------------|------------|-----------------------------------------------------|
# MAGIC | dbl-waterbear                              | data model lib         | Databricks | https://github.com/databrickslabs/waterbear             |

    EOT
  )
}



resource "databricks_job" "this" {
  name = "FS Blueprints Quickstart Job (${data.databricks_current_user.me.alphanumeric})"

  new_cluster {
    spark_version       = data.databricks_spark_version.latest.id
    node_type_id        = data.databricks_node_type.smallest.id
    enable_elastic_disk = false
    num_workers         = 1
    aws_attributes {
      availability = "SPOT"
    }
    data_security_mode = "SINGLE_USER"
    custom_tags        = { "clusterSource" = "lakehouse-blueprints" }
  }

  library {
    pypi {
      package = "dbl-waterbear"
    }
  }

  library {
    pypi {
      package = "dbl-tempo"
    }
  }

  notebook_task {
    notebook_path = databricks_notebook.this.path
  }
}

output "notebook_url" {
  value = databricks_notebook.this.url
}

output "job_url" {
  value = databricks_job.this.url
}