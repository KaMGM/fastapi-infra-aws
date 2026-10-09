terraform {
  backend "s3" {
    bucket         = "mon-tfstate-bucket-fastapi"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}