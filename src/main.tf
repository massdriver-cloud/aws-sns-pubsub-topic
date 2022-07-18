data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  sns_topic_name = var.topic.fifo ? "${var.md_metadata.name_prefix}.fifo" : var.md_metadata.name_prefix
}

resource "aws_sns_topic" "main" {
  name         = local.sns_topic_name
  display_name = coalesce(lookup(var.topic, "display_name", null), var.md_metadata.name_prefix)
  fifo_topic   = var.topic.fifo

  # TODO: set to false if FIFO is false, should be conditional in UI
  content_based_deduplication = var.topic.fifo ? var.topic.content_based_deduplication : false

  application_failure_feedback_role_arn = aws_iam_role.feedback.arn
  application_success_feedback_role_arn = null

  firehose_failure_feedback_role_arn = aws_iam_role.feedback.arn
  firehose_success_feedback_role_arn = null

  http_failure_feedback_role_arn = aws_iam_role.feedback.arn
  http_success_feedback_role_arn = null

  lambda_failure_feedback_role_arn = aws_iam_role.feedback.arn
  lambda_success_feedback_role_arn = null

  sqs_failure_feedback_role_arn = aws_iam_role.feedback.arn
  sqs_success_feedback_role_arn = null
}

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
