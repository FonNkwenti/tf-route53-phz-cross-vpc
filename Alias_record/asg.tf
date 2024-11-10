

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
#   version = "latest"
  version = "~> 6.0"

  name = "webserver-asg"

  min_size                  = 1
  max_size                  = 3
  desired_capacity         = 2
  wait_for_capacity_timeout = 0
  health_check_type        = "EC2"
  vpc_zone_identifier      = module.services_vpc.public_subnets


  launch_template_name        = "${local.name}-lt"
  launch_template_description = "Complete launch template example"
  update_default_version      = true

  image_id          = local.main_ami
  instance_type     = "t2.micro"
#   user_data         = filebase64("${path.module}/webserver.sh")
  user_data         = base64encode(local.user_data)
  ebs_optimized     = true
  enable_monitoring = true

  target_group_arns = module.alb.target_group_arns

  tags = {
    Name         = "asg"
  }
}
