# Creating a Lambda Function
resource "aws_lambda_function" "my_lambda" {
  function_name = var.lambda_function_name
  description   = "Lambda function to deploy a Nimbus app with environment variable and integrated via REST API Gateway"

  s3_bucket = var.bucket
  s3_key    = var.zip_key
  handler   = "bootstrap"
  runtime   = "provided.al2023"
  role      = var.role_arn

  memory_size = 256
  timeout     = 15

  environment {
    variables = {
      LAMBDA = var.lambda_env
    }
  }

  # Everytime the "function.zip" is changed automatically deploy it
  source_code_hash = filebase64sha256("function.zip")
}
