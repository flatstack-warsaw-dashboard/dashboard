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

resource "aws_iam_role" "codebuild_tf_apply" {
  name = "codebuild_tf_apply"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codebuild.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "example" {
  role = aws_iam_role.codebuild_tf_apply.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Resource" : [
          "*"
        ],
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : [
          "arn:aws:s3:::fwd-dashboard-app-codepipeline-artifacts",
          "arn:aws:s3:::fwd-dashboard-app-codepipeline-artifacts/*"
        ]
      }
    ]
  })
}

resource "aws_codebuild_project" "tf_apply_dashboard_app" {
  name         = "tf_apply_dashboard_app"
  service_role = aws_iam_role.codebuild_tf_apply.arn

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

