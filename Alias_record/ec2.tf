
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
  # subnet_id                   = module.services_vpc.public_subnets[0]
  subnet_id                   = module.services_vpc.private_subnets[0]
  vpc_security_group_ids      = [module.services_instance_security_group.security_group_id]
  # private_ip = cidrhost(module.services_vpc.public_subnets_cidr_blocks[0], 100)
  private_ip = cidrhost(module.services_vpc.private_subnets_cidr_blocks[0], 100)
}


# module "services_instance" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "5.2.1"
#   name                        = "${local.name}-service"
#   instance_type               = "t2.micro"
#   monitoring                  = false
#   associate_public_ip_address = true
#   key_name                    = var.ssh_key_pair
#   user_data_replace_on_change = true
#   user_data_base64            = filebase64("${path.module}/webserver.sh")
#   subnet_id                   = module.services_vpc.public_subnets[0]
#   # subnet_id                   = module.services_vpc.private_subnets[0]
#   vpc_security_group_ids      = [module.services_instance_security_group.security_group_id]
#   private_ip = cidrhost(module.services_vpc.public_subnets_cidr_blocks[0], 100)
#   # private_ip = cidrhost(module.services_vpc.private_subnets_cidr_blocks[0], 100)
# }



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
}
