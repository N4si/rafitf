# main.tf

provider "aws" {
  region = var.region # Replace with your desired region
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr       = "10.0.0.0/16"
  vpc_name       = "demo-vpc"
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  azs            = ["us-east-1a", "us-east-1b"]  # Replace with your desired AZs
}

module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id # Assuming you have a VPC module
}

module "ec2_instance" {
  source            = "./modules/ec2"
  ami_id            = "ami-0ad22bffaccf79694" # Replace with your AMI ID
  instance_type     = "t2.micro"
  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.security_group.security_group_id
}

module "eks" {
  source = "./modules/eks"

  cluster_name         = "my-eks-cluster"
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnet_ids
  worker_node_role_arn = "arn:aws:iam::471112589177:role/mynodes" # Replace with your role ARN
  eks_cluster_role_arn = "arn:aws:iam::471112589177:role/myeks"     # Replace with your role ARN
  security_group_ids   = [module.security_group.security_group_id]             # Replace with your SG IDs
}