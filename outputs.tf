# Account (for CloudWatch logging)
output "api_gateway_account" {
  value = aws_api_gateway_account.this
}

# Deployment
output "api_gateway_deployment" {
  value = aws_api_gateway_deployment.this
}

# REST API
output "api_gateway_rest_api" {
  value = aws_api_gateway_rest_api.this
}

# Stage
output "api_gateway_stage" {
  value = aws_api_gateway_stage.this
}

# Method settings (for CloudWatch logging)
output "api_gateway_method_settings" {
  value = aws_api_gateway_method_settings.this
}

# Lambda Permission
output "lambda_permission" {
  value = aws_lambda_permission.this
}

# IAM Policy
output "iam_policy_log" {
  value = aws_iam_policy.log
}

# IAM Role Policy Attachment
output "aws_iam_role_policy_attachment_log" {
  value = aws_iam_role_policy_attachment.log
}

# IAM Role
output "iam_role" {
  value = aws_iam_role.this
}
