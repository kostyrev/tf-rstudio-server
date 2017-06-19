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

data "aws_security_group" "rstudio" {
  name = "rstudio"
}

resource "aws_spot_instance_request" "rstudio" {
  ami                         = "${data.aws_ami.rstudio.id}"
  instance_type               = "r4.xlarge"
  spot_price                  = "${var.spot_price}"
  wait_for_fulfillment        = true
  spot_type                   = "one-time"
  associate_public_ip_address = true

  vpc_security_group_ids = [
    "${data.aws_security_group.rstudio.id}",
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
