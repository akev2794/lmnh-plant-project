

# ECS Task Definition to run the dashboard

resource "aws_ecs_task_definition" "c15-incitatus-dashboard-task-definition" {
    family = ""
    container_definitions = jsonencode([{

    }])
}