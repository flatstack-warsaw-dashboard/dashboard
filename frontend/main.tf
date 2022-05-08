terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.12.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.2.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.1"
    }
  }

  backend "s3" {
    bucket               = "fwd-dashboard-app-tf-remote-state"
    key                  = "frontend_app.tfstate"
    region               = "eu-central-1"
    encrypt              = true
    dynamodb_table       = "tf-remote-state-locks"
    workspace_key_prefix = "frontend_app/env:"
  }
}

provider "aws" {
  region = "eu-central-1"
}

locals {
  s3_origin_id = "frontend-app-origin-${terraform.workspace}"
}

resource "aws_s3_bucket" "frontend_app_bucket" {
  bucket_prefix = "fwd-dashboard-app"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "frontend_app_bucket_acl" {
  bucket = aws_s3_bucket.frontend_app_bucket.bucket
  acl    = "private"
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend_app_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "frontend_app_bucket_policy" {
  bucket = aws_s3_bucket.frontend_app_bucket.bucket
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "s3:GetObject"
        Effect : "Allow"
        Principal : {
          AWS : aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
        }
        Resource : "${aws_s3_bucket.frontend_app_bucket.arn}/*"
      },
    ]
  })
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.frontend_app_bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

module "file_extensions" {
  source  = "reifnir/mime-map/null"
}

resource "aws_s3_object" "file" {
  for_each = fileset("${path.module}/dist", "**")

  bucket = aws_s3_bucket.frontend_app_bucket.bucket
  key    = each.value
  source = "${path.module}/dist/${each.value}"
  etag   = filemd5("${path.module}/dist/${each.value}")
  content_type = lookup(module.file_extensions.mappings, regex("\\.([^.]+)$", each.value)[0], null)
}

output "domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}
