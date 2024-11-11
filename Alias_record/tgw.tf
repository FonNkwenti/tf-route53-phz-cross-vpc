resource "aws_ec2_transit_gateway" "main_tgw" {
  description                     = "Main region Transit Gateway"
  default_route_table_association = "disable"

  tags = merge(local.common_tags, {
    Name = "main-region-tgw"
  })

}

resource "aws_ec2_transit_gateway_vpc_attachment" "service_vpc_attachment" {
  subnet_ids                                      = module.services_vpc.private_subnets
  transit_gateway_id                              = aws_ec2_transit_gateway.main_tgw.id
  vpc_id                                          = module.services_vpc.vpc_id
  transit_gateway_default_route_table_association = "false"

  tags = merge(local.common_tags, {
    Name = "service-vpc-attachment"
  })

}
resource "aws_ec2_transit_gateway_vpc_attachment" "client_vpc_attachment" {
  vpc_id                                          = module.client_vpc.vpc_id
  transit_gateway_id                              = aws_ec2_transit_gateway.main_tgw.id
  subnet_ids                                      = module.client_vpc.private_subnets
  transit_gateway_default_route_table_association = "false"

  tags = merge(local.common_tags, {
    Name = "client-vpc-attachment"
  })

}

resource "aws_ec2_transit_gateway_route_table" "services_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.main_tgw.id

  tags = {
    Name = "main-tgw-Route-Table"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "service_vpc_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.service_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.services_rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "client_vpc_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.client_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.services_rt.id
}

resource "aws_ec2_transit_gateway_route" "service_to_client" {
  destination_cidr_block         = local.client_vpc_cidr
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.services_rt.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.client_vpc_attachment.id
}

resource "aws_ec2_transit_gateway_route" "client_to_service" {
  destination_cidr_block         = local.services_vpc_cidr
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.services_rt.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.service_vpc_attachment.id
}


