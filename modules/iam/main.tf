resource "aws_iam_group" "developers"{                    # developers group
     name = "${var.project_name}-Developers" 
}

resource "aws_iam_group_policy_attachment" "dev_ecr" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_group_policy_attachment" "dev_ec2_read" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "dev_s3_read" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_group" "operators" {                    # operators group
    name = "${var.project_name}-Operators" 
}

resource "aws_iam_group_policy_attachment" "op_ec2" {
  group      = aws_iam_group.operators.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "op_rds" {
  group      = aws_iam_group.operators.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
}

resource "aws_iam_group" "viewers" {                      # viewers group
    name = "${var.project_name}-Viewers" 
}

resource "aws_iam_group_policy_attachment" "view_only" {
  group      = aws_iam_group.viewers.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_group" "admins" {                       # admins group
    name = "${var.project_name}-Admins" 
}

resource "aws_iam_group_policy_attachment" "admin_full" {
  group      = aws_iam_group.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "ec2_role" {                      # EC2 instance role
  name = "${var.project_name}-EC2-Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ecr" {    # Attach ECR read-only policy to EC2 role
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ec2_cw" {      # Attach CloudWatch agent policy to EC2 role
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_profile" {       # EC2 instance profile
  name = "${var.project_name}-EC2-Profile"
  role = aws_iam_role.ec2_role.name
}