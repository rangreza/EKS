provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  public_subnets  = ["10.0.1.0/24"]
  private_subnets = ["10.0.2.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "my-vpc"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.29.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.27"
  subnets         = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  vpc_id          = module.vpc.vpc_id

  enable_irsa = true
  manage_aws_auth = true
}

module "eks_managed_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "18.29.0"

  cluster_name = module.eks.cluster_id
  node_group_name = "my-managed-node-group"

  node_group_defaults = {
    instance_type = "t3.medium"
    desired_capacity = 2
    max_capacity     = 3
    min_capacity     = 1
  }

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets
}
