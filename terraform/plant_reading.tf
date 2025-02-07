

# # ECR Definition for the plant readings
data "aws_ecr_repository" "c15-incitatus-plant-reading-ecr" {
  name = "c15-incitatus-plant-reading-ecr"
}

data "aws_ecr_image" "latest_plant_reading_image" {
  repository_name = data.aws_ecr_repository.c15-incitatus-plant-reading-ecr.name
  most_recent     = true
}

# # Lambda Function for the plant readings
resource "aws_lambda_function" "c15-incitatus-plant-reading-lambda-function" {
  function_name = "c15-incitatus-plant-reading-lambda-function"
  package_type  = "Image"
  image_uri     = data.aws_ecr_image.latest_plant_reading_image.image_uri
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