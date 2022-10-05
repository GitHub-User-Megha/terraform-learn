provider "aws" {
  region     = "us-east-1"
  access_key = "AKIA5BXTXGQTFD4FMK36"
  secret_key = "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"
}
//to connect to AWS using Keys

variable "subent-cider-block" {
  description = "subnet cider block"
  default     = "10.0.20.0/24"
  type        = string
}

variable "environment" {
  description = "Deployment environment"

}
//creating resources
resource "aws_vpc" "dev-vpc" {
  cidr_block = "10.0.0.0/16" //IP address range
  tags = {
    "Name"    = "Dev-vpc",
    "vpc-env" = "dev"
  }
}


//creating subnet using aws_vpc network
resource "aws_subnet" "dev-subnet-1" {

  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = var.subent-cider-block
  availability_zone = "us-east-1a"
  tags = {
    "Name" = "Dev-Subnet-1-vpc"
  }
}

data "aws_vpc" "existing_vpc" {
  default = true
}

resource "aws_subnet" "dev-subnet-2" {

  vpc_id            = data.aws_vpc.existing_vpc.id
  cidr_block        = "172.31.128.0/20"
  availability_zone = "us-east-1a"
  tags = {
    "Name" = "Dev-default-Subnet-1-vpc"
  }
}

output "dev-vpc-id" {
  value = aws_vpc.dev-vpc.id
}

output "dev-subnet-id" {
  value = aws_subnet.dev-subnet-1.id
}
