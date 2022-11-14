-- Databricks notebook source
-- MAGIC %md 
-- MAGIC 
-- MAGIC # Create Transaction Summaries and Alert Based on Failure Rates 
-- MAGIC 
-- MAGIC We know have full lineage of our workflow in Unity Catalog. Now that we have the foundation for governance, we will highlight the data warehousing capabilities of Databricks SQL for visualization, alerting, and Serverless capabilities.
-- MAGIC 
-- MAGIC <p></p>
-- MAGIC <p></p>
-- MAGIC 
-- MAGIC <img src='https://raw.githubusercontent.com/rportilla-databricks/dbt-asset-mgmt/main/images/payments_step_3_data_warehouse.jpg'>

-- COMMAND ----------

create catalog if not exists payments ; 
use catalog payments

-- COMMAND ----------

-- MAGIC %sql 
-- MAGIC 
-- MAGIC drop table if exists gold_pain_txn_loc_summary
-- MAGIC ;
-- MAGIC  
-- MAGIC create table gold_pain_txn_loc_summary
-- MAGIC as
-- MAGIC select state, count(1) ct
-- MAGIC from silver_payments_initiation
-- MAGIC group by state

-- COMMAND ----------

-- DBTITLE 1,Create Geographic Summary using the Same Visualization as Databricks SQL
-- MAGIC %sql select * from gold_pain_txn_loc_summary

-- COMMAND ----------

-- MAGIC %sql 
-- MAGIC 
-- MAGIC drop table if exists gold_pain_txn_freq_summary
-- MAGIC ;
-- MAGIC  
-- MAGIC create table gold_pain_txn_freq_summary
-- MAGIC as
-- MAGIC select Created_ts, count(1) ct
-- MAGIC from silver_payments_initiation
-- MAGIC group by created_ts

-- COMMAND ----------

drop table if exists gold_payment_failure_summary 
; 

create table gold_payment_failure_summary
as 
select 100*(select count(1) from silver_payments_initiation l left join silver_payment_cleared c 
on l.id = c.orgnlmsgid 
where c.orgnlmsgid is null) / (select count(1) from silver_payments_initiation) failure_pct

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 
-- MAGIC ## ===> [DBSQL Dashboard on Transaction Monitoring](https://e2-demo-field-eng.cloud.databricks.com/sql/dashboards/8b8a363d-11ca-4ab1-89c1-e903fbf600f2-payments-lakehouse---transaction-monitoring?o=1444828305810485)

-- COMMAND ----------

