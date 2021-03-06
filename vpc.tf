provider "aws" {
  region  = "ap-south-1"
}
resource "aws_vpc" "vpc1" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc1"
  }
}
resource "aws_subnet" "main" {
  vpc_id     = "${aws_vpc.vpc1.id}"
  cidr_block = "192.168.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet1"
  }
}
resource "aws_subnet" "main1" {
  vpc_id     = "${aws_vpc.vpc1.id}"
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "subnet2"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc1.id}"

  tags = {
    Name = "mygw1"
  }
}
resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.vpc1.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"

  }

  tags = {
    Name = "main"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.r.id
}
resource "aws_security_group" "sg1" {
  name        = "securitygr1"
  description = "Allow ssh_http_icmp"
  vpc_id      = "${aws_vpc.vpc1.id}"

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ICMP"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpresssg1"
  }
}
resource "aws_security_group" "sg2" {
  name        = "securitygr2"
  description = "Allow wordpresss1 only"
  vpc_id      = "${aws_vpc.vpc1.id}"

  ingress {
    description = "MYSQL"
    security_groups = ["${aws_security_group.sg1.id}"]
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "mysqlsg"
  }
}
resource "aws_instance" "web" {
  ami = "ami-7e257211"
  instance_type = "t2.micro"
  key_name = "onkar12"
  vpc_security_group_ids = [ "${aws_security_group.sg1.id}" ]
  subnet_id = aws_subnet.main.id  
tags ={
    Name = "wordpress"
  }
  
}
resource "aws_instance" "web2" {
  ami = "ami-08706cb5f68222d09"
  instance_type = "t2.micro"
  key_name = "onkar12"
  vpc_security_group_ids = [ "${aws_security_group.sg2.id}" ]
  subnet_id = aws_subnet.main1.id  
tags ={
    Name = "mysql"
  }
  
}


