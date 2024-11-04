provider "aws" {
  region = "us-east-1"  
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table_association" "my_route_table_assoc" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_security_group" "lamp_sg" {
  name        = "lamp_security_group"
  description = "security group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "lamp_server" {
  ami           = "ami-0866a3c8686eaeeba"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id
  key_name      = "coderzvision"
  vpc_security_group_ids = [aws_security_group.lamp_sg.id]

  provisioner "file" {
    source      = "C:/Neeraj/coderzvision-assessement/coderzvision/terraform/coderzvision_key.pub"
    destination = "/home/ubuntu/.ssh/authorized_keys"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("C:/Neeraj/coderzvision-assessement/coderzvision/terraform/coderzvision.pem")
      host        = self.public_ip
    }
  }
  
  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.ssh",
      "cat /tmp/jenkins_key.pub >> ~/.ssh/authorized_keys",
      "chmod 600 ~/.ssh/authorized_keys"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("C:/Neeraj/coderzvision-assessement/coderzvision/terraform/coderzvision.pem")
      host        = self.public_ip
    }
  }
 
  
  user_data = <<-EOF
              #!/bin/bash
	      sudo su
              apt update -y
              apt install -y apache2 mysql-server php php-mysql
              systemctl start apache2
              systemctl enable apache2
              apt update -y
              apt install -y docker.io docker-compose
              systemctl start docker
              systemctl enable docker
              EOF

  tags = {
    Name = "LAMP_Server"
  }
}
