provider "aws" {
  region = "us-west-2"  # Change region as needed
}

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

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "eks-cluster"
  cluster_version = "1.23"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

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

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_id" {
  value = module.eks.cluster_id
}
