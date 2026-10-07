output "s3_bucket_id" {
  description = "The name / ID of the created S3 bucket"
  value       = aws_s3_bucket.demo_bucket.id
}

output "s3_bucket_arn" {
  description = "The Amazon Resource Name (ARN) of the bucket"
  value       = aws_s3_bucket.demo_bucket.arn
}

output "s3_bucket_region" {
  description = "The AWS region where the bucket resides"
  value       = aws_s3_bucket.demo_bucket.region
}

output "versioning_status" {
  description = "Current versioning status"
  value       = aws_s3_bucket_versioning.versioning_config.versioning_configuration[0].status
}
