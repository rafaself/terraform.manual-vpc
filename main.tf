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
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id = module.vpc.public_subnet_id

  vpc_security_group_ids = [
    aws_security_group.app.id
  ]

  key_name = aws_key_pair.app.key_name

  user_data                   = file("${path.module}/assets/cloud_init.yaml")
  user_data_replace_on_change = true

  tags = {
    Name = "lab-terraform-aws-network"
  }
}

resource "aws_security_group" "app" {
  name        = "lab-sg-app-terraform-aws-network"
  description = "Security group for lab EC2 network"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "lab-sg-app-terraform-aws-network"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.app.id

  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.app.id

  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22

  cidr_ipv4 = var.ssh_cidr
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.app.id

  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_key_pair" "app" {
  key_name   = "terraform-lab"
  public_key = file("./keys/aws_key.pub")
}