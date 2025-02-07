# ECR Definition for Daily Uploading
data "aws_ecr_repository" "c15-incitatus-daily-upload-ecr" {
  name = "c15-incitatus-daily-upload-ecr"
}

data "aws_ecr_image" "latest_upload_archive_image" {
  repository_name = data.aws_ecr_repository.c15-incitatus-daily-upload-ecr.name
  most_recent     = true
}

# Lambda Function for Daily Uploading
resource "aws_lambda_function" "c15-incitatus-daily-upload-lambda-function" {
  function_name = "c15-incitatus-daily-upload-lambda-function"
  package_type  = "Image"
  image_uri     = data.aws_ecr_image.latest_upload_archive_image.image_uri
  memory_size   = 128
  timeout       = 120
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

# EventBridge Scheduler to run daily
# IAM Role for Scheduler
resource "aws_iam_role" "archive_scheduler_role" {
  name = "c15-incitatus-archive-scheduler-role"

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

resource "aws_iam_role_policy_attachment" "scheduler_role_lambda" {
  role       = aws_iam_role.archive_scheduler_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

resource "aws_scheduler_schedule" "c15-incitatus-daily-upload-schedule" {
  name = "c15-incitatus-daily-upload-scheduler"
  schedule_expression = "cron(1 0 * * ? *)"
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn      = aws_lambda_function.c15-incitatus-daily-upload-lambda-function.arn
    role_arn = aws_iam_role.archive_scheduler_role.arn
  }
}