# Configure AWS credentials and region
provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

# Define variables for customization
variable "eks_cluster_name" {
  type        = string
  default     = "my-eks-cluster"
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_blocks" {
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
}

# Create subnets
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_blocks[0]
  availability_zone = "us-east-1a" # Replace with your desired availability zone
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_blocks[1]
  availability_zone = "us-east-1b" # Replace with your desired availability zone
}

# Create internet gateway
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.main.id
}

# Attach internet gateway to VPC
resource "aws_vpc_attachment" "ig_attachment" {
  vpc_id             = aws_vpc.main.id
  internet_gateway_id = aws_internet_gateway.ig.id
}

# Create route table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

# Create route for internet gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id     = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id         = aws_internet_gateway.ig.id
}

# Create route table for private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

# Associate route tables with subnets
resource "aws_subnet_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Create security group for EKS nodes
resource "aws_security_group" "eks_nodes" {
  name        = "eks-nodes"
  description = "Security group for EKS nodes"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

# Create EKS cluster
resource "aws_eks_cluster" "main" {
  name         = var.eks_cluster_name
  vpc_config {
    subnet_ids = [
      aws_subnet.public.id,
      aws_subnet.private.id
    ]
    security_group_ids = [
      aws_security_group.eks_nodes.id
    ]
  }
}
