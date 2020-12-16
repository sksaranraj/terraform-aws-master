output "vpc_id" {
    description = "The ID of the VPC"
    value = module.vpc.vpc_id
     
}

output "private_subnets_id" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets_id
}

output "public_subnets_id" {
  description = "List of IDs of private subnets"
  value       = module.vpc.public_subnets_id
}
output "this_ecs_cluster_arn" {
  value = module.ecs_cluster.this_ecs_cluster_arn
}
output "this_ecs_cluster_name" {
  value = module.ecs_cluster.this_ecs_cluster_name
}
output "container_definitions" {
  description = "A list of container definitions in JSON format that describe the different containers that make up your task"
  value       = module.ecs-task-definition.container_definitions
}
output "arn" {
  description = "The full Amazon Resource Name (ARN) of the task definition"
  value       = module.ecs-task-definition.arn
}
output "family" {
  description = "The revision of the task in a particular family"
  value       = module.ecs-task-definition.family
}
output "this_lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = module.lb.this_lb_dns_name
}