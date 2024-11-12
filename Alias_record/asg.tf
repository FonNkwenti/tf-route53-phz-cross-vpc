
resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-lt"
  image_id      = var.service_ami
  instance_type = "t2.micro"
  network_interfaces {
    associate_public_ip_address = false 
    subnet_id = element(module.services_vpc.private_subnets, 0)
    security_groups = [module.app_sg.security_group_id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${local.name}-app-lt"
    })
  }

  lifecycle {
    create_before_destroy = true
  }

}
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity   = 2
  max_size           = 3
  min_size           = 2
  vpc_zone_identifier = module.services_vpc.private_subnets
  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
}
