variable "lambda_function_name" {
  type = string
}
variable "lambda_env" {
  type = string
  default = "true" 
}
variable "bucket" {
  type = string
}
variable "zip_key" {
  type = string
}
variable "role_arn" {
  type = string
}
