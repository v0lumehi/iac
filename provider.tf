terraform {
  backend "s3" {
    bucket = "jambit-iac-terraform"
    key    = "zaljic/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  version = "~> 2"
  region  = "eu-west-1"
}
