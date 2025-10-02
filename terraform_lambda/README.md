# Lambda Container Deployment Terraform Module

This Terraform module deploys an AWS Lambda function using a container image from Amazon ECR.

## Features

- Deploys a Lambda function using a container image
- Creates necessary IAM roles and permissions
- Sets up CloudWatch logs for the Lambda function
- Optional Lambda Function URL for direct invocation

## Usage

```hcl
module "lambda" {
  source       = "./terraform_lambda"
  
  function_name = "my-container-lambda"
  image_uri     = "111122223333.dkr.ecr.us-east-1.amazonaws.com/app-10:latest"
  
  # Optional parameters
  memory_size   = 256
  timeout       = 30
  create_function_url = true
  environment_variables = {
    ENV_VAR_1 = "value1"
    ENV_VAR_2 = "value2"
  }
}
```

## Input Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| function_name | Name of the Lambda function | string | - |
| image_uri | ECR Image URI for the Lambda container image | string | - |
| memory_size | Memory size for the Lambda function (in MB) | number | 128 |
| timeout | Timeout for the Lambda function (in seconds) | number | 30 |
| environment_variables | Environment variables for the Lambda function | map(string) | {} |
| log_retention_days | Number of days to retain Lambda logs | number | 14 |
| region | AWS region | string | "us-east-1" |
| create_function_url | Whether to create a function URL for the Lambda | bool | false |

## Outputs

| Name | Description |
|------|-------------|
| lambda_function_arn | The ARN of the Lambda function |
| lambda_function_name | The name of the Lambda function |
| lambda_role_arn | The ARN of the IAM role created for the Lambda function |
| lambda_invoke_arn | The invoke ARN of the Lambda function |
| lambda_function_url | The URL of the Lambda function (if configured) |