# ---------------------------------------------------------------------------
# S3 bucket (private, static assets)
# ---------------------------------------------------------------------------
resource "random_id" "bucket" {
  byte_length = 6
}

resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name != "" ? var.bucket_name : "${var.bucket_prefix}-${random_id.bucket.hex}"

  tags = {
    Name        = "${var.environment}-s3-bucket"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Versioning
# ---------------------------------------------------------------------------
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ---------------------------------------------------------------------------
# Block ALL public access. CloudFront reads the bucket through Origin Access
# Control; the bucket policy granting that is defined in the root module.
# ---------------------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
