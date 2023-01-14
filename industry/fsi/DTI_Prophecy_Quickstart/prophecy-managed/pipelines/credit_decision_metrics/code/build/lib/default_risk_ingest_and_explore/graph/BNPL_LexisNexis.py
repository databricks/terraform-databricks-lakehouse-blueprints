from pyspark.sql import *
from pyspark.sql.functions import *
from pyspark.sql.types import *
from default_risk_ingest_and_explore.config.ConfigStore import *
from default_risk_ingest_and_explore.udfs.UDFs import *

def BNPL_LexisNexis(spark: SparkSession) -> DataFrame:
    return spark.read\
        .format("json")\
        .schema(
          StructType([
            StructField("balance", LongType(), True), StructField("lender_name", StringType(), True), StructField("loan_id", LongType(), True), StructField("monthly_loan_amount", StringType(), True), StructField("name", StringType(), True), StructField("past_due", LongType(), True), StructField("processor", StringType(), True), StructField("term", StringType(), True)
        ])
        )\
        .load("dbfs:/FileStore/shared_uploads/finserv/prophecy/bnpl/")
