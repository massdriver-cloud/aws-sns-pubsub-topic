data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

// SNS subscriber endpoint feedback
resource "aws_iam_policy" "feedback" {
  name        = "${var.md_metadata.name_prefix}-sns-subscriber-feedback"
  description = "Subscriber delivery status logging for ${var.md_metadata.name_prefix}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:PutMetricFilter",
          "logs:PutRetentionPolicy"
        ],
        "Resource" : [
          format(
            "arn:%s:logs:%s:%s:log-group:sns/%s/%s/%s:*",
            data.aws_partition.current.partition,
            data.aws_region.current.name,
            data.aws_caller_identity.current.account_id,
            data.aws_region.current.name,
            data.aws_caller_identity.current.account_id,
            aws_sns_topic.main.name
          )
        ]
      }
    ]
  })
}

resource "aws_iam_role" "feedback" {
  name = "${var.md_metadata.name_prefix}-sns-subscriber-feedback"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "sns.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "feedback" {
  role       = aws_iam_role.feedback.name
  policy_arn = aws_iam_policy.feedback.arn
}
