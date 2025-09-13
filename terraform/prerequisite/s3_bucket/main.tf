resource "aws_s3_bucket" "db_backups_bucket" {
  bucket = var.name

  tags = {
    Name = var.name
  }
}

# Define the standalone website configuration resource
resource "aws_s3_bucket_website_configuration" "db_backups_website" {
  bucket = aws_s3_bucket.db_backups_bucket.id

  index_document {
    suffix = "index.html"
  }
}

# CORS configuration for static website hosting
resource "aws_s3_bucket_cors_configuration" "db_backups_cors" {
  bucket = aws_s3_bucket.db_backups_bucket.id

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
    expose_headers = []
  }
}

# Versioning as a prevention of data loss
resource "aws_s3_bucket_versioning" "db_backups_versioning" {
  bucket = aws_s3_bucket.db_backups_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Disable the bucket-level and account-level public access block.
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.db_backups_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy for public list + read
resource "aws_s3_bucket_policy" "combined_access_policy" {
  bucket = aws_s3_bucket.db_backups_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy_document.json
  depends_on = [aws_s3_bucket_public_access_block.public_access]
}

data "aws_iam_policy_document" "bucket_policy_document" {
  statement {
    sid       = "PublicReadListGet"
    effect    = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.db_backups_bucket.arn,
      "${aws_s3_bucket.db_backups_bucket.arn}/*",
    ]
  }
}

locals {
  website_files = fileset("${path.module}/files", "*")
}

resource "aws_s3_object" "website_files" {
  for_each = local.website_files
  bucket = aws_s3_bucket.db_backups_bucket.id
  key    = each.value
  source = "${path.module}/files/${each.value}"
  etag   = filemd5("${path.module}/files/${each.value}")
  depends_on = [aws_s3_bucket_policy.combined_access_policy]
}
