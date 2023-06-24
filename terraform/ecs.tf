resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
  capacity_providers = [aws_ecs_capacity_provider.provider.name]
}

resource "aws_ecs_task_definition" "task_definition" {
  family = "nginx"
  network_mode = "bridge"
  container_definitions = jsonencode([
    {
      essential   = true
      memory      = 256
      name        = "nginx"
      cpu         = 1
      image       = "nginx"
      environment = []
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "worker" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1
}

resource "aws_ecs_capacity_provider" "provider" {
  name = var.app_name
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.example.arn

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 100
    }
  }
}
