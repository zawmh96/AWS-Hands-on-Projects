# Configure the AWS provider
provider "aws" {
  region  = "ap-northeast-1"
  profile = "dev-programmatic-admin-role"
}

# Create a VPC
resource "aws_vpc" "pj1-vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "pj1-vpc"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "pj1-igw" {
  vpc_id = aws_vpc.pj1-vpc.id

  tags = {
    Name = "pj1-igw"
  }
}

# Create Public Route Table
resource "aws_route_table" "pj1-pub-rt" {
  vpc_id = aws_vpc.pj1-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pj1-igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.pj1-igw.id
  }

  tags = {
    Name = "pj1-pub-rt"
  }
}

# Create Private Route Table
resource "aws_route_table" "pj1-pri-rt" {
  vpc_id = aws_vpc.pj1-vpc.id

  tags = {
    Name = "pj1-pri-rt"
  }
}

# Create a public subnet
resource "aws_subnet" "pub-subnet" {
  vpc_id            = aws_vpc.pj1-vpc.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "pj1-public-subnet"
  }
}

# Create a private subnet
resource "aws_subnet" "pri-subnet" {
  vpc_id            = aws_vpc.pj1-vpc.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "pj1-private-subnet"
  }
}

# Associate public subnet with public Route Table
resource "aws_route_table_association" "pub-rt-asso" {
  subnet_id      = aws_subnet.pub-subnet.id
  route_table_id = aws_route_table.pj1-pub-rt.id
}

# Associate private subnet with private Route Table
resource "aws_route_table_association" "pri-rt-asso" {
  subnet_id      = aws_subnet.pri-subnet.id
  route_table_id = aws_route_table.pj1-pri-rt.id
}

# Create a security group for the bastion host
resource "aws_security_group" "bastion-secgw" {
  name        = "Allow SSH"
  description = "Allow SSH access from outside"
  vpc_id      = aws_vpc.pj1-vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bastion secgw"
  }
}

# Create a security group for the private Linux server
resource "aws_security_group" "server-secgw" {
  name        = "Allow only from public subnet"
  description = "Allow SSH access from bastion subnet"
  vpc_id      = aws_vpc.pj1-vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.pub-subnet.cidr_block]
  }

  egress {
    description = "allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Server secgw"
  }
}

# Create a network interface with an IP in the public subnet
resource "aws_network_interface" "bastion-ip" {
  subnet_id       = aws_subnet.pub-subnet.id
  private_ips     = ["10.10.1.50"]
  security_groups = [aws_security_group.bastion-secgw.id]
}

# Create a network interface with an IP in the private subnet
resource "aws_network_interface" "server-ip" {
  subnet_id       = aws_subnet.pri-subnet.id
  private_ips     = ["10.10.2.50"]
  security_groups = [aws_security_group.server-secgw.id]
}

# Assign an elastic IP to the network interface of the bastion host
resource "aws_eip" "bastion-eip" {
  domain                  = "vpc"
  network_interface       = aws_network_interface.bastion-ip.id
  associate_with_private_ip = "10.10.1.50"
}

# Create the bastion host in the public subnet
resource "aws_instance" "bastion-host" {
  ami               = "ami-034bc4e4fcccfe844"
  instance_type     = "t2.micro"
  availability_zone = "ap-northeast-1a"
  key_name          = "mykey" # create it in advance

  tags = {
    Name = "bastion-host"
  }

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.bastion-ip.id
  }
}

# Create Amazon Linux server for private server
resource "aws_instance" "private-server" {
  ami               = "ami-034bc4e4fcccfe844"
  instance_type     = "t2.micro"
  availability_zone = "ap-northeast-1c"
  key_name          = "mykey" # create it in advance

  tags = {
    Name = "private-server"
  }

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.server-ip.id
  }
}
