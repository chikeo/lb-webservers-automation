resource "aws_security_group" "andela-allow-ssh" {
  name        = "andela-allow-ssh"
  description = "Andela security group that allows ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "andela-allow-ssh"
  }
}

resource "aws_security_group" "andela-allow-http" {
  name        = "andela-allow-http"
  description = "Andela security group that allows http"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "andela-allow-http"
  }
}

resource "aws_key_pair" "andela_id_rsa" {
  key_name   = "andela_id_rsa"
  public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
}

resource "aws_instance" "machine2" {
  ami                    = "${lookup(var.AMI_ID, var.AWS_REGION)}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.andela_id_rsa.key_name}"
  vpc_security_group_ids = ["${aws_security_group.andela-allow-ssh.id}", "${aws_security_group.andela-allow-http.id}"]

  tags {
    Name = "webserver1-machine2"
  }

  provisioner "local-exec" {
    command = "echo \"[webservers]\n${aws_instance.machine2.public_ip} ansible_connection=ssh ansible_ssh_user=ubuntu\"  > ../ansible/hosts"
  }
}

resource "aws_instance" "machine3" {
  ami                    = "${lookup(var.AMI_ID, var.AWS_REGION)}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.andela_id_rsa.key_name}"
  vpc_security_group_ids = ["${aws_security_group.andela-allow-ssh.id}", "${aws_security_group.andela-allow-http.id}"]

  tags {
    Name = "webserver2-machine3"
  }

  provisioner "local-exec" {
    command = "echo \"${aws_instance.machine3.public_ip} ansible_connection=ssh ansible_ssh_user=ubuntu\"  >> ../ansible/hosts"
  }
}

resource "aws_instance" "machine1" {
  ami                    = "${lookup(var.AMI_ID, var.AWS_REGION)}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.andela_id_rsa.key_name}"
  vpc_security_group_ids = ["${aws_security_group.andela-allow-ssh.id}", "${aws_security_group.andela-allow-http.id}"]

  tags {
    Name = "loadbalancer-machine1"
  }

  provisioner "local-exec" {
    command = "echo \"[loadbalancers]\n${aws_instance.machine1.public_ip} ansible_connection=ssh ansible_ssh_user=ubuntu\"  >> ../ansible/hosts"
  }
}
