# AWS Simple Notification Service (SNS)

AWS Simple Notification Service (SNS) is a fully managed messaging service that enables you to decouple microservices, distributed systems, and serverless applications. It provides a highly durable, secure, and fully managed pub/sub messaging system to simplify communication between applications and microservices. SNS allows you to fan-out messages to a large number of subscribers, including Amazon SQS queues, AWS Lambda functions, and HTTP/S endpoints.

## Design Decisions

This module is designed to create and manage AWS SNS topics, along with necessary IAM roles and policies for security and monitoring purposes. Here are some key design decisions:

- **SNS Topic Creation**: The module supports the creation of both standard and FIFO SNS topics. For FIFO topics, content-based deduplication can be enabled.
- **IAM Policies & Roles**: The module generates IAM policies for publishing to the SNS topic and for logging delivery feedback to CloudWatch Logs.
- **Monitoring**: The module includes configuration for CloudWatch Alarms to monitor failed message deliveries, helping to ensure that issues are quickly identified and addressed.
- **KMS Encryption**: The SNS topic data is encrypted at rest using AWS-managed keys by default.
- **Feedback Mechanisms**: IAM roles and policies are created to log successful or failed deliveries to integrate with CloudWatch Logs, aiding in monitoring and troubleshooting.

## Helpful Links

* [AWS Pub/Sub Pattern](https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-integrating-microservices/pub-sub.html)
* [SNS FAQs](https://aws.amazon.com/sns/faqs/#:~:text=FIFO%20topics)
* [Delivery policies](https://docs.aws.amazon.com/sns/latest/dg/sns-message-delivery-retries.html)
* [Example IAM policies](https://docs.aws.amazon.com/sns/latest/dg/sns-access-policy-use-cases.html)

## Runbook

### Troubleshooting SNS Message Delivery Failures

Occasionally, you may encounter issues with message delivery failures. The following steps can help identify and resolve these issues.

#### Check CloudWatch Logs

SNS can log delivery attempts to CloudWatch Logs. To check for errors in delivery:

1. **Navigate to CloudWatch Logs in the AWS Management Console**.
2. **Locate the log group**: The log group will typically follow the format: `sns/REGION/ACCOUNT-ID/SNS-TOPIC-NAME`.
3. **Examine the log streams**: Look for any error messages or failed delivery attempts.

#### Using AWS CLI

To list the CloudWatch log groups:

```sh
aws logs describe-log-groups --log-group-name-prefix "/aws/sns"
```

To get the details of log streams for a specific log group:

```sh
aws logs describe-log-streams --log-group-name "sns/REGION/ACCOUNT-ID/SNS-TOPIC-NAME"
```

To fetch log events for a specific stream:

```sh
aws logs get-log-events --log-group-name "sns/REGION/ACCOUNT-ID/SNS-TOPIC-NAME" --log-stream-name "log-stream-id"
```

#### Check SNS Topic Attributes

Verify the status and configuration of the SNS topic:

```sh
aws sns get-topic-attributes --topic-arn "arn:aws:sns:REGION:ACCOUNT-ID:SNS-TOPIC-NAME"
```

This command returns details about the topic including configuration and any potential misconfigurations.

#### Inspect IAM Policies

Ensure that the necessary IAM roles and policies are correctly attached and have the required permissions:

- **IAM Role for SNS Feedback**:

```sh
aws iam get-role --role-name "ROLE-NAME-FOR-SNS-FEEDBACK"
```

- **IAM Policies**:

List attached policies for a particular role:

```sh
aws iam list-attached-role-policies --role-name "ROLE-NAME-FOR-SNS-FEEDBACK"
```

Check the policy document:

```sh
aws iam get-policy --policy-arn "arn:aws:iam::ACCOUNT-ID:policy/POLICY-NAME"
aws iam get-policy-version --policy-arn "arn:aws:iam::ACCOUNT-ID:policy/POLICY-NAME" --version-id "VERSION-ID"
```

#### Monitor CloudWatch Alarms

Ensure CloudWatch Alarms for failed notifications are properly set:

```sh
aws cloudwatch describe-alarms --alarm-names "SNS-TOPIC-NAME-numberOfNotificationsFailed"
```

This command will provide the alarm details including status. 

By following these steps, you can pinpoint and resolve common issues with AWS SNS message delivery.

