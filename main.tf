# Using aws 
provider "aws" {
    region = var.aws_region
}

# Create S3 Bucket to store our files
resource "aws_s3_bucket" "lambda_s3_bucket" {
    bucket = var.s3_bucket_name
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
  description   = "Lambda function to deploy a Nimbus app with environment variable and integrated via REST API Gateway" 
  function_name = var.lambda_function_name

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

# Creating the REST API 
resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "NimbusRestApi"
  description = "API Gateway REST for Lambda integration"
}

# Creating a dynamic path - /{proxy+} - Catches all routes and sends them to lambda 
resource "aws_api_gateway_resource" "proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "{proxy+}"
}

# This sets up the root endpoint "/" to accept ANY HTTP method like (post, get, put, etc.)
resource "aws_api_gateway_method" "any_root" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

# Creating a HTTP method on root path (enabling CORS for our API) 
resource "aws_api_gateway_method" "options_root" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# similar to above allowing ANY HTTP Method to proxy endpoint 
resource "aws_api_gateway_method" "any_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.proxy_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

# Creating a HTTP method on proxy path (enabling CORS for our API) 
resource "aws_api_gateway_method" "options_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.proxy_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Linking the lambda with the API we created to root endpoint
resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method             = aws_api_gateway_method.any_root.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.my_lambda.invoke_arn
}

# Linking the lambda with the API we created to "option"
resource "aws_api_gateway_integration" "options_root_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method             = "OPTIONS"
  type                    = "MOCK"
  request_templates       = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# similar to above linking the lambda with proxy endpoint
resource "aws_api_gateway_integration" "lambda_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.proxy_resource.id
  http_method             = aws_api_gateway_method.any_proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.my_lambda.invoke_arn
}

# similar to above linking the lambda with options 
resource "aws_api_gateway_integration" "options_proxy_integration" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.proxy_resource.id
  http_method = "OPTIONS"
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Allowing API Gateway to Invoke(run) Lambda - SAM does this by default
resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*"
}

# this below code is to set up CORS (Cross-Origin Resource Sharing) support for both the root (/) and proxy (/{proxy+}) paths of our API Gateway.

# this implements the response returned when an OPTIONS request hits the root (/).
resource "aws_api_gateway_integration_response" "options_root_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method = aws_api_gateway_method.options_root.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS,PATCH,HEAD'"
    "method.response.header.Access-Control-Allow-Origin"  = "'https://prod.d2nr02lclk5abd.amplifyapp.com'"
  }
}

# this declares that the root OPTIONS method can return those headers with a 200 OK.
resource "aws_api_gateway_method_response" "options_root_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method = aws_api_gateway_method.options_root.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# this mplements the response for the route /{proxy+}. 
resource "aws_api_gateway_integration_response" "options_proxy_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.proxy_resource.id
  http_method = aws_api_gateway_method.options_proxy.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS,PATCH,HEAD'"
    "method.response.header.Access-Control-Allow-Origin"  = "'https://prod.d2nr02lclk5abd.amplifyapp.com'"
  }
}

# Declares those headers and the 200 status for the OPTIONS method on the proxy route.
resource "aws_api_gateway_method_response" "options_proxy_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.proxy_resource.id
  http_method = aws_api_gateway_method.options_proxy.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# Publish/Deploy the API to use for our application
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_root,
    aws_api_gateway_integration.lambda_proxy,
    aws_api_gateway_integration.options_root_integration,
    aws_api_gateway_integration.options_proxy_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = "Prod"
}

# Outputs
output "api_url" {
  value = "https://${aws_api_gateway_rest_api.rest_api.id}.execute-api.${var.aws_region}.amazonaws.com/Prod/"
  description = "API Gateway endpoint URL for your nimbus application"
}
