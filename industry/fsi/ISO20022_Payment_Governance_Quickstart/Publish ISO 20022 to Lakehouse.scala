// Databricks notebook source
// MAGIC %md
// MAGIC 
// MAGIC # Structured Streaming into ISO 20022 Data Lake
// MAGIC 
// MAGIC Using Delta Lake and Structured Streaming, we can ensure reliability while also ensuring exactly once processing of the data as it is reported to a central authority. The ingestion phase allows for fault tolerance and can be used for any XML format (here `binaryFile` is the format type in Autoloader). 
// MAGIC 
// MAGIC The following flow shows that we start with streaming ingestion: 
// MAGIC 
// MAGIC <img src='https://raw.githubusercontent.com/rportilla-databricks/dbt-asset-mgmt/main/images/payments_step_1_streaming.jpg' width=900>

// COMMAND ----------

// DBTITLE 1,Use Unity Catalog to Save Tables for Lineage and Governance Purposes
// MAGIC %sql 
// MAGIC 
// MAGIC create catalog if not exists payments ; 
// MAGIC use catalog payments

// COMMAND ----------

// MAGIC %md
// MAGIC 
// MAGIC ## Ingestion of Raw Data and Format into ISO 20022 Format Uses Autoloader for Simple APIs and Incremental Processing. 
// MAGIC 
// MAGIC 
// MAGIC <img src='https://raw.githubusercontent.com/rportilla-databricks/dbt-asset-mgmt/main/images/iso_ingestion.png'>

// COMMAND ----------

// MAGIC %fs rm -r /home/ricardo/checkpoints/pacs/iso_20022/path222/

// COMMAND ----------

// MAGIC %fs rm -r /home/ricardo/checkpoints/pain/iso_20022/path30/

// COMMAND ----------

import com.databricks.spark.xml.functions.from_xml
import com.databricks.spark.xml.schema_of_xml
import spark.implicits._
import com.databricks.spark.xml._
import org.apache.spark.sql.functions.{input_file_name}
 
 
val toStrUDF = udf((bytes: Array[Byte]) => new String(bytes, "UTF-8")) // UDF to convert the binary to String
 
val df_schema = spark.read.format("binaryFile").load("/FileStore/shared_uploads/ricardo.portilla@databricks.com/finserv/iso20022/pain/src_files/").select(toStrUDF($"content").alias("text"))

val pain_payload_schema = schema_of_xml(df_schema.select("text").as[String])
 

// COMMAND ----------

// MAGIC %sql drop table if exists payments.default.payment_initiation; drop table if exists payments.default.payment_cleared

// COMMAND ----------

// DBTITLE 1,Autoloader Saves ISO 20022 Formats and Allows us to Save to a Transactional Format
import org.apache.spark.sql.streaming.Trigger

val pain_df = spark.readStream.format("cloudFiles")
  .option("cloudFiles.useNotifications", "false")
  .option("cloudFiles.format", "binaryFile")
  .option("cloudFiles.includeExistingFiles", "true")
  .load("/FileStore/shared_uploads/ricardo.portilla@databricks.com/finserv/iso20022/pain/src_files/")
  .select(toStrUDF($"content").alias("text")).select(from_xml($"text", pain_payload_schema).alias("parsed"))

pain_df.writeStream.format("delta").trigger(Trigger.AvailableNow()).option("checkpointLocation", "/home/ricardo/checkpoints/pain/iso_20022/path30/")
  .toTable("payments.default.payment_initiation")

// COMMAND ----------

// MAGIC %fs ls /FileStore/shared_uploads/ricardo.portilla@databricks.com/finserv/iso20022/pain/src_files/

// COMMAND ----------

// DBTITLE 1,Our Records Now Reside in Delta Format for Open Retrieval from Any Regulator, Clearing House or Partner
// MAGIC %sql select * from payments.default.payment_initiation

// COMMAND ----------

// MAGIC %md 
// MAGIC 
// MAGIC #Repeat for Payments and Clearing Data

// COMMAND ----------

import com.databricks.spark.xml.functions.from_xml
import com.databricks.spark.xml.schema_of_xml
import spark.implicits._
import com.databricks.spark.xml._
import org.apache.spark.sql.functions.{input_file_name}
 
 
val pacsUDF = udf((bytes: Array[Byte]) => new String(bytes, "UTF-8")) // UDF to convert the binary to String
 
val pacs_schema = spark.read.format("binaryFile").load("/FileStore/shared_uploads/ricardo.portilla@databricks.com/finserv/iso20022/pacs/src_files/").select(pacsUDF($"content").alias("text"))

val payloadSchema = schema_of_xml(pacs_schema.select("text").as[String])
 

// COMMAND ----------

import org.apache.spark.sql.streaming.Trigger._

val df = spark.readStream.format("cloudFiles")
  .option("cloudFiles.useNotifications", "false")
  .option("cloudFiles.format", "binaryFile")
  .option("cloudFiles.includeExistingFiles", "true")
  .load("/FileStore/shared_uploads/ricardo.portilla@databricks.com/finserv/iso20022/pacs/src_files/")
  .select(toStrUDF($"content").alias("text")).select(from_xml($"text", payloadSchema).alias("parsed"))

df.writeStream.format("delta").trigger(Trigger.AvailableNow()).option("checkpointLocation", "/home/ricardo/checkpoints/pacs/iso_20022/path222/")
  .toTable("payments.default.payment_cleared")

// COMMAND ----------

// MAGIC %sql select * from payments.default.payment_cleared

// COMMAND ----------

