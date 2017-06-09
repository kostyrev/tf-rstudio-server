provider "aws" {
  region = "us-east-1"
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

  owners = ["762089471837"]
}

data "aws_vpc" "vpc" {
  default = true
}

data "aws_security_group" "rstudio" {
  name = "rstudio"
}

resource "aws_spot_instance_request" "rstudio" {
  ami                  = "${data.aws_ami.rstudio.id}"
  instance_type        = "m4.xlarge"
  spot_price           = "0.105"
  wait_for_fulfillment = true
  spot_type            = "one-time"

  vpc_security_group_ids = [
    "${data.aws_security_group.rstudio.id}",
  ]
}

output "public dns" {
  value = ["${aws_spot_instance_request.rstudio.public_dns}"]
}

output "public address" {
  value = ["${aws_spot_instance_request.rstudio.public_ip}"]
}

output "instance type" {
  value = ["${aws_spot_instance_request.rstudio.instance_type}"]
}
