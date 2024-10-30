
module "services_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.services_vpc_cidr

  azs             = local.main_azs
  public_subnets  = [for k, v in local.main_azs : cidrsubnet(local.services_vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.main_azs : cidrsubnet(local.services_vpc_cidr, 8, k + 10)]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  manage_default_security_group = false
  manage_default_network_acl    = false

  tags = merge(local.common_tags, {
    Name = "${local.name}-services"
  })
}


resource "aws_route" "services_to_client" {
  count                  = length(module.services_vpc.private_route_table_ids)
  route_table_id         = element(module.services_vpc.private_route_table_ids, count.index)
  destination_cidr_block = local.client_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.main_tgw.id

}
resource "aws_route" "client_to_services" {
  count                  = length(module.client_vpc.private_route_table_ids)
  route_table_id         = element(module.client_vpc.private_route_table_ids, count.index)
  destination_cidr_block = local.services_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.main_tgw.id

}


module "services_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.2.1"

  name                        = "${local.name}-service"
  instance_type               = "t2.micro"
  monitoring                  = false
  associate_public_ip_address = false
  key_name                    = var.ssh_key_pair
  user_data_replace_on_change = true
  user_data_base64            = filebase64("${path.module}/webserver.sh")
  subnet_id                   = module.services_vpc.private_subnets[0]
  vpc_security_group_ids      = [module.services_instance_security_group.security_group_id]
}


module "services_instance_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "services-instance-sg"
  vpc_id      = module.services_vpc.vpc_id
  description = "services instance security group"

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "allow ssh"
    },
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = "0.0.0.0/0"
      description = "allow icmp pings"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "allow HTTP"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

}







