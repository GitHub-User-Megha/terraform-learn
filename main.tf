provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAZCPKNG777H3AEQUU"
  secret_key = "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"
}
//to connect to AWS using Keys

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {}
variable "public_key" {}


//creating resources
resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Name" = "${var.env_prefix}-vpc"
  }
}


//creating subnet using aws_vpc network
resource "aws_subnet" "myapp-subnet-1" {

  vpc_id            = aws_vpc.myapp-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    "Name" = "${var.env_prefix}-subnet-1"
  }
}

# resource "aws_route_table" "myapp-route-table" {
#   vpc_id            = aws_vpc.myapp-vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.myapp-igw.id
#   } 
#   tags = {
#     "Name"    = "${var.env_prefix}-rtb"
#   }
# }

// creating internet gateway
resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id

  tags = {
    "Name" = "${var.env_prefix}-igw"
  }

}

// adding subnet to custom route table
# resource "aws_route_table_association" "a-rtb-subnet" {
#   subnet_id = aws_subnet.myapp-subnet-1.id
#   route_table_id = aws_route_table.myapp-route-table.id
# }

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    "Name" = "${var.env_prefix}-main-rtb"
  }
}


resource "aws_security_group" "myapp-sg" {
  name   = "myapp-sg"
  vpc_id = aws_vpc.myapp-vpc.id

  ingress = [{
    cidr_blocks      = [var.my_ip]
    description      = ""
    from_port        = 22
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 22
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = ""
      from_port        = 8080
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 8080
  }]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  tags = {
    "Name" = "${var.env_prefix}-sg"
  }

}

//query the data from AWS
data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "description"
    values = ["Amazon Linux 2 Kernel * x86_64 HVM gp2"]
  }
}
output "aws_ami" {
  value = data.aws_ami.latest-amazon-linux-image.id
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key"
  public_key = var.public_key
}
//if other attributes are not set then default values will be set 
resource "aws_instance" "myapp-server" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id              = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]

  availability_zone = var.avail_zone

  associate_public_ip_address = true

  key_name = aws_key_pair.ssh-key.key_name

  user_data = <<EOF
                  #!bin/bash
                  sudo yum update -y && sudo yum install -y docker
                  sudo systemctll start docker
                  sudo usermode -aG docker ec2-user
                  docker run -p 8080:80 nginx
              EOF


  tags = {
    "Name" = "${var.env_prefix}-servers"
  }
}
