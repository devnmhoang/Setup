terraform {
  backend "s3" {
    bucket = "aztec-terraform"
    key    = "setup/setup-mpc-map"
    region = "eu-west-2"
  }
}

data "terraform_remote_state" "setup_iac" {
  backend = "s3"
  config = {
    bucket = "aztec-terraform"
    key    = "setup/setup-iac"
    region = "eu-west-2"
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

resource "aws_service_discovery_service" "setup_mpc_map" {
  name = "setup-mpc-map"

  health_check_custom_config {
    failure_threshold = 1
  }

  dns_config {
    namespace_id = "${data.terraform_remote_state.setup_iac.outputs.local_service_discovery_id}"

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
}

resource "aws_ecs_task_definition" "setup_mpc_map" {
  family                   = "setup-mpc-map"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "${data.terraform_remote_state.setup_iac.outputs.ecs_task_execution_role_arn}"

  container_definitions = <<DEFINITIONS
[
  {
    "name": "setup-mpc-map",
    "image": "aztec/setup-mpc-map:latest",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80
      }
    ],
    "environment": [
      {
        "name": "NODE_ENV",
        "value": "production"
      },
      {
        "name": "PORT",
        "value": "80"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/setup-mpc-map",
        "awslogs-region": "eu-west-2",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITIONS
}

data "aws_ecs_task_definition" "setup_mpc_map" {
  task_definition = "${aws_ecs_task_definition.setup_mpc_map.family}"
}

resource "aws_ecs_service" "setup_mpc_map" {
  name          = "setup-mpc-map"
  cluster       = "${data.terraform_remote_state.setup_iac.outputs.ecs_cluster_id}"
  launch_type   = "FARGATE"
  desired_count = "1"

  network_configuration {
    subnets = [
      "${data.terraform_remote_state.setup_iac.outputs.subnet_az1_private_id}",
      "${data.terraform_remote_state.setup_iac.outputs.subnet_az2_private_id}"
    ]
    security_groups = ["${data.terraform_remote_state.setup_iac.outputs.security_group_private_id}"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.setup_mpc_map.arn}"
    container_name   = "setup-mpc-map"
    container_port   = 80
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.setup_mpc_map.arn}"
  }

  # Track the latest ACTIVE revision
  task_definition = "${aws_ecs_task_definition.setup_mpc_map.family}:${max("${aws_ecs_task_definition.setup_mpc_map.revision}", "${data.aws_ecs_task_definition.setup_mpc_map.revision}")}"

  lifecycle {
    ignore_changes = ["task_definition"]
  }
}

# Logs
resource "aws_cloudwatch_log_group" "setup_mpc_map_logs" {
  name              = "/fargate/service/setup-mpc-map"
  retention_in_days = "14"
}

# Configure ALB route.
resource "aws_alb_target_group" "setup_mpc_map" {
  name        = "setup-mpc-map"
  port        = "80"
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${data.terraform_remote_state.setup_iac.outputs.vpc_id}"
  tags = {
    name = "setup-mpc-map"
  }
}

resource "aws_lb_listener_rule" "setup_mpc_map" {
  listener_arn = "${data.terraform_remote_state.setup_iac.outputs.alb_listener_arn}"
  priority     = 300

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.setup_mpc_map.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["*"]
  }
}
