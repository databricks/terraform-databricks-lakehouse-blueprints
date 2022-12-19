Deploy AWS Databricks Workspace with Data Exfiltration Protection and Private Link
=========================

In this example, we show an example deployment of Databricks workspaces with exfiltration protection. Backend private link and customer managed keys are also included in the template. The official guide here shows how to prepare data exfiltration protection networking infra: https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/aws-e2-firewall-hub-and-spoke. In this example we modified our existing modules to make it a complete example with both workspaces and networking infra.

Users of this template minimally should do these:
1. Supply credentials (aws+databricks) and configuration variables. 
2. Create a CMK admin role in IAM and get its ARN and supply it to `var.cmk_admin`.
3. Run `terraform init` and `terraform apply` to deploy resources.

## Acknowledgement
This sample template takes CMK module from the work of andrew.weaver@databricks.com. See original repo here: https://github.com/andyweaves/databricks-terraform-e2e-examples.

## Architecture

> Take reference to official guide diagram: https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/aws-e2-firewall-hub-and-spoke

## Get Started

> Step 1: Clone this repo to local, set environment variables for `aws` and `databricks` providers authentication:
    
```bash
export TF_VAR_databricks_account_username=your_username
export TF_VAR_databricks_account_password=your_password
export TF_VAR_databricks_account_id=your_databricks_E2_account_id

export AWS_ACCESS_KEY_ID=your_aws_role_access_key_id
export AWS_SECRET_ACCESS_KEY=your_aws_role_secret_access_key
```

> Step 2: In your AWS IAM, create a cmk admin role and assign it to a user, get its ARN into the variable `cmk_admin`, you can supply the value to overwrite default value by using environment variable `export TF_VAR_cmk_admin=xxxx`:

```terraform
variable "cmk_admin" {
  type      = string
  sensitive = true
  default   = "arn:aws:iam::xxxx:user/xxxx" // sample arn 
}
```

If you are deploying to other regions (current default is eu-central-1), you need to supply values for other variables, you can find them on https://docs.databricks.com/administration-guide/cloud-configurations/aws/customer-managed-vpc.html; these are the required connections per region.

You should also change the values of `workspace_vpce_service` and `relay_vpce_service` based on the regions, you can find regional values here: https://docs.databricks.com/administration-guide/cloud-configurations/aws/privatelink.html

