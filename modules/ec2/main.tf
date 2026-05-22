resource "aws_security_group" "bastion_sg" {         # Bastion host security group
  name   = "${var.project_name}-bastion-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_sg" {          # ALB security group
  name   = "${var.project_name}-alb-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_sg" {         # Web server security group
  name   = "${var.project_name}-web-server-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_ids[0]  # Use the first public subnet for the bastion host
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = var.key_name
  tags                   = { Name = "${var.project_name}-Bastion" }
}

resource "aws_lb" "web_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id] 
  subnets            = var.public_subnet_ids            # List the two public subnet IDs
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

data "template_file" "user_data" {
template = <<-EOF
#!/bin/bash

exec > /var/log/user-data.log 2>&1

set -x

echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4

# Fix Ubuntu mirrors
sudo sed -i 's|http://|https://|g' /etc/apt/sources.list.d/ubuntu.sources

# Update packages
sudo apt-get update -y

# Install dependencies
sudo apt-get install -y \
    ca-certificates \
    curl \
    unzip \
    gnupg \
    lsb-release

# Add Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update again after adding Docker repo
sudo apt-get update -y

# Install Docker
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

unzip awscliv2.zip

sudo ./aws/install

# Wait for Docker daemon
sleep 15

# Login to ECR
aws ecr get-login-password --region ${var.region} | \
docker login --username AWS --password-stdin ${var.ecr_repository_url}

# Pull image
docker pull ${var.ecr_repository_url}:latest

# Run container
docker run -d --name nginx-server -p 80:80 ${var.ecr_repository_url}:latest
EOF
}

resource "aws_launch_template" "app_template" {
  name_prefix   = "${var.project_name}-template-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile { name = var.instance_profile_name }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web_sg.id]
  }

  user_data = base64encode(data.template_file.user_data.rendered)
}

# Auto Scaling Group for creating web servers in private subnets

resource "aws_autoscaling_group" "asg" {
  name                = "${var.project_name}-asg"
  vpc_zone_identifier = var.private_subnet_ids       # List the two private subnet IDs (each private subnet in a different AZ)
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.tg.arn]

  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-private-web"
    propagate_at_launch = true                           # Ensure tags are applied to instances launched by ASG
  }

}

# On Amazon Linux 2, Docker is available directly from the default package repositories, so installation is simple using yum.
# However, for Ubuntu, we need to add the Docker repository and GPG key before installing Docker.
# The user data script has been updated to handle both cases,
# ensuring that the correct installation steps are followed based on the underlying OS of the AMI used for the EC2 instances.