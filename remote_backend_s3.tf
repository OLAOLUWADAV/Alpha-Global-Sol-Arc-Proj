terraform {
  backend "s3" {
    bucket         = "dev-proj-1-jenkins-terraform-state-2025"
    key            = "iac-aws-ecommerce/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}
