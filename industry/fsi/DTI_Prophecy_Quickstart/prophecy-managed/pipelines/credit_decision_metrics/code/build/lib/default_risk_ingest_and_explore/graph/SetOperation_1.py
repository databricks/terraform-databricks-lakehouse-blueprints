from pyspark.sql import *
from pyspark.sql.functions import *
from pyspark.sql.types import *
from default_risk_ingest_and_explore.config.ConfigStore import *
from default_risk_ingest_and_explore.udfs.UDFs import *

def SetOperation_1(spark: SparkSession, in0: DataFrame, in1: DataFrame, ) -> DataFrame:
    return in0.unionAll(in1)
