provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region     = var.AWS_REGION
}

# ECR Definition for the ETL Pipeline
data "aws_ecr_repository" "c15-incitatus-etl-pipeline-ecr" {
  name = "c15-incitatus-etl-pipeline-ecr"
}

data "aws_ecr_image" "latest_pipeline_image" {
  repository_name = data.aws_ecr_repository.c15-incitatus-etl-pipeline-ecr.name
  most_recent     = true
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_task_role" {
  name = "c15-incitatus-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Principal = { Service = "lambda.amazonaws.com" },
        Effect    = "Allow"
      }
    ]
  })
}

data "aws_iam_policy_document" "lambda_permissions_role" {
  statement {
    effect  = "Allow"
    actions = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:eu-west-2:${var.ACCOUNT_NUMBER}:*"]
  }
}

resource "aws_iam_policy" "lambda_permissions" {
  name   = "c15-incitatus-lambda-log-role"
  policy = data.aws_iam_policy_document.lambda_permissions_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_execution_role" {
  role       = aws_iam_role.lambda_task_role.name
  policy_arn = aws_iam_policy.lambda_permissions.arn
}

# Lambda Function for ETL Pipeline
resource "aws_lambda_function" "c15-incitatus-etl-pipeline-lambda-function" {
  function_name = "c15-incitatus-etl-pipeline-lambda-function"
  package_type  = "Image"
  image_uri     = data.aws_ecr_image.latest_pipeline_image.image_uri
  memory_size   = 128
  timeout       = 35

  environment {
    variables = {
      DB_HOST      = var.DB_HOST
      DB_NAME      = var.DB_NAME
      DB_PASSWORD  = var.DB_PASSWORD
      DB_PORT      = var.DB_PORT
      DB_USER      = var.DB_USER
      SCHEMA_NAME  = var.SCHEMA_NAME
    }
  }

  role = aws_iam_role.lambda_task_role.arn
}

# IAM Role for Step Function
resource "aws_iam_role" "state_role" {
  name = "c15-incitatus-state-machine"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "states.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "state_machine_lambda_policy" {
  name   = "c15-incitatus-state-machine-lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "lambda:InvokeFunction",
        Resource = [aws_lambda_function.c15-incitatus-etl-pipeline-lambda-function.arn,
        aws_lambda_function.c15-incitatus-plant-reading-lambda-function.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "state_role_lambda" {
  role       = aws_iam_role.state_role.name
  policy_arn = aws_iam_policy.state_machine_lambda_policy.arn
}

data "aws_ses_email_identity" "aren_email" {
  email = var.AREN_EMAIL 
}

data "aws_ses_email_identity" "joana_email" {
  email = var.JOANA_EMAIL 
}

data "aws_ses_email_identity" "rob_email" {
  email = var.ROB_EMAIL 
}

data "aws_ses_email_identity" "abdi_email" {
  email = var.ABDI_EMAIL 
}

resource "aws_iam_policy" "state_machine_ses_policy" {
  name        = "c15-aren-state-machine-ses-policy"
  description = "Allows Step Function to send emails using SES"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ],
        Resource = [data.aws_ses_email_identity.aren_email.arn, 
        data.aws_ses_email_identity.joana_email.arn, 
        data.aws_ses_email_identity.rob_email.arn,
        data.aws_ses_email_identity.abdi_email.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "state_role_ses" {
  role       = aws_iam_role.state_role.name
  policy_arn = aws_iam_policy.state_machine_ses_policy.arn
}

# CloudWatch Log Group for Step Function
resource "aws_cloudwatch_log_group" "incitatus_state_machine_logs" {
  name = "/aws/vendedlogs/states/incitatus-state-machine-logs"
}

resource "aws_iam_role_policy_attachment" "state_machine_cw_logs" {
  role       = aws_iam_role.state_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# Step Function - Calls both lambdas and SES now
resource "aws_sfn_state_machine" "incitatus_state_machine" {
  name     = "c15-incitatus-state-machine"
  role_arn = aws_iam_role.state_role.arn
  publish  = true
  type     = "EXPRESS"

  definition = jsonencode({
    "Comment": "Step Function to invoke two Lambdas and SES",
    "StartAt": "Invoke ETL Lambda",
    "States": {
      "Invoke ETL Lambda": {
        "Type": "Task",
        "Resource": "arn:aws:states:::lambda:invoke",
        "Parameters": {
          "FunctionName": aws_lambda_function.c15-incitatus-etl-pipeline-lambda-function.arn,
          "Payload.$": "$"
        },
        "Retry": [
          {
            "ErrorEquals": [
              "Lambda.ServiceException",
              "Lambda.AWSLambdaException",
              "Lambda.SdkClientException",
              "Lambda.TooManyRequestsException"
            ],
            "IntervalSeconds": 1,
            "MaxAttempts": 3,
            "BackoffRate": 2,
            "JitterStrategy": "FULL"
          }
        ],
        "Next": "Invoke Plant Reading Lambda"
      },
      "Invoke Plant Reading Lambda": {
        "Type": "Task",
        "Resource": "arn:aws:states:::lambda:invoke",
        "Parameters": {
          "FunctionName": aws_lambda_function.c15-incitatus-plant-reading-lambda-function.arn,
          "Payload.$": "$"
        },
        "Retry": [
          {
            "ErrorEquals": [
              "Lambda.ServiceException",
              "Lambda.AWSLambdaException",
              "Lambda.SdkClientException",
              "Lambda.TooManyRequestsException"
            ],
            "IntervalSeconds": 1,
            "MaxAttempts": 3,
            "BackoffRate": 2,
            "JitterStrategy": "FULL"
          }
        ],
        "ResultPath": "$", 
        "Next": "CheckPayload"
      },
      "CheckPayload": {
        "Type": "Choice",
        "Choices": [
          {
            "Variable": "$.Payload.shouldSendEmail",
            "BooleanEquals": true,
            "Next": "SendEmail"
          }
        ],
        "Default": "EndState"
      },
      "SendEmail": {
        "Type": "Task",
        "Resource": "arn:aws:states:::aws-sdk:sesv2:sendEmail",
        "Parameters": {
          "Content": {
            "Simple": {
              "Body": {
                "Html": {
                  "Data.$": "$.Payload.body"
                }
              },
              "Subject": {
                "Data": "ALERT"
              }
            }
          },
          "Destination": {
            "ToAddresses": ["${var.AREN_EMAIL}", "${var.JOANA_EMAIL}", "${var.ROB_EMAIL}", "${var.ABDI_EMAIL}"]
          },
          "FeedbackForwardingEmailAddress": "${var.AREN_EMAIL}",
          "FromEmailAddress": "${var.AREN_EMAIL}"
        },
        "End": true
      },
      "EndState": {
        "Type": "Succeed"
      }
    }
  })

  logging_configuration {
    log_destination       = "${aws_cloudwatch_log_group.incitatus_state_machine_logs.arn}:*"
    include_execution_data = true
    level                 = "ALL"
  }
}

# IAM Role for Scheduler
resource "aws_iam_role" "report_scheduler_role" {
  name = "c15-incitatus-state-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "scheduler.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "scheduler_role_step" {
  role       = aws_iam_role.report_scheduler_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
}

# EventBridge Scheduler to run Step Function every minute
resource "aws_scheduler_schedule" "report_schedule" {
  name                  = "c15-incitatus-state-machine-scheduler"
  schedule_expression   = "rate(1 minute)"  # Runs every minute
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn      = aws_sfn_state_machine.incitatus_state_machine.arn
    role_arn = aws_iam_role.report_scheduler_role.arn
  }
}