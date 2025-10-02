#Define AWS Region
variable "region" {
  description = "Infrastructure region"
  type        = string
  default     = "us-east-2"
}
#Define IAM User Access Key
variable "access_key" {
  description = "The access_key that belongs to the IAM user"
  type        = string
  sensitive   = true
  default     = ""
}
#Define IAM User Secret Key
variable "secret_key" {
  description = "The secret_key that belongs to the IAM user"
  type        = string
  sensitive   = true
  default     = ""
}
variable "name" {
  description = "The name of the application."
  type        = string
  default     = "app-8"
}
variable "log_group_prefix" {
  description = "The name of the log group."
  type        = string
  default     = "/aws/lambda/"
}
variable "image_uri" {
  description = "ECR Image URI for the Lambda container image (format: {account}.dkr.ecr.{region}.amazonaws.com/{repo}:{tag})"
  type        = string
}
variable "memory_size" {
  description = "Memory size for the Lambda function (in MB)"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Timeout for the Lambda function (in seconds)"
  type        = number
  default     = 30
}
variable "log_retention_days" {
  description = "Number of days to retain Lambda logs"
  type        = number
  default     = 365
}
# variable "reserved_concurrency" {
#   description = "Reserved concurrent executions for the Lambda function"
#   type        = number
#   default     = 2
# }