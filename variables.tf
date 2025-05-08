# AWS Region
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "lambda_env" {
    description = "Indicates if running in Lambda environment"
    type = string 
    default = "true" 
}

# S3 Bucket Name
variable "s3_bucket_name" {
  description = "The name of the S3 bucket to store function.zip"
  type        = string
  default     = "my-lambda-bucket-sanjay"
}

# Lambda Function Name
variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
  default     = "MyFunction"
}
