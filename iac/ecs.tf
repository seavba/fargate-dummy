resource "aws_ecs_cluster" "dummy_ecs_cluster" {
  name = "dummy_ecs_cluster" # Naming the cluster
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = "100"
  }
}


resource "aws_ecs_task_definition" "dummy_ecs_task" {
  family                   = "dummy_ecs_task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "dummy_ecs_task",
      "image": "${local.ecr_repo_url}/${var.ecr_repo}:${var.ecr_image_tag}",
      "essential": true,
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${var.cloudwatch_group}",
            "awslogs-region": "${var.aws_region}",
            "awslogs-stream-prefix": "ecs"
          }
        },
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ]
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 1024         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_service" "dummy_service" {
  name                              = "dummy_service"                             # Naming our first service
  cluster                           = aws_ecs_cluster.dummy_ecs_cluster.id            # Referencing our created Cluster
  task_definition                   = aws_ecs_task_definition.dummy_ecs_task.arn # Referencing the task our service will spin up
#  launch_type                       = "FARGATE"
  desired_count                     = var.num_containers # Setting the number of containers we want deployed to X
  health_check_grace_period_seconds = 300
  deployment_minimum_healthy_percent = 50

  load_balancer {
    target_group_arn                = aws_lb_target_group.dummyTG.arn # Referencing our target group
    container_name                  = aws_ecs_task_definition.dummy_ecs_task.family
    container_port                  = 80 # Specifying the container port
  }

  network_configuration {
    subnets                         = aws_subnet.private.*.id
    assign_public_ip                = true
    security_groups                 = ["${aws_security_group.dummy_security_group.id}"]
  }

  deployment_controller {
    type = "ECS"
  }

  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE"
    weight            = 100
  }
}
