provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region = var.AWS_REGION
}


# ECR Definition for the ETL Pipeline

data "aws_ecr_repository" "c15-incitatus-etl-pipeline-ecr" {
  name = "c15-incitatus-etl-pipeline-ecr"
}

data "aws_ecr_image" "latest_pipeline_image" {
  repository_name = data.aws_ecr_repository.c15-incitatus-etl-pipeline-ecr.name
  most_recent = true
}

# IAM role for the Lambda Function

resource "aws_iam_role" "lambda_task_role" {
  name = "c15-incitatus-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

# Lambda Function to run the ETL Pipeline

resource "aws_lambda_function" "c15-incitatus-etl-pipeline-lambda-function" {
  function_name = "c15-incitatus-etl-pipeline-lambda-function"
  package_type = "Image"
  image_uri = data.aws_ecr_image.latest_pipeline_image.image_uri
  memory_size = 128
  timeout = 3
  environment {
    variables = {
      DB_HOST = var.DB_HOST
      DB_NAME = var.DB_NAME
      DB_PASSWORD = var.DB_PASSWORD
      DB_PORT = var.DB_PORT
      DB_USER = var.DB_USER
      SCHEMA_NAME = var.SCHEMA_NAME
    }
  }
  role = aws_iam_role.lambda_task_role.arn
}

# EventBridge Scheduler to run every minute

resource "aws_scheduler_schedule" "c15-incitatus-etl-pipeline-schedule" {
  name = "c15-incitatus-etl-pipeline-scheduler"
  description = "Runs the ETL pipeline script from a Lambda Function every minute"
  schedule_expression = "rate(1 minute)"
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn      = ""
    role_arn = ""
  }
}