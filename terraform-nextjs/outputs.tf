output "bucket_website_endpoint" {
  value = aws_s3_bucket_website_configuration.portfolio_bucket_mb26.website_endpoint
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.portfolio_distribution.domain_name
}
