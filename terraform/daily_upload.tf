

# ECR Definition for Daily Uploading

resource "aws_ecr_repository" "c15-incitatus-daily-upload-ecr" {
  name = ""
}

# Lambda Function for Daily Uploading

resource "aws_lambda_function" "c15-incitatus-daily-upload-lambda-function" {
  role = ""
  function_name = ""
}

# EventBridge Scheduler to run daily

resource "aws_scheduler_schedule" "c15-incitatus-daily-upload-schedule" {
  schedule_expression = "rate(1 day)"
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn      = ""
    role_arn = ""
  }
}