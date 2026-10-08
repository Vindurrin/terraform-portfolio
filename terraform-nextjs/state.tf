terraform {
  backend "s3" {
    bucket       = "terraform-portfolio-state-bucket-mb26"
    key          = "global/s3/terraform-portfolio-state-bucket-mb26.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
