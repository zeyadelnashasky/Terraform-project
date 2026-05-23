project_name        = "terraform-project"
region              = "eu-north-1"
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"

# Ubuntu 22.04 LTS AMI ID for eu-north-1 (Stockholm)
ami_id              = "ami-09a9858973b288bdd"    # Amazon Linux 2 in eu-north-1 
instance_type       = "t3.micro"
key_name            = "project-key"              # name of existing AWS SSH Key Pair that i created in the AWS console and downloaded to my local machine

ecr_repository_url  = "200098097766.dkr.ecr.eu-north-1.amazonaws.com/my-registry"  # <account-id>.dkr.ecr.<region>.amazonaws.com/<repo-name>

db_name             = "production_db"
db_username         = "db_admin"
db_password         = "SuperSecurePassword123?!"

admin_email         = "zeyadmoustafa732@gmail.com"
