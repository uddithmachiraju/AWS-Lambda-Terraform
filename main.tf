provider "aws" {
  region = var.aws_region
}

module "s3" {
  source       = "./modules/s3"
  bucket_name  = local.bucket_name
}

module "iam" {
  source   = "./modules/iam"
  iam_role = local.iam_role_name
}

module "lambda" {
  source               = "./modules/lambda"
  lambda_function_name = var.lambda_function_name
  lambda_env           = var.lambda_env
  bucket               = module.s3.bucket
  zip_key              = module.s3.zip_key
  role_arn             = module.iam.role_arn
}

module "api_gateway" {
  source                = "./modules/api_gateway"
  api_gateway_name      = local.api_gateway_name
  api_description       = var.api_description
  lambda_invoke_arn     = module.lambda.lambda_invoke_arn
  lambda_function_name  = module.lambda.lambda_function_name
  allowed_origin        = var.allowed_origin
  stage_name            = var.stage_name
  aws_region            = var.aws_region
}
