variable "project_name" {
  type        = string
  description = "Name of the project used for tagging resources"
}

variable "region" {
  type        = string
  description = "AWS Region to deploy resources"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for the public subnet"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR block for the private subnet"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instances"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "key_name" {
  type        = string
  description = "Name of the AWS SSH Key Pair"
}

variable "ecr_repository_url" {
  type        = string
  description = "The URL of the ECR repository to pull Docker images"
}

variable "db_name" {
  type        = string
  description = "The name of the database to create"
}

variable "db_username" {
  type        = string
  description = "Username for the master DB user"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Password for the master DB user"
}

variable "admin_email" {
  type        = string
  description = "Email address to receive infrastructure alerts"
}