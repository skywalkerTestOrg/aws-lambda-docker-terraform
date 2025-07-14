data "aws_region" "current" {}
# Create a KMS key for encryption
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key
resource "aws_kms_key" "ecr_kms_key" {
  description             = "KMS key to encrypt ECR images in central AWS account."
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = { "Name" = "${var.name}-encrypt-ecr" }
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias
resource "aws_kms_alias" "ecr_key_alias" {
  name          = "alias/${var.name}-encrypt-ecr"
  target_key_id = aws_kms_key.ecr_kms_key.key_id
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key_policy
resource "aws_kms_key_policy" "ecr_key_policy" {
  key_id = aws_kms_key.ecr_kms_key.key_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Action = ["kms:*"]
        Effect = "Allow"
        Principal = {
          AWS = "${local.principal_root_arn}"
        }
        Resource = "*"
      },
      {
        Sid    = "Allow ECR to use the key"
        Effect = "Allow"
        Principal = {
          Service = "ecr.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:ReEncrypt*",
          "kms:CreateGrant",
          "kms:RetireGrant"
        ]
        Resource = aws_kms_key.ecr_kms_key.arn
        Condition = {
          StringEquals = {
            "kms:ViaService" = "ecr.${data.aws_region.current.name}.amazonaws.com"
          },
          StringLike = {
            "kms:EncryptionContext:aws:ecr:arn" : "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/*"
          }
        }
      }
    ]
  })
}