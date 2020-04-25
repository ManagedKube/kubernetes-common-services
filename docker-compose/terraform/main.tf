# terraform {
#   # The configuration for this backend will be filled in by Terragrunt
#   backend "s3" {}
# }

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    name         = "${var.name}"
    resource_for = "${var.resource_for}"
    env          = "${var.env}"
    group        = "${var.group}"
    application  = "${var.application}"
    managed_by   = "Terraform"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
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

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_instance" "instance" {
  ami                     = "${var.amis}"
  instance_type           = "${var.instance_type}"
  
  key_name                = "${var.key_name}"
  monitoring              = "${var.monitoring}"
  disable_api_termination = "${var.disable_api_termination}"
  
  vpc_security_group_ids  = [aws_security_group.allow_tls.id]
  subnet_id               = var.subnet_id

  user_data = "${file("${path.module}/userdata.sh")}"

  tags = "${merge(local.common_tags, map("Name", "${var.name}"))}"
}
