resource "aws_iam_policy" "log" {
  name        = var.iam_policy_log_name
  description = "Allows REST API Gateway to log to CloudWatch"
  policy      = data.aws_iam_policy_document.log.json
}
