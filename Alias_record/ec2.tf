
module "client_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.2.1"

  name                        = "${local.name}-client"
  instance_type               = "t2.micro"
  monitoring                  = false
  associate_public_ip_address = false
  key_name                    = var.ssh_key_pair
  subnet_id                   = module.client_vpc.private_subnets[0]
  vpc_security_group_ids      = [module.client_instance_security_group.security_group_id]

    tags = merge(local.common_tags, {
    Name = "${local.name}-client"
  })
}
