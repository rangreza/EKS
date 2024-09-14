provider "aws" {
  region = "us-west-2"
}

# VPC Module (unchanged)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.0"

  name                 = "eks-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = {
    Name = "eks-vpc"
  }
}

# EKS Module - Adjusted to match module version >= 18.0.0
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.29.0"  # Use the latest stable version

  cluster_name    = "eks-cluster"
  cluster_version = "1.23"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets  # Corrected argument name

  node_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      instance_type = "t3.medium"

      key_name = "eks-key"
    }
  }

  tags = {
    Name = "eks-cluster"
  }
}

