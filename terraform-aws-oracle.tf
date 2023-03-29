provider "aws" {
  region = "eu-west-1"
}

locals {
  vpc_cidr_block = "10.0.0.0/16"
}

resource "aws_vpc" "oracle_vpc" {
  cidr_block = local.vpc_cidr_block
  tags = {
    Name = "oracle-vpc"
  }
}

resource "aws_subnet" "oracle_subnet_1" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.oracle_vpc.id
  tags = {
    Name = "oracle-subnet-1"
  }
}

resource "aws_subnet" "oracle_subnet_2" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.oracle_vpc.id
  tags = {
    Name = "oracle-subnet-2"
  }
}

resource "aws_security_group" "oracle_sg" {
  name        = "oracle-sg"
  description = "Oracle database security group"
  vpc_id      = aws_vpc.oracle_vpc.id
}

resource "aws_db_subnet_group" "oracle_subnet_group" {
  name       = "oracle-subnet-group"
  subnet_ids = [aws_subnet.oracle_subnet_1.id, aws_subnet.oracle_subnet_2.id]

  tags = {
    Name = "oracle-db-subnet-group"
  }
}

resource "aws_db_instance" "oracle_instance" {
  identifier           = "oracle-instance"
  allocated_storage    = 20
  engine               = "oracle-se2"
  engine_version       = "19.0.0.0.ru-2021-07.rur-2021-07.r1"
  instance_class       = "db.t3.micro"
  name                 = "myoracledb"
  username             = "oracleuser"
  password             = "supersecretpassword"
  db_subnet_group_name = aws_db_subnet_group.oracle_subnet_group.name

  vpc_security_group_ids = [aws_security_group.oracle_sg.id]

  backup_retention_period = 7
  backup_window           = "07:00-09:00"
  maintenance_window      = "Mon:09:00-Mon:11:00"

  license_model          = "license-included"
  auto_minor_version_upgrade = true

  tags = {
    Name = "oracle-instance"
  }
}
