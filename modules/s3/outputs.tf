output "bucket" {
  value = aws_s3_bucket.lambda_s3_bucket.id  # Replace with your actual resource name
}

output "zip_key" {
  value = aws_s3_object.upload_zip.key  # Replace with your actual resource name
}
