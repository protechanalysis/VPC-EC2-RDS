terraform {
  backend "s3" {
    bucket       = "infra-terraform-backend-database-rds"
    key          = "terraform.tfstate"
    use_lockfile = true
    region       = "us-east-1"
  }
}
