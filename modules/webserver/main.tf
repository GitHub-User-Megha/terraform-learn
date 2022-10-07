resource "aws_security_group" "myapp-sg" {
  name   = "myapp-sg"
  vpc_id = var.vpc_id

  ingress {
    cidr_blocks      = [var.my_ip]
    description      = ""
    from_port        = 22
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 22
  }
  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 8080
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 8080
  }

  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }
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


# resource "aws_key_pair" "ssh-key" {
#   key_name   = "key-pair"
#   public_key = var.public_key
# }
//if other attributes are not set then default values will be set 
resource "aws_instance" "myapp-server" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]

  availability_zone = var.avail_zone

  associate_public_ip_address = true

  key_name = "key1"

  tags = {
    "Name" = "${var.env_prefix}-servers"
  }
}
