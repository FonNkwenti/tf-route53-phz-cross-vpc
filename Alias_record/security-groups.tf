module "alb_sg" {
  source          = "terraform-aws-modules/security-group/aws"
  version         = "5.1.0"

  name            = "alb-sg"
  vpc_id          = module.services_vpc.vpc_id
  description     = "private instance security group"

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "allow HTTP from ALB"
    },
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = "0.0.0.0/0"
      description = "allow ICMP pings from ALB"
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
    tags          = merge(local.common_tags, {
    Name          = "${local.name}-alb-sg"
  })
}
module "app_sg" {
  source          = "terraform-aws-modules/security-group/aws"
  version         = "5.1.0"

  name            = "app-sg"
  vpc_id          = module.services_vpc.vpc_id
  description     = "private instance security group"

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "allow HTTP from ALB"
      security_group_id = module.alb_sg.security_group_id
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
    tags          = merge(local.common_tags, {
    Name          = "${local.name}-app-sg"
  })
}

module "client_instance_security_group" {
  source          = "terraform-aws-modules/security-group/aws"
  version         = "5.1.0"

  name            = "client-sg"
  vpc_id          = module.client_vpc.vpc_id
  description     = "private instance security group"

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
    tags          = merge(local.common_tags, {
    Name          = "${local.name}-client-sg"
  })
}


module "client_instance_connect_security_group" {
  source          = "terraform-aws-modules/security-group/aws"
  version         = "5.1.0"

  name            = "ec2-instance-connect-sg"
  vpc_id          = module.client_vpc.vpc_id
  description     = "private instance security group"

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
      description = "allow all traffic"
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
    tags          = merge(local.common_tags, {
    Name          = "${local.name}-icx-sg"
  })

}






