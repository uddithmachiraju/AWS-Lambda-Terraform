locals {
  cors_origin    = var.cors_origin
  cors_headers   = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  cors_methods   = "'GET,POST,PUT,DELETE,OPTIONS,PATCH,HEAD'"

  cors_response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = local.cors_headers
    "method.response.header.Access-Control-Allow-Methods" = local.cors_methods
    "method.response.header.Access-Control-Allow-Origin"  = local.cors_origin
  }

  cors_method_response_parameters = {
    for k, _ in local.cors_response_parameters : k => true
  }
}

resource "aws_api_gateway_integration_response" "options_root_response" {
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  resource_id         = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method         = aws_api_gateway_method.options_root.http_method
  status_code         = "200"
  response_parameters = local.cors_response_parameters
}

resource "aws_api_gateway_method_response" "options_root_response" {
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  resource_id         = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method         = aws_api_gateway_method.options_root.http_method
  status_code         = "200"
  response_models     = { "application/json" = "Empty" }
  response_parameters = local.cors_method_response_parameters
}

# Same for proxy responses:
resource "aws_api_gateway_integration_response" "options_proxy_response" {
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  resource_id         = aws_api_gateway_resource.proxy_resource.id
  http_method         = aws_api_gateway_method.options_proxy.http_method
  status_code         = "200"
  response_parameters = local.cors_response_parameters
}

resource "aws_api_gateway_method_response" "options_proxy_response" {
  rest_api_id         = aws_api_gateway_rest_api.rest_api.id
  resource_id         = aws_api_gateway_resource.proxy_resource.id
  http_method         = aws_api_gateway_method.options_proxy.http_method
  status_code         = "200"
  response_models     = { "application/json" = "Empty" }
  response_parameters = local.cors_method_response_parameters
}
