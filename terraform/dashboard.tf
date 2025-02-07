

# # ECS Task Definition to run the dashboard

# resource "aws_ecs_task_definition" "c15-incitatus-dashboard-task-definition" {
#     family = ""
#     container_definitions = jsonencode([{

#     }])
# }

# Steps to Create Task Definition
data "aws_vpc" "c15_vpc" {
    id = var.AWS_VPC_ID
}

data "aws_iam_role" "ecs_service_execution_role" {
    name = "ecsServiceExecutionRole"
}

data "aws_ecr_repository" "dashboard_repo" {
  name = "c15-incitatus-dashboard-ecr"
}

data "aws_ecr_image" "latest_dashboard_image" {
  repository_name = data.aws_ecr_repository.dashboard_repo.name
  most_recent     = true
}

resource "aws_ecs_task_definition" "task_def" {
    family                   = "c15-aren-t3-pipeline-taskdef"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = "256"
    memory                   = "512"
    execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn

    container_definitions = jsonencode([{
    name      = "c15-incitatus-dashboard-taskdef"
    image     = data.aws_ecr_image.latest_pipeline_image.image_uri
    cpu       = 256
    memory    = 512
    essential = true

    portMappings = [
        {
        containerPort = 80
        hostPort      = 80
        protocol      = "tcp"
        },
        {
        containerPort = 443
        hostPort      = 443
        protocol      = "tcp"
        },
        {
        containerPort = 3306
        hostPort      = 3306
        protocol      = "tcp"
        }
    ]
    logConfiguration = {
        logDriver = "awslogs"
        options = {
        "awslogs-group"         = "/ecs/15-aren-t3-pipeline-taskdef"
        "awslogs-region"        = var.AWS_REGION
        "awslogs-stream-prefix" = "ecs"
        "awslogs-create-group" = "true"
        }
    }
    environment = [
      {
        name  = "AWS_ACCESS_KEY"
        value = var.AWS_ACCESS_KEY
      },
      {
        name  = "AWS_SECRET_ACCESS_KEY"
        value = var.AWS_SECRET_ACCESS_KEY
      },
      {
        name  = "AWS_BUCKET"
        value = var.AWS_BUCKET
      },
      {
        name  = "DB_HOST"
        value = var.DB_HOST
      },
      {
        name  = "DB_USER"
        value = var.DB_USER
      },
      {
        name  = "DB_PASSWORD"
        value = var.DB_PASSWORD
      },
      {
        name  = "DB_NAME"
        value = var.DB_NAME
      },
      {
        name  = "DB_PORT"
        value = var.DB_PORT
      }
    ]
  }])
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture = "X86_64"
  }
}