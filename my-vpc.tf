# Define the AWS provider
provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

# Create a VPC
resource "aws_vpc" "my_test_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "My Test VPC"
}
}
# Create an internet gateway
resource "aws_internet_gateway" "my_test_igw" {
  vpc_id = aws_vpc.my_test_vpc.id
  tags={
    Name = "My Test igw"
  }
}
# Create public subnet
resource "aws_subnet" "my_public_subnet" {
  vpc_id                  = aws_vpc.my_test_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"  # Replace with your desired availability zone

  tags = {
    Name = "My Public Subnet"
  }
}

# Create private subnet
resource "aws_subnet" "my_private_subnet" {
  vpc_id                  = aws_vpc.my_test_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"  # Replace with your desired availability zone

  tags = {
    Name = "My Private Subnet"
  }
}

# Create a public route table
resource "aws_route_table" "my_public_route_table" {
  vpc_id = aws_vpc.my_test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_test_igw.id
  }
  tags={
    Name = "My Public RT"
  }
}

# Associate public subnet with the public route table
resource "aws_route_table_association" "my_public_subnet_association" {
  subnet_id      = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.my_public_route_table.id
}

# Create a private route table
resource "aws_route_table" "my_private_route_table" {
  vpc_id = aws_vpc.my_test_vpc.id
  tags ={
  Name = "My Private RT"
  }
}

# Associate private subnet with the private route table
resource "aws_route_table_association" "my_private_subnet_association" {
  subnet_id      = aws_subnet.my_private_subnet.id
  route_table_id = aws_route_table.my_private_route_table.id
}
# Create a security group
resource "aws_security_group" "my_security_group" {
  name        = "my-security-group"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id = aws_vpc.my_test_vpc.id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["73.147.81.220/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["73.147.81.220/32"]
  }
  # Egress rules (outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch an EC2 instance
resource "aws_instance" "my_nat_instance" {
  ami           = "ami-0715c1897453cabd1"  # Replace with the desired AMI ID
  instance_type = "t2.micro"
  key_name      = "prasanth_dev"  # Replace with your key pair name
  subnet_id       = aws_subnet.my_public_subnet.id
  security_groups = [aws_security_group.my_security_group.id]

  tags = {
    Name = "My Nat Instance"
  }
    associate_public_ip_address = true
    source_dest_check           = false
}
# Create a security group
resource "aws_security_group" "my_security_group2" {
  name        = "my-security-group2"
  description = "Allow SSH inbound traffic"
  
  vpc_id = aws_vpc.my_test_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
}

# Launch an EC2 instance
resource "aws_instance" "my_app_instance" {
  ami                    = "ami-0715c1897453cabd1"  # Replace with the desired AMI ID
  instance_type          = "t2.micro"
  key_name               = "prasanth_dev"  # Replace with your key pair name
  subnet_id              = aws_subnet.my_private_subnet.id
  vpc_security_group_ids = [aws_security_group.my_security_group2.id]
  user_data = templatefile("userdata/lampstack.sh",
  {
      ServerName = "lamp-server"
  })

  tags = {
    Name = "My App Instance"
  }
}
