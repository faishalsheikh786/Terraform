terraform {
  backend "s3" {
    bucket         = "faishal-bucket-1234567890"
    key            = "faishal/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}