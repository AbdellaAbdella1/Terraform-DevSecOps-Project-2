# Terraform configuration for AWS EC2 instance with Docker and Nginx
resource "aws_key_pair" "deployer" {
  key_name   = "deployer"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDE7EitQm1drC8I6VU6v6cvtWhd0yX0zq34Zn6x3rIJ6g2s9bE+5g+uW16xC0kEA3kVSPEWfdn5xc79btL0ZpTaXVN4cF0PnVIvssk6UsN7XCdyyehULojGpLNj2eQI0eJUA9clDziRAtHN3ziqdHhXXa1hwij4C0shUqhYvnyYCyfmhTJurCYpRlN94KVpma2/YIvGCOcuJMonNFXWUby24k1ux0G/n/LmS8GEkXWL3PZk7DjAeJpVOAel1EX4WOC50QjbXZR9e9hCm3qHzJwJyw4dpDvN9rJFU0Zp4zofaEgohvPyHkyXz6h1ED7pvimzijK1CADJuKcSISi0xQ4/"
}

# Security group
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
}

# EC2 instance
resource "aws_instance" "docker_host" {
  ami             = "ami-0c02fb55956c7d316"
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.allow_ssh_http.id]
  subnet_id       = "subnet-0c821fc83655f26a7"  # Replace with your subnet ID

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              systemctl enable docker
              docker pull nginx
              docker run -d -p 80:80 nginx
              EOF

  tags = {
    Name = "DockerHost"
  }
}
