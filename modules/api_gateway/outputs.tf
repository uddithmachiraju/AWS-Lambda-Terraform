output "api_url" {
  value       = "https://${aws_api_gateway_rest_api.rest_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.stage_name}/"
  description = "API Gateway endpoint URL"
}
