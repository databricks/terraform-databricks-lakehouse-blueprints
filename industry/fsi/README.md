# Industry Quickstarts - Financial Services

## Purpose

What is an industry quickstart? It's a simple, self-contained demo that makes it easy to start using Databricks for a broad range of financial services use cases. We will usually demonstrate a Databricks feature or integration in the context of a financial use case to make them relevant for industry practitioners and those new to Databricks.  An example would be a DTI calculation with buy-now-pay-later data using a Databricks integration with Prophecy.io, a platform for reproducible, GUI-based development. 

### Technology Integrations

Databricks has a broad range of technology partners, and as part of the quickstarts seen here, we will aim to integrate these into our industry quickstarts. So far, we have ~[dbt](https://www.getdbt.com/) and ![Prophecy](https://www.prophecy.io/) represented, with more to come!

![Technology Ecosystem](https://www.databricks.com/wp-content/uploads/2022/08/isv-ecosytem-for-web-img.png)

### Examples 

#### 1. Credit Decisioning Metrics with Prophecy.io 

DTI metrics are a basic starting point for assessing credit for short-term loans. In this quickstart, we use Prophecy.io as a development tool for integrating BNPL, Credit Bureau, and Customer-level information to compute DTI metrics. Features include: 

* Documentation on importing the Prophecy project 
* Pre-built Prophecy.io DAG
* Databricks SQL Dashboard showing the basic metrics 

![Prophecy DAG](https://raw.githubusercontent.com/databricks/terraform-databricks-lakehouse-blueprints/main/industry/fsi/images/step_4.png)

#### 2. Portfolio Valuation with dbt

Portfolio Valuation involves integration internal data (portfolio positions) along with external market data. In this simple quickstart, we show how the integration is done with dbt, how Unity Catalog captures the lineage, and how to integrate unstructured data sources using Databricks ingestion. Features include: 

* Documentation of the Architecture 
* Pre-built dbt project 
* Unity Catalog Visualization of Lineage

<img src='https://raw.githubusercontent.com/rportilla-databricks/dbt-asset-mgmt/main/images/uc_lineage.png'>


#### 3. ISO20022 Payments ETL and Analytics with Structured Streaming


The ISO20022 standard simplifies the way in which payment remittance information is stored and shared across the financial services ecosystem. Since the new format has more structure in XML, all banking institutions will be required to consolidate data in the format. This quickstart shows both how to save into the ISO20022 format and how to parse and analyze it. Features include: 

* Streaming integration of parquet sources into the ISO2022 format 
* Parsing the format using Spark 
* Masking PII information 
* Databricks SQL dashboard showing basic metrics for customers

<img width="1100px" src="https://raw.githubusercontent.com/rportilla-databricks/dbt-asset-mgmt/main/images/payments_lakehouse_arch_flow.png" />
