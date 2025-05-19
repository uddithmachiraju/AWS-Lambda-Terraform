# generate a 4–6 digit random suffix, dividing by 2 to get the bytes (6 ÷ 2 = 3)
resource "random_id" "suffix" {
    byte_length = 3
}

locals {
    # if we want to take the substrings of the random number generated we can use the below.
    random_suffix      = substr(random_id.suffix.hex, 0, 6)
    bucket_name        = "${var.lambda_function_name}-s3-${local.random_suffix}"
    api_gateway_name   = "${var.lambda_function_name}-api-gateway" 
    iam_role_name      = "${var.lambda_function_name}-iam-role"
}
