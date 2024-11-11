
module "services_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name}-services-vpc"
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
    Name = "${local.name}-services-vpc"
  })
}



module "client_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name}-client-vpc"
  cidr = local.client_vpc_cidr

  azs             = local.main_azs
  private_subnets = [for k, v in local.main_azs : cidrsubnet(local.client_vpc_cidr, 8, k + 10)]

  enable_nat_gateway = false
  single_nat_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${local.name}-client-vpc"
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


resource "aws_ec2_instance_connect_endpoint" "client_instance" {
  subnet_id  = element(module.client_vpc.private_subnets, 0)  
  depends_on = [module.client_instance]
  security_group_ids = [module.client_instance_connect_security_group.security_group_id]

  tags = local.common_tags
}
