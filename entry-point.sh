#!bin/bash
sudo yum update -y && sudo yum install -y docker
sudo systemctll start docker
sudo usermode -aG docker ec2-user
docker run -p 8080:80 nginx
  