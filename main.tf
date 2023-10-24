terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_key_pair" "ssh_key" {
  key_name = "ssh_key"
  public_key = file("${path.module}/keys/id_rsa.pub")
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_block
  
  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "main"
  }
}

resource "aws_eip" "main" {
}

# The NAT gateway needs to sit in a public subnet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id = aws_subnet.public.id

  tags = {
    Name = "main"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main.id
  }
  
  tags = {
    Name = "private"
  }
}

# A public subnet necessarily has a route to an igw
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "assoc_private" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "assoc_public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_block
  
  tags = {
    Name = "private"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_block
  
  tags = {
    Name = "public"
  }
}

# SG "allow": ssh and http from anywhere
resource "aws_security_group" "allow" {
  name = "allow"
  description = "Allow inbound traffic"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow"
  }
}

# SG "allow_internal": ssh and http from the bastion
resource "aws_security_group" "allow_internal" {
  name = "allow_internal"
  description = "Allow internal inbound traffic"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH from the bastion host"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.14.0.11/32"]
  }

  ingress {
    description = "HTTP from the bastion host"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["10.14.0.11/32"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_internal"
  }
}

# The load balancer becomes the bastion host
resource "aws_instance" "load_balancer" {
  ami = var.instance_ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.public.id
  key_name = "ssh_key"
  private_ip = var.load_balancer_ip_address
  vpc_security_group_ids = [aws_security_group.allow.id]
  user_data = "${file("${path.module}/user_data/load-balancer.sh")}"
  associate_public_ip_address = true

  tags = {
    Name = "load-balancer"
  }
}

resource "aws_instance" "app_server_1" {
  ami = var.instance_ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.private.id
  key_name = "ssh_key"
  private_ip = var.app_server_1_ip_address
  vpc_security_group_ids = [aws_security_group.allow_internal.id]
  user_data = "${file("${path.module}/user_data/app-server.sh")}"

  tags = {
    Name = "app-server-1"
  }
}

resource "aws_instance" "app_server_2" {
  ami = var.instance_ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.private.id
  key_name = "ssh_key"
  private_ip = var.app_server_2_ip_address
  vpc_security_group_ids = [aws_security_group.allow_internal.id]
  user_data = "${file("${path.module}/user_data/app-server.sh")}"

  tags = {
    Name = "app-server-2"
  }
}
