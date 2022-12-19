# Databricks notebook source
# MAGIC %md 
# MAGIC # Databricks & Prophecy together can be used to develop low-code data engineering pipelines at scale. 
# MAGIC 
# MAGIC Use the current notebook to load simple datasets into Databricks to get started with the Prophecy pipeline in the Industry Quickstarts in the blueprints [repository](https://github.com/databricks/terraform-databricks-lakehouse-blueprints/tree/main/industry/fsi/prophecy/prophecy-managed)
# MAGIC 
# MAGIC <img src = 'https://assets.website-files.com/5ec3ebc95538f8302b8dcdf3/62b4070ae27005797572e0e0_Prophecy%20for%20Databricks%20Features-p-3200.png'>

# COMMAND ----------

# MAGIC %sh 
# MAGIC 
# MAGIC wget https://raw.githubusercontent.com/databricks/terraform-databricks-lakehouse-blueprints/prophecy_quickstart/industry/fsi/data/bnpl.json

# COMMAND ----------

# MAGIC %fs cp file:/databricks/driver/bnpl.json dbfs:/FileStore/shared_uploads/finserv/prophecy/bnpl/bnpl.json

# COMMAND ----------

# MAGIC %sh 
# MAGIC 
# MAGIC wget https://raw.githubusercontent.com/databricks/terraform-databricks-lakehouse-blueprints/prophecy_quickstart/industry/fsi/data/customer.csv

# COMMAND ----------

# MAGIC %fs cp file:/databricks/driver/bnpl.json dbfs:/FileStore/shared_uploads/finserv/prophecy/customer/customer.csv

# COMMAND ----------

# MAGIC %sh 
# MAGIC 
# MAGIC wget https://raw.githubusercontent.com/databricks/terraform-databricks-lakehouse-blueprints/prophecy_quickstart/industry/fsi/data/credit_report.xml

# COMMAND ----------

# MAGIC %fs cp file:/databricks/driver/bnpl.json dbfs:/FileStore/shared_uploads/finserv/prophecy/credit/credit_report.xml

# COMMAND ----------

# MAGIC %sql 
# MAGIC 
# MAGIC create table hive_metastore.default.gold_credit_dti 
# MAGIC location 'dbfs:/home/finserv/designpatterns/gold_credit_dti/'

# COMMAND ----------

# MAGIC %sql 
# MAGIC 
# MAGIC create table bronze_credit_income_csv
# MAGIC using csv 
# MAGIC options (sep = '|', header = 'true')
# MAGIC location 'dbfs:/FileStore/shared_uploads/finserv/prophecy/credit/'

# COMMAND ----------


