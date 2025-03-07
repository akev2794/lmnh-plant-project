

# Steps to Create Task Definition
data "aws_vpc" "c15_vpc" {
    id = var.AWS_VPC_ID
}

data "aws_iam_role" "ecs_service_execution_role" {
    name = "ecsTaskExecutionRole"
}

data "aws_ecr_repository" "dashboard_repo" {
  name = "c15-incitatus-dashboard-ecr"
}

data "aws_ecr_image" "latest_dashboard_image" {
  repository_name = data.aws_ecr_repository.dashboard_repo.name
  most_recent     = true
}

resource "aws_ecs_task_definition" "dashboard_task" {
  family                   = "c15-incitatus-dashboard-taskdef"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_service_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "c15-incitatus-dashboard-taskdef"
      image     = data.aws_ecr_image.latest_dashboard_image.image_uri
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
          containerPort = 1433
          hostPort      = 1433
          protocol      = "tcp"
        },
        {
          containerPort = 8501
          hostPort      = 8501
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/c15-incitatus-dashboard-taskdef"
          "awslogs-region"        = var.AWS_REGION
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }

      environment = [
        { name = "DB_HOST", value = var.DB_HOST },
        { name = "DB_USER", value = var.DB_USER },
        { name = "DB_PASSWORD", value = var.DB_PASSWORD },
        { name = "DB_NAME", value = var.DB_NAME },
        { name = "DB_PORT", value = var.DB_PORT }
      ]
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture       = "X86_64"
  }
}

resource "aws_security_group" "ecs_security_group" {
  vpc_id = data.aws_vpc.c15_vpc.id

  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ecs_cluster" "ecs_cluster" {
  cluster_name = "c15-ecs-cluster"
}

data "aws_subnet" "subnet1" {
  id = "subnet-09963d73cb3483abe"
}

data "aws_subnet" "subnet2" {
  id = "subnet-08b00202ae83c58a8"
}

data "aws_subnet" "subnet3" {
  id = "subnet-0a007e7162fab0ba2"
}

resource "aws_ecs_service" "dashboard_service" {
  name            = "c15-incitatus-dashboard-service"
  cluster         = data.aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.dashboard_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [data.aws_subnet.subnet1.id, data.aws_subnet.subnet2.id, data.aws_subnet.subnet3.id]
    security_groups  = [aws_security_group.ecs_security_group.id]
    assign_public_ip = true  
  }

  depends_on = [aws_ecs_task_definition.dashboard_task]
}