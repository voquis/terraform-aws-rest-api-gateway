resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = var.method_setting_path

  settings {
    data_trace_enabled = var.method_settings_data_trace_enabled
    logging_level      = var.method_settings_logging_level
    metrics_enabled    = var.method_settings_metrics_enabled
  }
}
