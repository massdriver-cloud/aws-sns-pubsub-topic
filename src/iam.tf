
resource "aws_iam_policy" "publish" {
  name        = "${var.md_metadata.name_prefix}-publish"
  description = "SNS Pub/Sub publish policy: ${var.md_metadata.name_prefix}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sns:Publish"]
        Effect   = "Allow"
        Resource = aws_sns_topic.main.arn
      }
    ]
  })
}
