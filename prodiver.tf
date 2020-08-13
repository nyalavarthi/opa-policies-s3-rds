# we provision resources only in aws region which is defined by the variables
provider "aws" {
  #access_key = " "
  #secret_key = " "
  region = "us-east-1"
  #token =""
}

terraform {
  backend "s3" {
    bucket = "your-s3-state-bucket"
    key    = "OPA/opa-policies.tfstate"
    region = "us-east-1"
  }
}  