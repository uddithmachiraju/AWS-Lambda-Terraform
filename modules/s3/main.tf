# CREATE S3 BUCKET IF NOT EXISTS
resource "aws_s3_bucket" "lambda_s3_bucket" {
  bucket = var.bucket_name

  # This avoids accidental deletion
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# UPLOAD FUNCTION.ZIP ONLY WHEN IT CHANGES 
resource "aws_s3_object" "upload_zip" {
  bucket = aws_s3_bucket.lambda_s3_bucket.id
  key    = "function.zip"
  source = "function.zip"
  etag   = filemd5("function.zip")  # Only triggers upload if ZIP changes
}