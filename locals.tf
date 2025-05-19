# generate a 4–6 digit random suffix, dividing by 2 to get the bytes (6 ÷ 2 = 3)
resource "random_id" "suffix" {
    byte_length = 3
}

locals {
    # taking only the first 4 characters of the hex string for a 4-digit suffix, or full 6 if you want up to 6 characters
    random_suffix      = substr(random_id.suffix.hex, 0, 6)
    bucket_name        = "${var.lambda_function_name}-s3-${local.random_suffix}"
    api_gateway_name   = "${var.lambda_function_name}-api-gateway"
}
