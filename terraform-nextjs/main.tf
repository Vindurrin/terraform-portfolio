provider "aws" {
  region = "us-east-1"
}


# 1. The bucket itself (this is what was missing)
resource "aws_s3_bucket" "portfolio_bucket_mb26" {
  bucket = "portfolio-bucket-mb26"

  tags = {
    Name        = "Portfolio Website"
    Environment = "Production"
  }
}

# 3. Block public policies (new buckets block them by default)
resource "aws_s3_bucket_public_access_block" "portfolio_bucket_mb26" {
  bucket = aws_s3_bucket.portfolio_bucket_mb26.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 4. Public read policy, applied only after the block is lifted
resource "aws_s3_bucket_policy" "portfolio_bucket_mb26_bucket_policy" {
  bucket = aws_s3_bucket.portfolio_bucket_mb26.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.portfolio_bucket_mb26.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.portfolio_distribution.arn
          }
        }
      }
    ]
  })

}

resource "aws_cloudfront_distribution" "portfolio_distribution" {
  origin {
    domain_name              = aws_s3_bucket.portfolio_bucket_mb26.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.portfolio.id
    origin_id                = "S3-Website"

  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-Website"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }



  tags = {
    Name        = "CloudFront Portfolio"
    Environment = "Production"
  }

}

resource "aws_cloudfront_origin_access_control" "portfolio" {
  name                              = "portfolio-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
