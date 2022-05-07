terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.12.1"
    }
  }

  backend "s3" {
    bucket               = "fwd-dashboard-app-tf-remote-state"
    key                  = "codepipeline.tfstate"
    region               = "eu-central-1"
    encrypt              = true
    dynamodb_table       = "tf-remote-state-locks"
    workspace_key_prefix = "codepipeline/env:"
  }
}

provider "aws" {
  region = "eu-central-1"
}

locals {
  branch = terraform.workspace == "default" ? "main" : terraform.workspace
  target_workspace = local.branch == "main" ? "staging" : "branch-${local.branch}"
}

resource "aws_codepipeline" "codepipeline" {
  name     = "dashboard-app-${local.branch}"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = "fwd-dashboard-app-codepipeline-artifacts"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.gh_connection.arn
        FullRepositoryId = "flatstack-warsaw-dashboard/dashboard"
        BranchName       = local.branch
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "tf-apply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = "tf_apply_dashboard_app"
        EnvironmentVariables = jsonencode([
          {
            name : "TARGET_WORKSPACE",
            value : local.target_workspace
          }
        ])
      }
    }
  }

  dynamic "stage" {
    for_each = local.branch == "main" ? [1] : []
    content {
      name = "Approve"
      action {
        name     = "Production-Approval"
        category = "Approval"
        owner    = "AWS"
        provider = "Manual"
        version  = "1"
      }
    }
  }

  dynamic "stage" {
    for_each = local.branch == "main" ? [1] : []
    content {
      name = "Deploy-Production"

      action {
        name            = "tf-apply"
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        version         = "1"
        input_artifacts = ["source_output"]

        configuration = {
          ProjectName = "tf_apply_dashboard_app"
          EnvironmentVariables = jsonencode([
            {
              name : "TARGET_WORKSPACE",
              value : "production"
            }
          ])
        }
      }
    }
  }
}

resource "aws_codestarconnections_connection" "gh_connection" {
  name          = "gh-connection"
  provider_type = "GitHub"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codepipeline.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl",
          "s3:PutObject"
        ],
        "Resource" : [
          "arn:aws:s3:::fwd-dashboard-app-codepipeline-artifacts",
          "arn:aws:s3:::fwd-dashboard-app-codepipeline-artifacts/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "codestar-connections:UseConnection"
        ],
        "Resource" : aws_codestarconnections_connection.gh_connection.arn
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ],
        "Resource" : "*"
      }
    ]
  })
}
