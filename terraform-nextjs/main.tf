provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "portfolio" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "VPC for Portfolio"
  }
}

resource "aws_subnet" "public_portfolio_subnet" {
  vpc_id            = aws_vpc.portfolio.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Public Subnet for Portfolio"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.portfolio.id
  tags = {
    Name = "Internet Gateway"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.portfolio.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table for Portfolio"
  }
}

resource "aws_route_table_association" "portfolio_subnet" {
  route_table_id = aws_route_table.route_table.id
  subnet_id      = aws_subnet.public_portfolio_subnet.id
}

# 1. The bucket itself (this is what was missing)
resource "aws_s3_bucket" "portfolio_bucket_mb26" {
  bucket = "portfolio-bucket-mb26"

  tags = {
    Name        = "Portfolio Website"
    Environment = "Production"
  }
}

# 2. Website hosting, configured on the bucket above
resource "aws_s3_bucket_website_configuration" "portfolio_bucket_mb26" {
  bucket = aws_s3_bucket.portfolio_bucket_mb26.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html" # Next.js export produces out/404.html
  }
}

# 3. Allow public policies (new buckets block them by default)
resource "aws_s3_bucket_public_access_block" "portfolio_bucket_mb26" {
  bucket = aws_s3_bucket.portfolio_bucket_mb26.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 4. Public read policy, applied only after the block is lifted
resource "aws_s3_bucket_policy" "portfolio_bucket_mb26_bucket_policy" {
  bucket = aws_s3_bucket.portfolio_bucket_mb26.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.portfolio_bucket_mb26.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.portfolio_bucket_mb26]
}

resource "aws_cloudfront_distribution" "portfolio_distribution" {
  origin {
    domain_name = aws_s3_bucket_website_configuration.portfolio_bucket_mb26.website_endpoint
    origin_id   = "S3-Website"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
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
