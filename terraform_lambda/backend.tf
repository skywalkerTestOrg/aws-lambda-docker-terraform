terraform {
  backend "s3" {
    bucket       = "tf-state-bucket-02342342d"
    encrypt      = true
    key          = "tf/aws-lambda-docker-terraform/terraform_lambda/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}