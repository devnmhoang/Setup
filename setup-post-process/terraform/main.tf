terraform {
  backend "s3" {
    bucket = "aztec-terraform"
    key    = "setup/setup-post-processing"
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

data "terraform_remote_state" "setup_iac_us_east_2" {
  backend = "s3"
  config = {
    bucket = "aztec-terraform"
    key    = "setup/setup-iac/us-east-2"
    region = "eu-west-2"
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

resource "aws_ecs_task_definition" "setup_post_process" {
  family                   = "setup-post-process"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  execution_role_arn       = data.terraform_remote_state.setup_iac.outputs.ecs_task_execution_role_arn
  task_role_arn            = aws_iam_role.setup_post_process_task_role.arn

  container_definitions = <<DEFINITIONS
[
  {
    "name": "setup-post-process",
    "image": "aztec/setup-post-process:latest",
    "essential": true,
    "memoryReservation": 256,
    "environment": [
      {
        "name": "JOB_SERVER_HOST",
        "value": "internal-setup-job-server-1643422750.eu-west-2.elb.amazonaws.com"
      },
      {
        "name": "MPC_SERVER_HOST",
        "value": "internal-setup-mpc-server-1439018684.eu-west-2.elb.amazonaws.com"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/service/setup-post-process",
        "awslogs-region": "us-east-2",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITIONS
}

data "aws_ecs_task_definition" "setup_post_process" {
  task_definition = "${aws_ecs_task_definition.setup_post_process.family}"
}

resource "aws_ecs_service" "setup_post_process" {
  name                               = "setup-post-process"
  cluster                            = data.terraform_remote_state.setup_iac_us_east_2.outputs.ecs_main_cluster_id
  launch_type                        = "EC2"
  desired_count                      = "3000"
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  network_configuration {
    subnets = [
      "${data.terraform_remote_state.setup_iac_us_east_2.outputs.subnet_az1_private_id}",
      "${data.terraform_remote_state.setup_iac_us_east_2.outputs.subnet_az2_private_id}",
      "${data.terraform_remote_state.setup_iac_us_east_2.outputs.subnet_az3_private_id}"
    ]
    security_groups = ["${data.terraform_remote_state.setup_iac_us_east_2.outputs.security_group_private_id}"]
  }

  placement_constraints {
    type = "distinctInstance"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:group == setup-post-process"
  }

  # Track the latest ACTIVE revision
  # task_definition = "${aws_ecs_task_definition.setup_post_process.family}"
  task_definition = "${aws_ecs_task_definition.setup_post_process.family}:${max("${aws_ecs_task_definition.setup_post_process.revision}", "${data.aws_ecs_task_definition.setup_post_process.revision}")}"
}

# Logging setup-post-process to CloudWatch
resource "aws_cloudwatch_log_group" "setup_post_process" {
  name              = "/service/setup-post-process"
  retention_in_days = "14"
}

# S3 bucket.
data "aws_iam_policy_document" "ecs_task" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "setup_post_process_task_role" {
  name               = "setup-post-process-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task.json
}

data "aws_iam_policy_document" "aztec_post_processing_bucket_read" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::aztec-post-process/*"]
  }
}

resource "aws_iam_role_policy" "setup_post_processing_task_policy" {
  policy = data.aws_iam_policy_document.aztec_post_processing_bucket_read.json
  role   = aws_iam_role.setup_post_process_task_role.id
}
