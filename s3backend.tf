terraform {
  backend "s3" {
    bucket         = "tfstate"
    key            = "path/to/your/statefile.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "dynamolck"
  }
}
