output "cross_account_role_arn" {
  value       = aws_iam_role.cross_account_role.arn
  description = "Cross account IAM role for Databricks workspace deployment"
}

output "root_bucket" {
  value       = aws_s3_bucket.root_storage_bucket.bucket
  description = "root bucket"
}
