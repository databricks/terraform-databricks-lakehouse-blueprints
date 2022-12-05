# Databricks notebook source
# MAGIC %md 
# MAGIC 
# MAGIC ## Prepare Data for use in Portfolio Valuation Use Case (dbt on Databricks)

# COMMAND ----------

# MAGIC %sql 
# MAGIC 
# MAGIC create catalog if not exists industry_fe

# COMMAND ----------

# MAGIC %sql 
# MAGIC 
# MAGIC create database if not exists industry_fe.asset_mgmt

# COMMAND ----------

# MAGIC %sh 
# MAGIC 
# MAGIC wget https://raw.githubusercontent.com/rportilla-databricks/dbt-asset-mgmt/blob/main/data/$tbl.csv.gz
# MAGIC https://raw.githubusercontent.com/rportilla-databricks/dbt-asset-mgmt/main/images/payments_lakehouse_overview.png

# COMMAND ----------

# MAGIC %sh 
# MAGIC 
# MAGIC for tbl in 'trades' 'quotes' 'market_trades' 'sentiment'
# MAGIC do
# MAGIC     wget https://raw.githubusercontent.com/rportilla-databricks/dbt-asset-mgmt/main/data/$tbl.csv.gz
# MAGIC     gunzip $tbl.csv.gz
# MAGIC     mkdir -p /dbfs/FileStore/shared_uploads/dbt-asset-mgmt/data/$tbl/
# MAGIC     cp $tbl.csv /dbfs/FileStore/shared_uploads/dbt-asset-mgmt/data/$tbl/
# MAGIC done

# COMMAND ----------

# MAGIC %fs ls /FileStore/shared_uploads/dbt-asset-mgmt/data/trades/

# COMMAND ----------

# MAGIC %sql 
# MAGIC 
# MAGIC --create dbfs copy of trades
# MAGIC drop table if exists hive_metastore.asset_mgmt.trades;
# MAGIC 
# MAGIC create table hive_metastore.asset_mgmt.trades using csv OPTIONS (header="true") LOCATION '/FileStore/shared_uploads/dbt-asset-mgmt/data/trades/trades.csv';
# MAGIC 
# MAGIC --create staged table in the catalog (in practice, the landing zone is directly in the catalog)
# MAGIC drop table if exists industry_fe.asset_mgmt.trades; 
# MAGIC 
# MAGIC create table industry_fe.asset_mgmt.trades as select * from hive_metastore.asset_mgmt.trades;
# MAGIC 
# MAGIC --create dbfs copy of quotes
# MAGIC drop table if exists hive_metastore.asset_mgmt.quotes;
# MAGIC 
# MAGIC create table hive_metastore.asset_mgmt.quotes using csv OPTIONS (header="true", inferSchema="true") LOCATION '/FileStore/shared_uploads/dbt-asset-mgmt/data/quotes/quotes.csv';
# MAGIC 
# MAGIC drop table if exists industry_fe.asset_mgmt.quotes; 
# MAGIC 
# MAGIC --create staged table in the catalog (in practice, the landing zone is directly in the catalog)
# MAGIC create table industry_fe.asset_mgmt.quotes as select * from hive_metastore.asset_mgmt.quotes;
# MAGIC 
# MAGIC --create dbfs copy of market_trades
# MAGIC drop table if exists hive_metastore.asset_mgmt.market_trades;
# MAGIC 
# MAGIC create table hive_metastore.asset_mgmt.market_trades using csv OPTIONS (header="true", inferSchema="true") LOCATION '/FileStore/shared_uploads/dbt-asset-mgmt/data/market_trades/market_trades.csv';
# MAGIC 
# MAGIC drop table if exists industry_fe.asset_mgmt.market_trades; 
# MAGIC 
# MAGIC --create staged table in the catalog (in practice, the landing zone is directly in the catalog)
# MAGIC create table industry_fe.asset_mgmt.market_trades as select * from hive_metastore.asset_mgmt.market_trades;
# MAGIC 
# MAGIC --create dbfs copy of sentiment
# MAGIC drop table if exists hive_metastore.asset_mgmt.sentiment;
# MAGIC 
# MAGIC create table hive_metastore.asset_mgmt.sentiment using csv OPTIONS (header="true") LOCATION '/FileStore/shared_uploads/dbt-asset-mgmt/data/sentiment/sentiment.csv';
# MAGIC 
# MAGIC drop table if exists industry_fe.asset_mgmt.sentiment; 
# MAGIC 
# MAGIC --create staged table in the catalog (in practice, the landing zone is directly in the catalog)
# MAGIC create table industry_fe.asset_mgmt.sentiment as select * from hive_metastore.asset_mgmt.sentiment;

# COMMAND ----------

# MAGIC %sql select * from industry_fe.asset_mgmt.market_trades
