# S3 Static Assets & Backup Bucket
resource "aws_s3_bucket" "assets_bucket" {
  bucket_prefix = "${var.bucket_prefix}-${var.environment}-"
  force_destroy = true

  # Explicit dependency demonstration
  depends_on = [
    aws_vpc.main_vpc
  ]

  tags = {
    Name = "${var.environment}-assets-bucket"
    Tier = "Storage"
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "assets_versioning" {
  bucket = aws_s3_bucket.assets_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "assets_encryption" {
  bucket = aws_s3_bucket.assets_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Public Access Block
resource "aws_s3_bucket_public_access_block" "assets_block" {
  bucket = aws_s3_bucket.assets_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
