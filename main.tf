# main.tf

provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr       = "10.0.0.0/16"
  vpc_name       = "demo-vpc"
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  azs            = ["us-east-1a", "us-east-1b"]  # Replace with your desired AZs
}