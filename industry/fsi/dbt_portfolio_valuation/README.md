# Databricks notebook source
# MAGIC %md
# MAGIC 
# MAGIC ## Portfolio Valuation and Analysis using dbt on Databricks 
# MAGIC 
# MAGIC The dbt project at the github [here](https://github.com/rportilla-databricks/dbt-asset-mgmt) reads simulated trades (executed trades for a given portfolio), quotes, market_trades (external), and sentiment data from a sample of reddit data to showcase how intraday portfolio value can be computed incrementally using Delta Lake and dbt on the Lakehouse. 
# MAGIC 
# MAGIC You can get stared with this simple quickstart in 2 simple steps: 
# MAGIC 
# MAGIC <p></p>
# MAGIC 
# MAGIC 1) Set up a task with a prep notebook available [here](https://github.com/rportilla-databricks/dbt-asset-mgmt/blob/main/databricks_job/dbt%20Prep.py)
# MAGIC <br></br>
# MAGIC <img src='https://raw.githubusercontent.com/rportilla-databricks/dbt-asset-mgmt/main/images/prep_task.png' width=700>
# MAGIC 
# MAGIC 2) Set up a dbt task with a project on intraday portfolio valuation
# MAGIC <br></br>
# MAGIC <img src='https://raw.githubusercontent.com/rportilla-databricks/dbt-asset-mgmt/main/images/dbt_task.png' width=700>
# MAGIC 
# MAGIC <br></br>
# MAGIC View the successful run after execution: 
# MAGIC 
# MAGIC <img src='https://raw.githubusercontent.com/rportilla-databricks/dbt-asset-mgmt/main/images/successful_run.png' width=700>
# MAGIC 
# MAGIC <br></br>
# MAGIC 
# MAGIC View lineage available from Unity Catalog after building all dbt models!
# MAGIC 
# MAGIC <img src='https://raw.githubusercontent.com/rportilla-databricks/dbt-asset-mgmt/main/images/uc_lineage.png'>
