module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "webserver-alb"

  load_balancer_type = "application"
  vpc_id             = module.services_vpc.vpc_id
  subnets            = module.services_vpc.public_subnets
  security_groups    = [module.alb_sg.security_group_id]

  target_groups = [
    {
      name_prefix          = "web-"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type         = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path               = "/"
        port               = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol           = "HTTP"
        matcher            = "200-399"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Name = "alb"
  }
}

