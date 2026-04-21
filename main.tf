terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

# VPC
resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "iigtn-tf-dev-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "iigtn-tf-dev-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "iigtn-tf-dev-igw"
  }
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "iigtn-tf-dev-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group
resource "aws_security_group" "web_sg" {
  name   = "iigtn-tf-dev-web-sg"
  vpc_id = aws_vpc.dev_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_IP]
  }

  ingress {
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
    Name = "iigtn-tf-dev-web-sg"
  }
}

# Key Pair
resource "aws_key_pair" "dev_key" {
  key_name   = "iigtn-tf-dev-key"
  public_key = file(var.public_key_path)
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami                         = "ami-0d52744d6551d851e"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.dev_key.key_name

  tags = {
    Name = "iigtn-tf-dev-web"
  }
}

# Private Subnet for RDS (AZ-a)
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.1.10.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "iigtn-tf-dev-private-subnet-a"
  }
}

# Private Subnet for RDS (AZ-c)
resource "aws_subnet" "private_subnet_c" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.1.11.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "iigtn-tf-dev-private-subnet-c"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name = "iigtn-tf-dev-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_c.id
  ]

  tags = {
    Name = "iigtn-tf-dev-db-subnet-group"
  }
}

# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name   = "iigtn-tf-dev-rds-sg"
  vpc_id = aws_vpc.dev_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "iigtn-tf-dev-rds-sg"
  }
}

# RDS Instance
resource "aws_db_instance" "mysql" {
  identifier             = "iigtn-tf-dev-mysql"
  allocated_storage      = 20
  storage_type           = "gp3"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  db_name                = "appdbtf"
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  multi_az               = false

  tags = {
    Name = "iigtn-tf-dev-rds"
  }
}