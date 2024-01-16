# Databricks notebook source
# MAGIC %md
# MAGIC
# MAGIC ## Merge Trade and Quote Time Series using Delta Lake, Liquid Clustering, and Pandas UDFs.
# MAGIC
# MAGIC All tables are governed in Unity Catalog with auto-generated descriptions and tags for columns

# COMMAND ----------

# MAGIC %sql use catalog cap_markets; use schema q_on_dbx

# COMMAND ----------

import os

os.environ['QLIC'] = '/dbfs/tmp/license/'
import pandas as pd
import pykx as kx

# COMMAND ----------

# MAGIC %md
# MAGIC #Read the source tables

# COMMAND ----------

# MAGIC %sh
# MAGIC
# MAGIC wget https://pages.databricks.com/rs/094-YMS-629/images/ASOF_Quotes.csv ; wget https://pages.databricks.com/rs/094-YMS-629/images/ASOF_Trades.csv ;

# COMMAND ----------

# MAGIC %sh mkdir -p /dbfs/tmp/finserv/

# COMMAND ----------

# MAGIC %sh cp ASOF_Quotes.csv /dbfs/tmp/finserv/ASOF_Quotes.csv

# COMMAND ----------

# MAGIC %sh cp ASOF_Trades.csv /dbfs/tmp/finserv/ASOF_Trades.csv

# COMMAND ----------

# MAGIC %sql drop table if exists pykx_db_trades; drop table if exists pykx_db_quotes;

# COMMAND ----------

# DBTITLE 1,Convert Existing CSV Tick Data Sources to Delta Lake for Backtesting and TCA Use Cases
from pyspark.sql.types import *
from pyspark.sql.functions import *

trade_schema = StructType([
    StructField("sym", StringType()),
    StructField("time", TimestampType()),
    StructField("trade_dt", StringType()),
    StructField("price", DoubleType()),
    StructField("size", IntegerType()),
    StructField("date", TimestampType())
])

quote_schema = StructType([
    StructField("sym", StringType()),
    StructField("time", TimestampType()),
    StructField("trade_dt", StringType()),
    StructField("bid", DoubleType()),
    StructField("ask", DoubleType()),
    StructField("date", TimestampType())
])

spark.read.format("csv").schema(trade_schema).option("header", "true").option("delimiter", ",").load("/tmp/finserv/ASOF_Trades.csv").withColumn("size", lit(100)).withColumn("date", col("time").cast("date")).write.mode('overwrite').option("overwriteSchema", "true").saveAsTable('pykx_db_trades')

spark.read.format("csv").schema(quote_schema).option("header", "true").option("delimiter", ",").load("/tmp/finserv/ASOF_Quotes.csv").withColumn("date", col("time").cast("date")).write.mode('overwrite').option("overwriteSchema", "true").saveAsTable('pykx_db_quotes')



# COMMAND ----------

# MAGIC %md
# MAGIC #Define Pandas UDF function used as part of ASOF join Spark's cogrouped map

# COMMAND ----------

# Define pandas asof join UDF function
def asof_join_udf_pandas(t, q):
    from datetime import timedelta
    t = t.sort_values(by=['time', 'sym'], ignore_index=True)
    q = q.sort_values(by=['time', 'sym'], ignore_index=True)
    q['mid'] = (q['ask'] + q['bid']) / 2
    qq = q[['sym', 'time', 'mid']]
    tt = t[['sym', 'time', 'price', 'size']].copy()
    tt['mid'] = pd.merge_asof(tt, qq, on='time', by='sym')['mid']
    return tt


# COMMAND ----------

# MAGIC %md
# MAGIC #Define PyKX UDF function used as part of ASOF join Spark's cogrouped map

# COMMAND ----------

# Define pykx asof join UDF function
def asof_join_udf_pykx(trade_pdf, quote_pdf):
    q_function_definition = """
      ajWrapper:{[tt;qq]
        tt:update `g#sym, `s#time from `time`sym xasc tt;
        qq:update `g#sym, `s#time from `time`sym xasc qq;
        qq:update mid:(ask+bid)%2 from qq;
        data:aj[`sym`time;select sym, time, price, size from tt;select sym, time, mid from qq];
        :data
        }
    """

    import os
    os.environ['QLIC'] = '/dbfs/tmp/license/'
    # os.environ['QARGS'] = '-s 2'
    import pandas as pd
    import pykx as kx
    kx.q(q_function_definition)

    # get q function definition and wrap as python function
    business_logic = kx.q['ajWrapper']
    # call python function that executes the underlying q function
    merged_pdf = business_logic(trade_pdf, quote_pdf).pd()

    return merged_pdf


# COMMAND ----------

# MAGIC %sql -- Create an empty table
# MAGIC CREATE TABLE IF NOT EXISTS rp_asof_result
# MAGIC (sym string, time timestamp, price float, size int, mid float)
# MAGIC USING DELTA
# MAGIC CLUSTER BY (sym);

# COMMAND ----------

# MAGIC %sql truncate table rp_asof_result

# COMMAND ----------

def aqe_ts_join(small_df, big_df, key, pandas_func, tgt_table):
    from pyspark.sql.functions import count, sum, row_number, col
    from pyspark.sql.window import Window

    df_allkeys = big_df
    df_sym_count = df_allkeys.groupBy(key).agg(count("*").alias("key_count"))
    sym_window = Window.orderBy(lit("")).rowsBetween(Window.unboundedPreceding, Window.unboundedFollowing)
    df_sym_agg = df_sym_count.withColumn("tot_ct", sum("key_count").over(sym_window))
    df_pct_skew = df_sym_agg.withColumn("total_pct_skew", 100 * df_sym_agg["key_count"] / df_sym_agg["tot_ct"]).select(
        key, "total_pct_skew")
    df_final = df_pct_skew.filter(df_pct_skew["total_pct_skew"] >= 1.5)

    # collect all the skewed key
    skewed_keys = [x[0] for x in df_final.select(key).distinct().collect()]
    [print(k) for k in skewed_keys]
    for sk in skewed_keys:
        small_data_result = asof_join_udf_pykx(small_df.filter(col(key) == sk).toPandas(),
                                               big_df.filter(col(key) == sk).toPandas())
        spark.createDataFrame(small_data_result).write.insertInto(tgt_table)

    spark.conf.set("spark.sql.shuffle.partitions", "1000")

    full_schema = "sym string, time timestamp, price float, size int, mid float"

    merged_pandas_udf_df = small_df.filter(~col('sym').isin(skewed_keys)).groupby('sym').cogroup(
        big_df.filter(~col('sym').isin(skewed_keys)).groupby('sym')).applyInPandas(asof_join_udf_pykx,
                                                                                      schema=full_schema)

    merged_pandas_udf_df.write.insertInto(tgt_table)


# COMMAND ----------

aqe_ts_join(small_df=spark.table("pykx_db_trades"), big_df=spark.table("pykx_db_quotes"), key="sym",
            pandas_func=asof_join_udf_pykx, tgt_table="rp_asof_result")

# COMMAND ----------

# MAGIC %sql select count(1) from rp_asof_result

# COMMAND ----------

# MAGIC %sql select * from rp_asof_result
