# Databricks notebook source
# MAGIC %md
# MAGIC
# MAGIC ## Create Delta Lake Objects Governed by Unity Catalog
# MAGIC
# MAGIC This particular workflow shows parquet file generation directly from a `q` table in KDB. All tables saved in the cap_markets catalog, which can be inspected for all table definitions, lineage, and access controls.

# COMMAND ----------

# MAGIC %sql create catalog if not exists cap_markets; create schema if not exists q_on_dbx

# COMMAND ----------

# MAGIC %sql use catalog cap_markets; use schema q_on_dbx

# COMMAND ----------

# MAGIC %fs mkdirs /rp_ts

# COMMAND ----------

# MAGIC %md
# MAGIC
# MAGIC ### Create KDB Table and Save to Parquet

# COMMAND ----------

import os
os.environ['QLIC'] = '/dbfs/tmp/license/'
os.environ['QARGS'] = '-s 4'
import pandas as pd
import pykx as kx
import os


# COMMAND ----------

# MAGIC %%q
# MAGIC
# MAGIC tbl: ([] sym: `symbol$(); int_f: `int$(); float_f: `float$(); real_f: `real$(); byte_f: `byte$(); char_f: `char$(); timestamp_f: `timestamp$(); month_f: `month$(); date_f: `date$(); time_f: `time$(); minute_f: `minute$(); second_f: `second$(); time_f: `time$())
# MAGIC
# MAGIC tbl

# COMMAND ----------

# MAGIC %%q
# MAGIC
# MAGIC tbl,: enlist[`a; 1; 1.1; 1e; 0x01; "a"; .z.p; 2023.01m; 2023.01.01;  12:00:00.000; 12:00; 12:00:00; 12:00:00.000]
# MAGIC tbl,: enlist[`b; 2; 2.2; 2e; 0x02; "b"; .z.p; 2023.02m; 2023.02.02;  13:00:00.000; 13:00; 13:00:00; 13:00:00.000]
# MAGIC tbl,: enlist[`c; 3; 3.3; 3e; 0x03; "c"; .z.p; 2023.03m; 2023.03.03;  14:00:00.000; 14:00; 14:00:00; 14:00:00.000]
# MAGIC tbl,: enlist[`d; 4; 4.4; 4e; 0x04; "d"; .z.p; 2023.04m; 2023.04.04;  15:00:00.000; 15:00; 15:00:00; 15:00:00.000]
# MAGIC tbl,: enlist[`e; 5; 5.5; 5e; 0x05; "e"; .z.p; 2023.05m; 2023.05.05;  16:00:00.000; 16:00; 16:00:00; 16:00:00.000]
# MAGIC

# COMMAND ----------

# MAGIC %%q
# MAGIC
# MAGIC tbl

# COMMAND ----------

import pyarrow as pa
import pyarrow.parquet as pq
import pykx as kx

# Fetch data from Kdb+
kdb_table = kx.q('tbl')  # Replace 'tbl' with your Kdb+ table name


arrow_table = kdb_table.pa()

# Step 4: Write the modified table to the final Parquet file
# In order to avoid downcasting errors, we need to use the int96_timestamp configuration as shown below
pq.write_table(arrow_table, '/dbfs/rp_ts/output.parquet', use_deprecated_int96_timestamps=True)

# COMMAND ----------

display(spark.read.format("parquet").load("dbfs:/rp_ts/output.parquet"))

# COMMAND ----------

spark.read.format("parquet").load("dbfs:/rp_ts/output.parquet").write.saveAsTable("cap_markets.q_on_dbx.sample_dbx_table")
