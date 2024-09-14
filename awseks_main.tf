provider "aws" {
  region = "ap-south-1"  # Set the appropriate region
}

# Define the S3 backend for Terraform state storage
terraform {
  backend "s3" {
    bucket         = "ttfstate"
    key            = "terraform/state"
    region         = "ap-south-1"
    encrypt        = true
  }
}

# Define the EKS module
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.29.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.21"  # Adjust based on your requirements

  node_groups = {
    example_node_group = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_type    = "t3.medium"
    }
  }

  tags = {
    "Name" = "my-cluster"
  }
}
