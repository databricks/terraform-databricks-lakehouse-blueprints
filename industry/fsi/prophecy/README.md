# Getting Started with Prophecy and Databricks in Financial Services 

Users in Financial Services have a wide variety of ETL tools to integrate many different data sources. From alternative data providers such as LexisNexis, Acxiom, and AnalyticsIQ to traditional bureau data from firms such as Equifax and TransUnion, it is a non-trivial task to integrate hundreds of sources required for default risk and other use cases. Luckily, [Prophecy on Databricks](https://www.prophecy.io/blogs/prophecy-for-databricks-deep-dive) provides a low-code layer to compose ETL pipelines, speeding up time-to-value. Moreover, Databricks provides the ecosystem to integrate insights, end-to-end. 

In this demo, Databricks serves as the underlying compute. On top of this, Databricks acts as the ingestion layer and the presentation layer after Prophecy pipelines execute, with a DBSQL dashboard layering on top of Delta Lake tables which are created. Follow the simple steps below to get started!


## Step 0 - Import Databricks notebook 

Import `00_Data_Load.py` into your Databricks environment. The file is located in the [prophecy folder](https://github.com/databricks/terraform-databricks-lakehouse-blueprints/tree/main/industry/fsi/prophecy) to load data into Databricks.

## Step 1 - Create Prophecy Project

![Step 1](https://raw.githubusercontent.com/databricks/terraform-databricks-lakehouse-blueprints/main/industry/fsi/images/step_1.png)

## Step 2 - Connect Prophecy to Pre-made Pipeline

**NOTE**: Create a fork of the lakehouse blueprints repository and provide read/write access to the /prophecy-managed folder (as shown in the image below) to hook up to Prophecy.

![Step 2](https://raw.githubusercontent.com/databricks/terraform-databricks-lakehouse-blueprints/main/industry/fsi/images/step_2.png)

## Step 3 - Show Pipeline as Part of Project

![Step 3](https://raw.githubusercontent.com/databricks/terraform-databricks-lakehouse-blueprints/main/industry/fsi/images/step_3.png)

## Step 4 - Show Pipeline Integrate Credit Decisioning Data Sources with Final DTI Metrics Dataset

See the sample pipeline - create a branch and modify as needed to experiment with Prophecy on Databricks!

![Step 3](https://raw.githubusercontent.com/databricks/terraform-databricks-lakehouse-blueprints/main/industry/fsi/images/step_4.png)

## Step 5 - Create a Databricks SQL Dashboard 

Execute the view creation `02_Create_DTI_View.sql` in the [lakehouse blueprints prophecy folder](https://github.com/databricks/terraform-databricks-lakehouse-blueprints/tree/main/industry/fsi/prophecy) and import the Prophecy Credit Decision Dashboard to see basic visualizations and metrics available in Databricks. This completes the end-to-end quickstart with Prophecy on Databricks.