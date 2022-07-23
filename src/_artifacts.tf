resource "massdriver_artifact" "topic" {
  field                = "topic"
  provider_resource_id = aws_sns_topic.main.arn
  name                 = "AWS SNS Topic: ${aws_sns_topic.main.arn}"
  artifact = jsonencode(
    {
      data = {
        infrastructure = {
          arn = aws_sns_topic.main.arn
        }
      }
      specs = {
        aws = {
          region = var.topic.region
        }
      }
    }
  )
}
