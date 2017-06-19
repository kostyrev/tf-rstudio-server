variable "key_name" {
  description = "How to name SSH keypair and security group in AWS."
}

variable "public_key_path" {
  description = "Enter the path to the SSH Public Key to add to AWS."
  default     = "~/.ssh/id_rsa.pub"
}

variable "region" {
  type = "string"
}

variable "spot_price" {
  type        = "string"
  description = "The price to request on the spot market"
}

terraform {
  required_version = ">= 0.9.4"
}

provider "aws" {
  region = "${var.region}"
}

data "aws_ami" "rstudio" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["fasten-RStudio-1.0.143_R-3.4.0_ubuntu-16.04-LTS-64bit"]
  }

  owners = ["828328152120"]
}

data "aws_vpc" "vpc" {
  default = true
}

resource "aws_security_group" "rstudio" {
  name        = "${format("rstudio-%s", var.key_name)}"
  description = "Allow ping, ssh and http over 80 port"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  # Allow echo-requests
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow http
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

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_spot_instance_request" "rstudio" {
  ami                         = "${data.aws_ami.rstudio.id}"
  instance_type               = "r4.xlarge"
  spot_price                  = "${var.spot_price}"
  wait_for_fulfillment        = true
  spot_type                   = "one-time"
  associate_public_ip_address = true
  key_name                    = "${var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.rstudio.id}",
  ]
}

output "public_dns" {
  value = ["${aws_spot_instance_request.rstudio.public_dns}"]
}

output "public_address" {
  value = ["${aws_spot_instance_request.rstudio.public_ip}"]
}

output "instance_type" {
  value = ["${aws_spot_instance_request.rstudio.instance_type}"]
}
