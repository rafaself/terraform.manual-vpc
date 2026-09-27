module "vpc" {
  source = "./modules/vpc"

  cidr_block         = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
    most_recent = true

    owners = ["099720109477"] # Canonical ID

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }

    filter {
        name = "virtualization_type"
        values = ["hvm"]
    }
}

resource "aws_instance" "lab-app-terraform-aws-network" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t3.micro"

    subnet_id = module.vpc.public_subnet_id

    tags = {
        Name = "lab-terraform-aws-network"
    }
}