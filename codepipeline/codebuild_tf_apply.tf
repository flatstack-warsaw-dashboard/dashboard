locals {
  buildspec = templatefile("buildspec.yml.tftpl", {
    branch = var.branch
  })
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

resource "aws_codebuild_project" "tf_apply_dashboard_app" {
  name         = "deploy_dashboard_app"
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
