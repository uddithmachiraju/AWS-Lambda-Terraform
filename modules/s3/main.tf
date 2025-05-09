# Create S3 Bucket to store our files
resource "aws_s3_bucket" "lambda_s3_bucket" {
  bucket = var.s3_bucket_name
}

# Upload our 'function.zip' in the s3 bucket we created
resource "aws_s3_object" "upload_zip" {
  bucket = aws_s3_bucket.lambda_s3_bucket.id
  key    = "function.zip"
  source = "function.zip"
}
