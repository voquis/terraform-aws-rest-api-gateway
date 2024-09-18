resource "aws_iam_role_policy_attachment" "log" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.log.arn
}
