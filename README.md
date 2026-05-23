# ShopFlow - Containerized E-Commerce Backend Platform

## Overview

ShopFlow is a complete DevOps project that demonstrates how to provision and automate a secure AWS infrastructure using Terraform and Jenkins CI/CD pipelines.

The project follows Infrastructure as Code (IaC) principles and deploys a containerized backend application using Docker, Amazon ECR, EC2 Auto Scaling, and RDS.

---

## Architecture Diagram

<img width="1024" height="1536" alt="Architecture" src="https://github.com/user-attachments/assets/1fc3cf29-4060-4d98-90ab-70927b6eced7" />


---

# AWS Architecture Summary

The infrastructure is designed using a secure multi-tier AWS architecture:

- Public Subnet for Bastion Host

- Private Subnet for Application Servers

- RDS MySQL Database in isolated subnet group

- Auto Scaling Group for high availability

- CloudWatch for monitoring and logging

- Terraform Remote State stored in Amazon S3

---

# Notes to be considered 

Infrastructure Setup Explanation
---------------------------------

In this project, I started by manually creating an Amazon S3 bucket before running any Terraform configuration. The main purpose of this was to store the Terraform backend state file remotely instead of keeping it locally.

Using a remote state in S3 has several advantages:

1- It prevents loss of state in case the local machine crashes or gets corrupted.

2- It ensures that the infrastructure state can be recovered at any time.

3- It enables team collaboration, allowing multiple engineers to work on the same infrastructure safely using a shared state file.

After creating the S3 bucket manually, I configured it in the backend.tf file so Terraform could use it as the remote backend for state management.


ECR Setup
----------

I also manually created an Private Amazon ECR (Elastic Container Registry) repository before running the CI/CD pipeline.

This step was important because:

The Docker image needs a destination repository before the pipeline builds and pushes it.
If the ECR repository does not exist beforehand, the pipeline would fail when trying to push the image.
Pre-creating the ECR ensures that the deployment process runs smoothly without interruptions or misconfigurations.
Deployment Flow

Once the infrastructure was ready:

1- The CI/CD pipeline builds the Docker image.

2- The image is pushed to the manually created Private ECR repository.

3- The EC2 instances in the private subnet pull the image from ECR.

4- Then the containers are run inside the private environment securely.

---

# Technologies Used

## Cloud Provider

- <img src="https://upload.wikimedia.org/wikipedia/commons/9/93/Amazon_Web_Services_Logo.svg" width="60" alt="AWS Genuine Logo" />  AWS (Amazon Web Services)

## Infrastructure as Code

- <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/terraform/terraform-original.svg" width="40" height="40" alt="Terraform" />  Terraform

## CI/CD

- <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/jenkins/jenkins-original.svg" width="40" height="40" alt="Jenkins" />  Jenkins

## Containerization

- <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/docker/docker-original.svg" width="40" height="40" alt="Docker" />  Docker

- <img src="https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Containers/ElasticContainerRegistry.png" width="40" height="40" alt="AWS ECR" />  Amazon ECR

## Monitoring

- <img src="https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/ManagementGovernance/CloudWatch.png" width="40" height="40" alt="AWS CloudWatch" />  CloudWatch

## Database

- <img src="https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/Database/Aurora.png" width="40" height="40" alt="AWS RDS" />  Amazon RDS (MySQL)

---

# AWS Services Used

- VPC

- EC2

- Auto Scaling Group

- Launch Template

- Security Groups

- Internet Gateway

- NAT Gateway

- Amazon RDS

- Amazon ECR

- Amazon S3

- IAM

- CloudWatch

---

# Project Architecture

## Networking

- VPC CIDR: `10.0.0.0/16`

- Public Subnet

- Private Subnet

- Internet Gateway

- NAT Gateway

- Route Tables

## Compute Layer

- Bastion Host in Public Subnet

- 2 EC2 Instances inside Private Subnet

- Auto Scaling Group

- Dockerized Application Deployment

## Database Layer

- MySQL RDS

- Single-AZ Enabled

- DB Subnet Group

- Restricted Access through Security Groups

---

# CI/CD Pipeline

The Jenkins pipeline automates the deployment process through multiple stages:

## Stage 1 - Checkout

Fetch source code from GitHub repository.

## Stage 2 - Build & Test

Build and validate the application.

## Stage 3 - Push Docker Image

Build Docker image and push it to Amazon ECR.

## Stage 4 - Terraform Plan

Validate infrastructure changes using Terraform Plan.

## Stage 5 - Approval

Approval stage before deployment.

## Stage 6 - Terraform Apply

Provision and update infrastructure automatically.

---

# Security Features

- Private EC2 instances with no direct public access

- Bastion Host for secure SSH access

- IAM Roles and Policies

- Security Groups for traffic control

- RDS accessible only from application servers

---

# Monitoring

CloudWatch is used for:

- Logs

- Metrics

- Monitoring

- Alarms

---

# Terraform Remote State

Terraform state is stored remotely in Amazon S3 to ensure:

- Team collaboration

- State consistency

- Secure state management

---

# Deployment Flow

```text
User
   ↓
Bastion Host
   ↓
Private EC2 Instances

```

---

# Key Features

- Infrastructure as Code using Terraform

- Fully automated CI/CD pipeline using Jenkins

- Docker container deployment

- Secure AWS architecture

- Auto Scaling infrastructure

- Centralized monitoring with CloudWatch

- Remote Terraform state management

---

# Future Improvements

- Add HTTPS using ACM
- Integrate WAF for enhanced security
- Add Kubernetes deployment
- Implement Blue/Green deployment strategy

---

# Author

Zeyad Moustafa  
Cloud & DevOps Engineer
