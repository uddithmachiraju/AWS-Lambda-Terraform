locals {
  cors_headers = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS,PATCH,HEAD'"
    "method.response.header.Access-Control-Allow-Origin"  = var.allowed_origin
  }

  response_params_true = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_root_response" {
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  resource_id         = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method         = aws_api_gateway_method.options_root.http_method
  status_code         = "200"
  response_parameters = local.cors_headers

  depends_on = [aws_api_gateway_integration.options_root_mock]
}

resource "aws_api_gateway_method_response" "options_root_response" {
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  resource_id         = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method         = aws_api_gateway_method.options_root.http_method
  status_code         = "200"
  response_models     = { "application/json" = "Empty" }
  response_parameters = local.response_params_true

  depends_on = [aws_api_gateway_method.options_root]
}

resource "aws_api_gateway_integration_response" "options_proxy_response" {
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  resource_id         = aws_api_gateway_resource.proxy_resource.id
  http_method         = aws_api_gateway_method.options_proxy.http_method
  status_code         = "200"
  response_parameters = local.cors_headers

  depends_on = [aws_api_gateway_integration.options_proxy_mock]
}

resource "aws_api_gateway_method_response" "options_proxy_response" {
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  resource_id         = aws_api_gateway_resource.proxy_resource.id
  http_method         = aws_api_gateway_method.options_proxy.http_method
  status_code         = "200"
  response_models     = { "application/json" = "Empty" }
  response_parameters = local.response_params_true

  depends_on = [aws_api_gateway_method.options_proxy]
}
