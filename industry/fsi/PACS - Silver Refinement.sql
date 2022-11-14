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

use database default

-- COMMAND ----------

drop table if exists silver_payment_cleared
; 

create table silver_payment_cleared as select
parsed.FIToFIPmtStsRpt.OrgnlGrpInfAndSts.orgnlmsgid, parsed.FIToFIPmtStsRpt.grphdr.InstgAgt.FinInstnId.pstladr.adrline, cast(parsed.FIToFIPmtStsRpt.TxInfAndSts.AccptncDtTm as timestamp) acceptance_ts, parsed.FIToFIPmtStsRpt.txinfandsts.orgnltxref.sttlminf.sttlmmtd settlement_frequency,
parsed.FIToFIPmtStsRpt.txinfandsts['ChrgsInf']['Amt']['_VALUE'] txn_amount
from payments.default.payment_cleared x

-- COMMAND ----------

select *
from payments.default.silver_payment_cleared

-- COMMAND ----------

drop table if exists silver_lifecycle_payment;
create table silver_lifecycle_payment as
select
  a.*,
  acceptance_ts,
  settlement_frequency,
  txn_amount,
  datediff(created_ts, acceptance_ts) time_to_clear_duration
from
  silver_payments_initiation a
   join silver_payment_cleared b on a.id = b.orgnlmsgid

-- COMMAND ----------

select * from silver_lifecycle_payment

-- COMMAND ----------

select * from silver_payment_cleared

-- COMMAND ----------

