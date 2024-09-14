terraform {
  backend "s3" {
    bucket = "my-tf-state-bucket"
    key    = "eks-cluster/terraform.tfstate"
    region = "us-west-2"
  }
}
