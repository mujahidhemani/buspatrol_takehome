terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "buspatrol-vpc"
  cidr = "10.0.0.0/21"

  azs             = ["us-east-1a"]
  private_subnets = ["10.0.0.0/24"]
  public_subnets  = ["10.0.1.0/24"]

  enable_nat_gateway = true
}

resource "aws_cloudwatch_log_group" "cluster_logs" {
  name = "buspatrol_ecs_cluster_logs"
}

resource "aws_ecs_cluster" "buspatrol-ecs" {
  name = "buspatrol"
  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.cluster_logs.name
      }
    }
  }
}

resource "aws_ecs_task_definition" "takehome" {
  network_mode             = "awsvpc"
  family                   = "buspatrol"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode(
    [
      {
        name      = "buspatrol-takehome"
        image     = "mujahidhemani/buspatrol-takehome:latest"
        essential = true
        command   = ["${var.bucket_name}"]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group : aws_cloudwatch_log_group.cluster_logs.name
            awslogs-region : "us-east-1"
            awslogs-stream-prefix : "takehome"
          }
        }
      }
  ])
}

resource "aws_iam_role" "ecs_task_role" {
  name = "buspatrol-ecsTaskRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "s3_create_bucket" {
  name        = "buspatrol-takehome-task-policy-s3"
  description = "Policy that allows bucket creation on S3"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": [
               "s3:CreateBucket"
           ],
           "Resource": "*"
       }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.s3_create_bucket.arn
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "buspatrol-ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}