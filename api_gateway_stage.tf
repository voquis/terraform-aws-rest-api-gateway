resource "aws_api_gateway_stage" "this" {
  deployment_id        = aws_api_gateway_deployment.this.id
  rest_api_id          = aws_api_gateway_rest_api.this.id
  stage_name           = var.stage_name
  xray_tracing_enabled = var.stage_xray_tracing_enabled
}
