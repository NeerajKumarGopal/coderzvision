provider "aws" {
  region = "ap-south-1"  
}

resource "aws_instance" "lamp_server" {
  ami           = "ami-0dee22c13ea7a9a67"
  instance_type = "t2.micro"
  key_name      = "coderzvision"
  vpc_security_group_ids = [aws_security_group.lamp_sg.id]
  
  
  provisioner "file" {
    source      = "jenkins_key.pub"
    destination = "/home/ubuntu/.ssh/authorized_keys"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/jenkins_key")
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
      private_key = file("~/.ssh/jenkins_key")
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

resource "aws_security_group" "lamp_sg" {
  name = "lamp_security_group"

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
