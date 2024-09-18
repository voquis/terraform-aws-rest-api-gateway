# Resource to enable API Gateway to log to cloudwatch
resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.this.arn
}
