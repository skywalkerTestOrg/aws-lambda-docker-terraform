#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lambda_function
resource "aws_lambda_function" "container_lambda" {
  function_name                  = "${var.name}-lambda"
  role                           = aws_iam_role.lambda_role.arn
  package_type                   = "Image"
  image_uri                      = var.image_uri
  memory_size                    = var.memory_size
  timeout                        = var.timeout
  reserved_concurrent_executions = var.reserved_concurrency
  kms_key_arn                    = aws_kms_key.encrypt_lambda_environments.arn
  logging_config {
    log_format       = "JSON"
    log_group        = aws_cloudwatch_log_group.lambda_log.name
    system_log_level = "INFO"
  }
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {}
  }
  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dead_letter_queue.arn
  }
  #checkov:skip=CKV_AWS_272: "Ensure AWS Lambda function is configured to validate code-signing"
  #Skip-reason: Code signing is not supported for Lambda running Docker containers.
  #https://docs.aws.amazon.com/lambda/latest/dg/configuration-codesigning-create.html

  #checkov:skip=CKV_AWS_117: "Ensure that AWS Lambda function is configured inside a VPC"
  #Skip-reason: Primary purpose of this use case is to demonstrate how to create a Lambda function using a container image
  #hence not included VPC configuration.
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "lambda_role" {
  name = "${var.name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

locals {
  image_uri      = var.image_uri
  ecr_account_id = split(".", local.image_uri)[0]
  ecr_region     = split(".", local.image_uri)[3]
  ecr_repo_path  = split("/", local.image_uri)[1]
  ecr_repo_name  = split(":", local.ecr_repo_path)[0]

  ecr_repo_arn = "arn:aws:ecr:${local.ecr_region}:${local.ecr_account_id}:repository/${local.ecr_repo_name}"
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
resource "aws_iam_role_policy" "lambda_ecr_access" {
  name = "${var.name}-lambda-ecr-access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = [local.ecr_repo_arn]
      }
    ]
  })
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
resource "aws_iam_role_policy" "lambda_dlq_and_kms_access" {
  name = "${var.name}-lambda-dlq-kms-access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowSendMessageToDLQ",
        Effect = "Allow",
        Action = [
          "sqs:SendMessage"
        ],
        Resource = aws_sqs_queue.lambda_dead_letter_queue.arn
      },
      {
        Sid    = "AllowDecryptKMSForDLQ",
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        Resource = aws_kms_key.encrypt_sqs.arn
      }
    ]
  })
}