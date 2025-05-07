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
    bucket  = aws_s3_bucket.lambda_s3_bucket.id
    key     = "function.zip"
    source  = "function.zip" 
}

# Creating a IAM role for Lambda 
resource "aws_iam_role" "lambda_role" {
    name = "lambda_execution_role"
    assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
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

  # Adding Environment variables to Lambda
  environment {
    variables = {
      LAMBDA = var.lambda_env
    }
  }

  source_code_hash = filebase64sha256("function.zip") # Everytime the "function.zip" is changed automatically deploy it
}

# Adding API Gateway 
resource "aws_apigatewayv2_api" "http_api" {
  name          = "NimbusApiGateway" 
  protocol_type = "HTTP" 

  # Cross Origin Resource Sharing config
  cors_configuration {
    allow_origins     = ["https://prod.d2nr02lclk5abd.amplifyapp.com"]
    allow_methods     = ["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"]
    allow_headers     = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key", "X-Amz-Security-Token"]
    allow_credentials = true 
  }
}

# We need to give the lambda permissions to allow the ApiGateway to run it(invoke) SAM will do it in backend 
resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke" 
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name 
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# Connect the Gateway to Lambda 
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.my_lambda.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# API Gateway route for root 
resource "aws_apigatewayv2_route" "root_route" {
  api_id    = aws_apigatewayv2_api.http_api.id 
  route_key = "ANY /" 
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# API Gateway route for all other routes 
resource "aws_apigatewayv2_route" "all_routes" {
  api_id    = aws_apigatewayv2_api.http_api.id 
  route_key = "ANY /{proxy+}" 
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Adding Gateway stage 
resource "aws_apigatewayv2_stage" "prod_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id 
  name        = "Prod" 
  auto_deploy = true
}

# 11. Outputs
output "api_url" {
  description = "API Gateway endpoint URL for your nimbus application"
  value       = aws_apigatewayv2_stage.prod_stage.invoke_url
}