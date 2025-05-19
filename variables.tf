# AWS Region
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

# S3 Bucket Name
# variable "s3_bucket_name" {
#   description = "The name of the S3 bucket to store function.zip"
#   type        = string
# }

variable "lambda_env" {
    description = "Indicates if running in Lambda environment"
    type = string 
    default = "true" 
}

# Lambda Function Name
variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
  default     = "nimbus-lambda-func"
}

# variable "api_name" {
#   type = string
#   default = local.api_gateway_name
# }

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