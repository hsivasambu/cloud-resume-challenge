output "bucket_name" {
  value       = aws_s3_bucket.blog.bucket
  description = "Blog S3 bucket name"
}

output "cloudfront_distribution_id" {
  value       = aws_cloudfront_distribution.blog.id
  description = "Blog CloudFront distribution ID"
}

output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.blog.domain_name
  description = "Blog CloudFront domain name"
}
