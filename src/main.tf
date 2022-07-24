locals {
  sns_topic_name = var.topic.fifo ? "${var.md_metadata.name_prefix}.fifo" : var.md_metadata.name_prefix
}

resource "aws_sns_topic" "main" {
  name                        = local.sns_topic_name
  display_name                = var.md_metadata.name_prefix
  fifo_topic                  = var.topic.fifo
  content_based_deduplication = var.topic.fifo ? var.topic.content_based_deduplication : false
  kms_master_key_id           = "alias/aws/sns"

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
