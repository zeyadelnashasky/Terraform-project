output "alb_dns_name" {
  value = module.ec2.alb_dns_name
  description = "The public DNS of the Load Balancer to access the application"
}

output "db_endpoint" {
  value = module.rds.db_endpoint
  description = "The endpoint of the Database"      
}

output "vpc_id" {
  value = module.vpc.vpc_id
  description = "The ID of the VPC"
}