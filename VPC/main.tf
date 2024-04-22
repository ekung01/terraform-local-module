# terraform block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider.
provider "aws" {
  region = "us-west-2"
}

# Create a VPC
resource "aws_vpc" "my-vpc" {
  cidr_block           = var.my-vpc_cidr_block
  # instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-deployed-vpc"
  }
}
# creating subnets
resource "aws_subnet" "publicSubnet1" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = var.publicSubnet1_cidr_block
}

resource "aws_subnet" "publicSubnet2" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = var.publicSubnet2_cidr_block
}

resource "aws_subnet" "privateSubnet1" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = var.privateSubnet1_cidr_block
}

resource "aws_subnet" "privateSubnet2" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = var.privateSubnet2_cidr_block
}

# creating internet gateway
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "my-igw"
  }
}

# creating route table

resource "aws_route_table" "my-public-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

  tags = {
    Name = "my-public-rt"
  }
}

# route table for private subnet1
resource "aws_route_table" "my-private-rt1" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my-nat-gateway.id
  }

  tags = {
    Name = "my-private-rt1"
  }
}

# route table for private subnet2

resource "aws_route_table" "my-private-rt2" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my-nat-gateway.id
  }

  tags = {
    Name = "my-private-rt2"
  }
}

# route table association for private subnet1

resource "aws_route_table_association" "privateSubnet1-rt" {
  subnet_id      = aws_subnet.privateSubnet1.id
  route_table_id = aws_route_table.my-private-rt1.id
}

# route table association for private subnet2

resource "aws_route_table_association" "privateSubnet2-rt" {
  subnet_id      = aws_subnet.privateSubnet2.id
  route_table_id = aws_route_table.my-private-rt2.id
}

# creating route table association

resource "aws_route_table_association" "publicSubnet1-rt" {
  subnet_id      = aws_subnet.publicSubnet1.id
  route_table_id = aws_route_table.my-public-rt.id
}

resource "aws_route_table_association" "publicSubnet2-rt" {
  subnet_id      = aws_subnet.publicSubnet2.id
  route_table_id = aws_route_table.my-public-rt.id
}

# creating security group

resource "aws_security_group" "my-sg" {
  name        = "my-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-sg"
  }
}

# creating security group rule

resource "aws_security_group_rule" "my-sg-rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my-sg.id
}

# creating NAT gateway

resource "aws_nat_gateway" "my-nat-gateway" {
  allocation_id = aws_eip.my-eip.id
  subnet_id     = aws_subnet.publicSubnet1.id

  tags = {
    Name = "my-nat-gateway"
  }
}

# creating Elastic IP

resource "aws_eip" "my-eip" {
  vpc = true
}
