resource "aws_s3_bucket" "remote_state" {
  bucket = "fwd-dashboard-app-tf-remote-state"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "remote_state_bucket_acl" {
  bucket = aws_s3_bucket.remote_state.bucket
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "remote_state_bucket_sse_config" {
  bucket = aws_s3_bucket.remote_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "remote_state_bucket_versioning" {
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
