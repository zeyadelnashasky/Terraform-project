terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-zoz"  # Name of your S3 bucket to store the Terraform state file
    key            = "global/terraform.tfstate"    # Path within the bucket to store the state file
    region         = "eu-north-1"   # Make sure this matches the region where your S3 bucket you want to locate 
  # because backend intialize before terrraform apply the variables 
    encrypt        = true
    use_lockfile = true
  }
}