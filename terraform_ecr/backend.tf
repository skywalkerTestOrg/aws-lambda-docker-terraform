terraform {
  backend "s3" {
    bucket       = "skywalker-tf-state-bucket"
    encrypt      = true
    key          = "tf/aws-lambda-docker-terraform/terraform_ecr/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}