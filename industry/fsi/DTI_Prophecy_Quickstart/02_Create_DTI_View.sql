-- Databricks notebook source
-- MAGIC %md 
-- MAGIC 
-- MAGIC ## Create a View On Top of the Final DTI Metrics and Reported Income from the Prophecy Pipeline
-- MAGIC 
-- MAGIC Once the following view is created, you can load the basic DBSQL Dashboard showing some visualizations of the metrics: 
-- MAGIC 
-- MAGIC <p></p>
-- MAGIC 
-- MAGIC <img src = 'https://raw.githubusercontent.com/databricks/terraform-databricks-lakehouse-blueprints/main/industry/fsi/images/dbsql_dash.png'>

-- COMMAND ----------

create table hive_metastore.default.gold_credit_dti 
location 'dbfs:/home/finserv/designpatterns/gold_credit_dti/'
