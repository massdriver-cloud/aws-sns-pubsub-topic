locals {
  automated_alarms = {
    failed_notifications = {
      period    = 300
      threshold = 1
      statistic = "Sum"
    }
  }
  alarms_map = {
    "AUTOMATED" = local.automated_alarms
    "DISABLED"  = {}
    "CUSTOM"    = lookup(var.monitoring, "alarms", {})
  }

  alarms = lookup(local.alarms_map, var.monitoring.mode, {})
}

module "alarm_channel" {
  source      = "github.com/massdriver-cloud/terraform-modules//aws-alarm-channel?ref=aa08797"
  md_metadata = var.md_metadata
}

module "failed_notifications_alarm" {
  count = lookup(local.alarms, "failed_notifications", null) == null ? 0 : 1

  source        = "github.com/massdriver-cloud/terraform-modules//aws-cloudwatch-alarm?ref=8997456"
  sns_topic_arn = module.alarm_channel.arn
  depends_on = [
    aws_sns_topic.main
  ]

  md_metadata         = var.md_metadata
  display_name        = "Failed Notifications"
  message             = "SNS Topic ${aws_sns_topic.main.name}: has failed to deliver messages"
  alarm_name          = "${aws_sns_topic.main.name}-numberOfNotificationsFailed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "NumberOfNotificationsFailed"
  namespace           = "AWS/SNS"
  statistic           = local.alarms.failed_notifications.statistic
  period              = local.alarms.failed_notifications.period
  threshold           = local.alarms.failed_notifications.threshold

  dimensions = {
    TopicName = aws_sns_topic.main.name
  }
}
