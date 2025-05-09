resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method             = aws_api_gateway_method.any_root.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

resource "aws_api_gateway_integration" "lambda_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.proxy_resource.id
  http_method             = aws_api_gateway_method.any_proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

resource "aws_api_gateway_integration" "options_root_mock" {
  rest_api_id       = aws_api_gateway_rest_api.rest_api.id
  resource_id       = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method       = "OPTIONS"
  type              = "MOCK"
  request_templates = { "application/json" = "{\"statusCode\": 200}" }
}

resource "aws_api_gateway_integration" "options_proxy_mock" {
  rest_api_id       = aws_api_gateway_rest_api.rest_api.id
  resource_id       = aws_api_gateway_resource.proxy_resource.id
  http_method       = "OPTIONS"
  type              = "MOCK"
  request_templates = { "application/json" = "{\"statusCode\": 200}" }
}
