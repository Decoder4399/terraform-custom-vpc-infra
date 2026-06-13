provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "custom_vpc"
  }
}

resource "aws_subnet" "my_subnet1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-southeast-2a"
  tags = {
    Name = "my_public_subnet"
  }
}

resource "aws_subnet" "my_private_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-southeast-2a"
  tags = {
    Name = "my_private_subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "my-route-table"
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.my_subnet1.id
  route_table_id = aws_route_table.my_rt.id
}

resource "aws_security_group" "my_sg" {
  name   = "my_sec"
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_security_grp"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ssh"
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "http"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "key" {
  key_name   = "my-key"
  public_key = file("my-key.pub")
}

resource "aws_instance" "my_ec2_custom" {
  ami                    = "ami-0a59248a6294cece2"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  key_name               = aws_key_pair.key.key_name
  subnet_id              = aws_subnet.my_subnet1.id
  tags = {
    Name = "my-custom-instance"
  }
}