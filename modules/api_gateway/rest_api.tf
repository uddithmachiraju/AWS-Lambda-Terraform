# Creating the REST API 
resource "aws_api_gateway_rest_api" "rest_api" {
  name        = var.api_name
  description = var.api_description
} 

