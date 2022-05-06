terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.12.1"
    }
  }

  backend "s3" {
    bucket         = "tf-remote-state20220502044723327700000001"
    key            = "remote_state_infra.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "tf-remote-state-locks"
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_s3_bucket" "remote_state" {
  bucket_prefix = "tf-remote-state"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "remote_state_bucket_acl" {
  bucket = aws_s3_bucket.remote_state.bucket
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "remote_state_sse_config" {
  bucket = aws_s3_bucket.remote_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "remote_state_versioning" {
  bucket = aws_s3_bucket.remote_state.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "locks" {
  name         = "tf-remote-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }
}

output "bucket" {
  value = aws_s3_bucket.remote_state.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.locks.name
}

