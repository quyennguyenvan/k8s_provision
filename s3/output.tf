output "bucket_id" {
  value = aws_s3_bucket.bucket_data.id
}

output "bucket_arn" {
  value = aws_s3_bucket.bucket_data.arn
}

output "cloudfront_dns" {
  value = { for k, v in aws_cloudfront_distribution.cf_s3_distribution : k => v.domain_name }
}
