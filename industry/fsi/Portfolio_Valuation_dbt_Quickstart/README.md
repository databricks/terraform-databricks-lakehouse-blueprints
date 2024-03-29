## Quickstart for Portfolio Valuation and Analysis using dbt on Databricks 

The dbt project at the github [here](https://github.com/rportilla-databricks/dbt-asset-mgmt) reads simulated trades (executed trades for a given portfolio), quotes, market_trades (external), and sentiment data from a sample of reddit data to showcase how intraday portfolio value can be computed incrementally using Delta Lake and dbt on the Lakehouse. 

To start, we post a reference architecture for asset management where dbt plays a role. See the quickstart steps below this to get started. 

### Reference Architecture
![Coalesce Financial Services Databricks Talk](https://user-images.githubusercontent.com/38080604/144859772-728c1830-b168-4e65-af16-8d623ede109a.jpg)


You can get stared with this simple quickstart in 2 simple steps: 
 
<p></p>

1) Set up a task with a prep notebook available [here](https://github.com/rportilla-databricks/dbt-asset-mgmt/blob/main/databricks_job/dbt%20Prep.py)
<br></br>
<img src='https://raw.githubusercontent.com/rportilla-databricks/dbt-asset-mgmt/main/images/prep_task.png' width=700>
 
2) Set up a dbt task with a project on intraday portfolio valuation
<br></br>
<img src='https://raw.githubusercontent.com/rportilla-databricks/dbt-asset-mgmt/main/images/dbt_task.png' width=700>
 
<br></br>
View the successful run after execution: 

<img src='https://raw.githubusercontent.com/rportilla-databricks/dbt-asset-mgmt/main/images/successful_run.png' width=700>
 
<br></br>

View lineage available from Unity Catalog after building all dbt models!

<img src='https://raw.githubusercontent.com/rportilla-databricks/dbt-asset-mgmt/main/images/uc_lineage.png'>
