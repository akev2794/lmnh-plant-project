provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region = var.AWS_REGION
}


# ECR Definition for the ETL Pipeline

resource "aws_ecr_repository" "c15-incitatus-etl-pipeline-ecr" {
  name = "c15-incitatus-etl-pipeline-ecr"
}

# Lambda Function to run the ETL Pipeline

resource "aws_lambda_function" "c15-incitatus-etl-pipeline-lambda-function" {
  role = ""
  function_name = ""
}

# EventBridge Scheduler to run every minute

resource "aws_scheduler_schedule" "c15-incitatus-etl-pipeline-schedule" {
  schedule_expression = "rate(1 minute)"
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn      = ""
    role_arn = ""
  }
}