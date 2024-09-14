terraform {
  backend "s3" {
    bucket         = "ttfstate"
    key            = "terraform/statefile.tfstate"
    region         = "ap-south-1"
    encrypt        = true
  }
}
