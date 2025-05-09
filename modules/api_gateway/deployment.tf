resource "aws_api_gateway_deployment" "deployment" {
  depends_on  = [
    aws_api_gateway_integration.lambda_root, 
    aws_api_gateway_integration.lambda_proxy,
    aws_api_gateway_integration.options_root_mock,
    aws_api_gateway_integration.options_proxy_mock
    ]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = var.stage_name
}
