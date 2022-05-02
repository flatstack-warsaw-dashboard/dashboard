resource "aws_codebuild_project" "terraform_apply" {
  name          = "terraform-apply-${var.branch}"
  description   = "This CodeBuild apply Terraform using the code from ${var.branch} branch"
  service_role  = aws_iam_role.example.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-aarch64-standard:2.0"
    type                        = "ARM_CONTAINER"
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = aws_codepipeline.example.buildspec
  }
}
