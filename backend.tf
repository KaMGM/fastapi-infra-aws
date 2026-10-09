
terraform {
  backend "s3" {
    bucket         = "mon-bucket-tfstate-911167911701" 
    key            = "infra-complete/terraform.tfstate"
    region         = "us-east-1"
  }
}