resource "aws_api_gateway_rest_api" "this" {
  body              = var.rest_api_body
  name              = var.rest_api_name
  put_rest_api_mode = var.rest_api_put_rest_api_mode

  endpoint_configuration {
    types = var.rest_api_endpoint_configuration_types
  }
}
