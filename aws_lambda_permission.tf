resource "aws_lambda_permission" "this" {
  for_each = toset(var.lambdas_to_invoke_names)

  action        = "lambda:InvokeFunction"
  function_name = each.value
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*"
}
