-- Databricks notebook source
-- MAGIC %md 
-- MAGIC 
-- MAGIC ### Create a View On Top of the Final DTI Metrics and Reported Income from the Prophecy Pipeline

-- COMMAND ----------

create table hive_metastore.default.gold_credit_dti 
location 'dbfs:/home/finserv/designpatterns/gold_credit_dti/'
