terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.12.1"
    }
  }

  backend "s3" {
    bucket         = "fwd-dashboard-app-tf-remote-state"
    key            = "codebuild_tf_apply.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "tf-remote-state-locks"
  }
}

provider "aws" {
  region = "eu-central-1"
}

locals {
  buildspec = file("buildspec.yml")
}

data "aws_iam_role" "admin" {
  name = "admin"
}

resource "aws_codebuild_project" "tf_apply_dashboard_app" {
  name         = "tf_apply_dashboard_app"
  service_role = data.aws_iam_role.admin.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-aarch64-standard:2.0"
    type         = "ARM_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = local.buildspec
  }
}

