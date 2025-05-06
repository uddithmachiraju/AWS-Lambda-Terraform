# Using aws 
provider "aws" {
    region = "us-east-1"
}

# Create S3 Bucket to store our files
resource "aws_s3_bucket" "lambda_s3_bucket" {
    bucket = "my-lambda-bucket-sanjay"
}

# Upload our 'function.zip' in the s3 bucket we created
resource "aws_s3_object" "upload_zip" {
    bucket = aws_s3_bucket.lambda_s3_bucket.id
    key = "function.zip"
    source = "function.zip" 
}

# Creating a IAM role for Lambda 
resource "aws_iam_role" "lambda_role" {
    name = "lambda_execution_role"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })
}

# Attaching the permissions to the IAM Role we created (As of now only basic logging ploicy was given)
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name 
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Creating a Lambda Function
resource "aws_lambda_function" "my_lambda" {
  function_name = "MyFunction"

  s3_bucket = aws_s3_bucket.lambda_s3_bucket.id
  s3_key    = aws_s3_object.upload_zip.key

  handler = "bootstrap"
  runtime = "provided.al2023"
  role    = aws_iam_role.lambda_role.arn

  memory_size = 256
  timeout     = 15

  source_code_hash = filebase64sha256("function.zip") # Everytime the "function.zip" is changed automatically deploy it
}
