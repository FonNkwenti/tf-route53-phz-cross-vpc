
resource "aws_lb" "app_alb" {
  name               = "alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = module.services_vpc.private_subnets
  security_groups    = [module.alb_sg.security_group_id]

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true 
  enable_zonal_shift = true

  tags               = merge(
    local.common_tags,{ 
      Name           = "${local.name}-app-alb"
      }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "app_tg" {
  name                              = "app-tg"
  port                              = 80
  protocol                          = "HTTP"
  vpc_id                            = module.services_vpc.vpc_id
  target_type                       = "instance"
  load_balancing_cross_zone_enabled = true
  load_balancing_algorithm_type     = "round_robin"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
    port                = 80
    protocol            = "HTTP"
  }
    tags = merge(
    local.common_tags,{ 
      Name = "${local.name}-app-tg"
      }
    )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn  = aws_lb.app_alb.arn
  port               = 80
  protocol           = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
  tags = local.common_tags

}

resource "aws_autoscaling_attachment" "app_alb_att" {
  autoscaling_group_name = aws_autoscaling_group.app_asg.id
  lb_target_group_arn    = aws_lb_target_group.app_tg.arn
}

