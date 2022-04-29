## Deploy Your Financial Services Lakehouse Architecture 

### Purpose: 

This set of terraform templates is designed to get every FS practitioner and devops team started quickly with financial services best practice setup as well as highly valuable FS-focused libraries directly in your environment. 

<p align="center">
  <img src="fs_blueprints.jpg" width="700px"/>
</p>


### Details on What is Packaged: 

What's include in this Terraform package? 

1. Hardened Cloud Environment (restricted root bucket) 
2. Restricted PII Rules via Databricks ACLs and Groups
3. Pre-installed Libraries for Creating Common Data Models & Time Series Analytics
4. Example Job with Financial Services Quickstarts
5. PrivateLink Automation for AWS


### AWS 

3 main modules: 

* Workspace from scratch (new)
* Managed VPC - Private Link workspace
* Managed VPC - Pre-installed FS libraries, Groups to protect PII, Private Link


### Azure 


* Workspace from scratch (new)
* Managed VNET - No public IPs in VNET with private NSGs
