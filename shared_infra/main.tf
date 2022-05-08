terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.12.1"
    }
  }

#  backend "s3" {
#    bucket         = "fwd-dashboard-app-tf-remote-state"
#    key            = "shared_infra.tfstate"
#    region         = "eu-central-1"
#    encrypt        = true
#    dynamodb_table = "tf-remote-state-locks"
#  }
}

provider "aws" {
  region = "eu-central-1"
}
