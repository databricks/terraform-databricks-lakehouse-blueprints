from pyspark.sql import *
from pyspark.sql.functions import *
from pyspark.sql.types import *
from default_risk_ingest_and_explore.config.ConfigStore import *
from default_risk_ingest_and_explore.udfs.UDFs import *

def Reported_Income(spark: SparkSession) -> DataFrame:
    return spark.read\
        .schema(
          StructType([
            StructField("CUSTOMER_ID", StringType(), True), StructField("CUSTOMER_NAME", StringType(), True), StructField("REPORTED_INCOME", StringType(), True), StructField("DOB", StringType(), True)
        ])
        )\
        .option("header", True)\
        .option("sep", "|")\
        .csv("dbfs:/FileStore/shared_uploads/finserv/prophecy/income/customer.csv")
