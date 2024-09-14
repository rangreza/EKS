terraform {
  backend "s3" {
    bucket         = "tfstate"
    key            = "path/to/your/statefile.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "dynamolck"
  }
}
