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
        Resource = aws_lambda_function.c15-incitatus-etl-pipeline-lambda-function.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "state_role_lambda" {
  role       = aws_iam_role.state_role.name
  policy_arn = aws_iam_policy.state_machine_lambda_policy.arn
}

# CloudWatch Log Group for Step Function
resource "aws_cloudwatch_log_group" "incitatus_state_machine_logs" {
  name = "/aws/vendedlogs/states/incitatus-state-machine-logs"
}

resource "aws_iam_role_policy_attachment" "state_machine_cw_logs" {
  role       = aws_iam_role.state_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# Step Function - Only Calls Pipeline Lambda for now
resource "aws_sfn_state_machine" "incitatus_state_machine" {
  name     = "c15-incitatus-state-machine"
  role_arn = aws_iam_role.state_role.arn
  type     = "EXPRESS"

  definition = jsonencode({
    Comment = "Step Function to invoke Lambda",
    StartAt = "Invoke Lambda",
    States = {
      "Invoke Lambda" = {
        Type       = "Task",
        Resource   = "arn:aws:states:::lambda:invoke",
        Parameters = {
          FunctionName = aws_lambda_function.c15-incitatus-etl-pipeline-lambda-function.arn
        },
        End = true
      }
    }
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.incitatus_state_machine_logs.arn}:*"
    include_execution_data = true
    level                  = "ALL"
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