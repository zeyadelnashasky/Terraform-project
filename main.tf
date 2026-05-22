module "vpc" {
  source             = "./modules/vpc"
  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  region             = var.region
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "iam" {
  source              = "./modules/iam"
  project_name        = var.project_name
}

module "ec2" {
  source                = "./modules/ec2"
  project_name          = var.project_name
  region                = var.region
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids
  instance_profile_name = module.iam.ec2_instance_profile_name
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  key_name              = var.key_name
  ecr_repository_url    = var.ecr_repository_url
}

module "rds" {
  source            = "./modules/rds"
  project_name      = var.project_name
  region            = var.region
  vpc_id            = module.vpc.vpc_id
  private_subnet_id = module.vpc.private_subnet_ids[0]  # Use the first private subnet for RDS
  web_sg_id         = module.ec2.web_sg_id
  instance_type     = var.instance_type
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
}

module "monitoring" {
  source       = "./modules/monitoring"
  project_name = var.project_name
  asg_name     = module.ec2.asg_name
  admin_email  = var.admin_email
}

# create ecr manual on aws console 
# If you are building a complete pipeline, Terraform needs the ECR repository to exist first,
# so you can push the Docker images that ECS or EKS will later use in the script.
# If you want to automate the ECR repository creation as well, you can add a resource block for it in your Terraform configuration like this:

################################################################
# resource "aws_ecr_repository" "my_app_repo" {
#   name = "${var.project_name}-app-repo"
#   image_tag_mutability = "MUTABLE"
#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }
################################################################


# if you have ecs rely on ecr, you can force ecr to be created first,
# then ecs can use the ecr repository to use images stored in ecr.


#################################################################
#resource "aws_ecs_task_definition" "app_task" {
#  family                   = "my-app-task"
#  depends_on = [aws_ecr_repository.my_app_ecr]
#}
#################################################################

