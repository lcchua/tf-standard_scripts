#============ S3 BUCKET =============

# Bucket with versioning enabled and acl set to public read
resource "random_id" "s3_id" {
  byte_length = 2
}
resource "aws_s3_bucket" "lcchua-tf-s3bucket" {
  bucket = "lcchua-bucket-${random_id.s3_id.dec}"

  tags = {
    group = var.stack_name
    Env   = "Dev"
    Name  = "stw-s3-bucket"
  }
}
output "s3bucket" {
  description = "18a stw devops S3 bucket"
  value       = aws_s3_bucket.lcchua-tf-s3bucket.id
}

# Enable bucket versioning 
resource "aws_s3_bucket_versioning" "lcchua-tf-s3bucket-versioning" {
  bucket = aws_s3_bucket.lcchua-tf-s3bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
output "s3bucket-versioning" {
  description = "18b stw devops S3 bucket versioning"
  value       = aws_s3_bucket_versioning.lcchua-tf-s3bucket-versioning.id
}

# Enable bucket ownership control and public read
resource "aws_s3_bucket_ownership_controls" "lcchua-tf-s3bucket-owner-ctl" {
  bucket = aws_s3_bucket.lcchua-tf-s3bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_public_access_block" "lcchua-tf-s3bucket-pub-access-blk" {
  bucket = aws_s3_bucket.lcchua-tf-s3bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
# Set up bucket ACL
resource "aws_s3_bucket_acl" "lcchua-tf-s3bucket-acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.lcchua-tf-s3bucket-owner-ctl,
    aws_s3_bucket_public_access_block.lcchua-tf-s3bucket-pub-access-blk
  ]

  bucket = aws_s3_bucket.lcchua-tf-s3bucket.id
  acl    = "public-read"
}
output "s3bucket-acl" {
  description = "18c stw devops S3 bucket acl set to public read"
  value       = aws_s3_bucket_acl.lcchua-tf-s3bucket-acl.id
}
