-- Databricks notebook source
-- MAGIC %md 
-- MAGIC 
-- MAGIC # Curating an ISO20022 Payments Data Lakehouse
-- MAGIC 
-- MAGIC ISO 20022 will be our standard payments format in the bronze layer (created from a streaming job). Databricks robust ETL features allow us to create dependencies between silver and gold layers as well as enforce governance on highly sensitive data within the bronze layer. In this pipeline, we apply transformation, masking, and aggregation, which all retain lineage in Unity Catalog: 
-- MAGIC 
-- MAGIC <p></p>
-- MAGIC <p></p>
-- MAGIC <p></p>
-- MAGIC 
-- MAGIC * Step 1 - Use [Workflows](https://docs.databricks.com/workflows/index.html) to set dependencies between silver and gold layers
-- MAGIC * Step 2 - Extract location, Payment and Clearing Settlement acceptance time, and transaction details. Mask data using access controls from [Unity Catalog](https://docs.databricks.com/data-governance/unity-catalog/get-started.html)
-- MAGIC * Step 3 - Join Clearing and Settlement information to payment initiation information and summarize using Databricks [notebook visualizations](https://docs.databricks.com/notebooks/visualizations/index.html)
-- MAGIC 
-- MAGIC <p></p>
-- MAGIC <p></p>
-- MAGIC <p></p>
-- MAGIC 
-- MAGIC <img src='https://raw.githubusercontent.com/rportilla-databricks/dbt-asset-mgmt/main/images/payments_step_2_transform.jpg' width=1000>
-- MAGIC 
-- MAGIC <img src='https://www.databricks.com/wp-content/uploads/2021/09/DLT_graphic_tiers.jpg' width=1000>

-- COMMAND ----------

create catalog if not exists payments ; 
use catalog payments

-- COMMAND ----------

select * From payments.default.payment_initiation

-- COMMAND ----------

drop table if exists silver_payments_initiation_base
; 

create table silver_payments_initiation_base
as 
select cast(parsed.mndtInitnreq.grphdr.credttm as timestamp) created_ts, parsed.MndtInitnReq.grphdr.initgpty.CtctDtls.emailadr, parsed.MndtInitnReq.grphdr.initgpty.pstladr.adrline, parsed.mndtInitnreq.mndt.mndtid, parsed.MndtInitnReq.grphdr.msgid,  split(trim(split(parsed.MndtInitnReq.grphdr.initgpty.pstladr.adrline, ',')[2]), ' ')[0] state
from payments.default.payment_initiation x

-- COMMAND ----------


create or replace view silver_payments_initiation
as 
select msgid `id`, created_ts, adrline, state, case when is_member("data-science") then base64(aes_encrypt(emailadr, 'key')) else emailadr end emailadr
from silver_payments_initiation_base

-- COMMAND ----------

select * from silver_payments_initiation

-- COMMAND ----------

