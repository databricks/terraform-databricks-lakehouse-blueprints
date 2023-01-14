from pyspark.sql import *
from pyspark.sql.functions import *
from pyspark.sql.types import *
from default_risk_ingest_and_explore.config.ConfigStore import *
from default_risk_ingest_and_explore.udfs.UDFs import *
from prophecy.utils import *
from default_risk_ingest_and_explore.graph import *

def pipeline(spark: SparkSession) -> None:
    df_Reported_Income = Reported_Income(spark)
    df_Bureau_Source = Bureau_Source(spark)
    df_Join_Income_to_Tradelines = Join_Income_to_Tradelines(spark, df_Reported_Income, df_Bureau_Source)
    df_Flatten = Flatten(spark, df_Join_Income_to_Tradelines)
    df_BNPL_LexisNexis = BNPL_LexisNexis(spark)
    df_SchemaTransform_1 = SchemaTransform_1(spark, df_BNPL_LexisNexis)
    df_SetOperation_1 = SetOperation_1(spark, df_Flatten, df_SchemaTransform_1)
    df_Aggregate_1 = Aggregate_1(spark, df_SetOperation_1)
    credit_metrics(spark, df_Aggregate_1)

def main():
    spark = SparkSession.builder\
                .config("spark.default.parallelism", "4")\
                .config("spark.sql.legacy.allowUntypedScalaUDF", "true")\
                .enableHiveSupport()\
                .appName("Prophecy Pipeline")\
                .getOrCreate()\
                .newSession()
    Utils.initializeFromArgs(spark, parse_args())
    spark.conf.set("prophecy.metadata.pipeline.uri", "pipelines/credit_decision_metrics")
    
    MetricsCollector.start(spark = spark, pipelineId = spark.conf.get("prophecy.project.id") + "/" + "pipelines/credit_decision_metrics")
    pipeline(spark)
    MetricsCollector.end(spark)

if __name__ == "__main__":
    main()
