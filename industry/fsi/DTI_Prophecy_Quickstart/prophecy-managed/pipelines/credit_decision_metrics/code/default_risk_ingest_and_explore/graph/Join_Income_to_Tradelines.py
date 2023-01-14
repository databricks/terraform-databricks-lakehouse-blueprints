from pyspark.sql import *
from pyspark.sql.functions import *
from pyspark.sql.types import *
from default_risk_ingest_and_explore.config.ConfigStore import *
from default_risk_ingest_and_explore.udfs.UDFs import *

def Join_Income_to_Tradelines(spark: SparkSession, in0: DataFrame, in1: DataFrame, ) -> DataFrame:
    return in0.alias("in0").join(in1.alias("in1"), (col("in0.CUSTOMER_NAME") == col("in1.Name")), "inner")
