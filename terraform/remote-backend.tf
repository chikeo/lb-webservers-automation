terraform {
  required_version = "~> 0.11.10"

  backend "s3" {
    encrypt        = true
    bucket         = "andela-terraform-remote-state-storage-s3"
    dynamodb_table = "andela-terraform-state-lock-dynamo"
    region         = "us-east-2"
    key            = "andela/terraform.tfstate"
  }
}
