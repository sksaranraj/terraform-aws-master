provider "aws" {
  region  = "ap-south-1"
}
module "vpc" {
  source = "/home/ubuntu/environment/Terraform/Modules/VPC"
  name = "my-vpc"
  vpc_cidr = "10.0.0.0/16"
  az             = ["ap-south-1a", "ap-south-1b"]
  db_subnet_cidr = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet_cidr  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
module "ecs_sg" {
  source = "terraform-aws-modules/security-group/aws"
  name        = "ECS-SG"
  description = "ECS-SG"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_rules            = ["https-443-tcp","http-80-tcp"]
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = ["all-all"]
  
  
  /*ingress_with_source_security_group_id = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "User-service ports"
      source_security_group_id  = "sg-0502b3551591cd816" 
    },
    {
      from_port   = 8081
      to_port     = 8090
      protocol    = "tcp"
      description = "User-service ports"
      source_security_group_id  = "sg-0502b3551591cd816" 
    },
  ]*/
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.10.0.0/16"
    },
    {
      from_port   = 48000
      to_port     = 48100
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.10.0.0/16"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "testi"
      cidr_blocks = "10.10.0.0/16"
    },
    
  ]
}
module "lb_sg" {
  source = "terraform-aws-modules/security-group/aws"
  name        = "ECS-LB-SG"
  description = "ECS-LB-SG"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_rules            = ["https-443-tcp","http-80-tcp"]
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = ["all-all"]
}
module "lb" {
    source = "/home/ubuntu/environment/Terraform/Modules/ALB"
    name               = "ECS-TerralB"
    security_groups    = [module.lb_sg.this_security_group_id]
    subnets            = [module.vpc.public_subnets_id[0],module.vpc.public_subnets_id[1]]
    vpc_id = module.vpc.vpc_id
    TargetGroup_name = "Ecs-default-TG"
    

}


module "ecs_cluster" {
  source = "/home/ubuntu/environment/Terraform/Modules/ECS"
  name = "my-cluster"
  container_insights = false
}

module "ecs-task-definition" {
  source = "/home/ubuntu/environment/Terraform/Modules/ECS-Taskdefinition"
  family = "apache"
  image = "442889374161.dkr.ecr.ap-south-1.amazonaws.com/saran_apache:version1.1"
  execution_role_arn = "arn:aws:iam::442889374161:role/ecsTaskExecutionRole"
  name ="apache"
  essential = true
  network_mode ="awsvpc"
  portMappings = [
    {
      containerPort = 80
      hostPort = 80
    },
  ]
}

module "ecs-service" {
  name = "apache"
  source = "/home/ubuntu/environment/Terraform/Modules/ECS-ServiceCreation"
  desired_count = 1
  cluster = module.ecs_cluster.this_ecs_cluster_name
  
  launch_type = "FARGATE"
  task_definition = module.ecs-task-definition.arn
  security_groups = [module.ecs_sg.this_security_group_id]
  subnets = [module.vpc.public_subnets_id[0],module.vpc.public_subnets_id[1]]
  target_group_arn = module.lb.target_group_arns
  
}
