# AWS Region
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

# S3 Bucket Name
variable "s3_bucket_name" {
  description = "The name of the S3 bucket to store function.zip"
  type        = string
  default     = "my-lambda-bucket-test-27"
}

variable "lambda_env" {
    description = "Indicates if running in Lambda environment"
    type = string 
    default = "true" 
}

# Lambda Function Name
variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
  default     = "MyFunction"
}

variable "api_name" {
  type = string
  default = "NimbusAPI"
}

variable "api_description" {
  type = string
  default = "Numbus app API gateway" 
}

variable "allowed_origin" {
  type    = string
  default = "'https://prod.d2nr02lclk5abd.amplifyapp.com'"
}

variable "stage_name" {
  type    = string
  default = "Prod" 
}