
data "aws_iam_policy_document" "assume_role_for_ec2" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "role_for_s3_access" {
  name               = "${local.prefix}-ec2-role-for-s3"
  description        = "Role for shared access"
  assume_role_policy = data.aws_iam_policy_document.assume_role_for_ec2.json
  inline_policy {
    name = "${local.prefix}-ext-bucket-access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Action = [
          "s3:PutObjectAcl",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetObjectVersion",
          "s3:GetObject",
          "s3:GetBucketLocation",
          "s3:DeleteObject",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${local.ext_s3_bucket}",
          "arn:aws:s3:::${local.ext_s3_bucket}/*"
        ]
      }]
    })
  }
}
data "aws_iam_policy_document" "pass_role_for_s3_access" {
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.role_for_s3_access.arn]
  }
}
resource "aws_iam_policy" "pass_role_for_s3_access" {
  name   = "${local.prefix}-passrole"
  path   = "/"
  policy = data.aws_iam_policy_document.pass_role_for_s3_access.json
}
resource "aws_iam_role_policy_attachment" "cross_account" {
  policy_arn = aws_iam_policy.pass_role_for_s3_access.arn
  role       = var.crossaccount_role_name
  depends_on = [aws_iam_policy.pass_role_for_s3_access]
}
resource "aws_iam_instance_profile" "shared" {
  name = "shared-${local.prefix}-inst-profile"
  role = aws_iam_role.role_for_s3_access.name
    depends_on = [aws_iam_role.role_for_s3_access]

}
resource "databricks_instance_profile" "shared" {
  instance_profile_arn = aws_iam_instance_profile.shared.arn
  depends_on = [aws_iam_instance_profile.shared]
}
data "databricks_spark_version" "latest" {}
data "databricks_node_type" "smallest" {
  local_disk = true
}

resource "aws_s3_bucket" "ext_bucket" {
  bucket = "${local.ext_s3_bucket}"
   acl    = "private"
  versioning {
    enabled = false
  }
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.ext_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_policy" "read_write" {
  bucket = aws_s3_bucket.ext_bucket.id
  policy = data.aws_iam_policy_document.read_write.json
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "read_write" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.ext_bucket.arn
    ]
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }

    actions = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutObjectAcl"
    ]

    resources = [
      "${aws_s3_bucket.ext_bucket.arn}/*"
    ]
  }
}