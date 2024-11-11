data "aws_availability_zones" "available" {
}

data "aws_caller_identity" "main" {
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

}

locals {
  dir_name = basename(path.cwd)
  name     = "${var.project_name}-${var.environment}"

  services_vpc_cidr = "10.15.0.0/16"
  client_vpc_cidr   = "10.10.0.0/16"

  main_azs = slice(data.aws_availability_zones.available.names, 0, 2)
  main_az1 = data.aws_availability_zones.available.names[0]
  main_az2 = data.aws_availability_zones.available.names[1]

  main_ami = data.aws_ami.amazon_linux_2.id

  instance_name = "${local.name}-saas"

  common_tags = {
    Service = var.service_name
  }

}

