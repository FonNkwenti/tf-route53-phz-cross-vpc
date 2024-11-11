
resource "aws_lb" "alb" {
  name               = "alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = module.services_vpc.private_subnets
  # security_groups    = [module.services_instance_security_group.security_group_id]
  security_groups    = [aws_security_group.alb_sg.id]

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true 
  enable_zonal_shift = true

  tags = merge(
    local.common_tags,{ 
      Name = "my_alb"
      }
  
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name        = "alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.services_vpc.vpc_id
  target_type = "instance"
  load_balancing_cross_zone_enabled = true
  load_balancing_algorithm_type = "round_robin"

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
      Name = "my-alb-tg"
      }
    )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
  tags = local.common_tags

}



resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-lt"
  image_id      = var.service_ami
  # image_id      = local.main_ami
  instance_type = "t2.micro"
  # user_data = filebase64("${path.module}/webserver.sh")
  network_interfaces {
    associate_public_ip_address = false 
    subnet_id = element(module.services_vpc.private_subnets, 0)
    security_groups  = [module.services_instance_security_group.security_group_id]
    # security_groups  = [aws_security_group.application_http.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "lt"
    })
  }

  lifecycle {
    create_before_destroy = true
  }

}
resource "aws_autoscaling_group" "asg" {
  desired_capacity   = 2
  max_size           = 3
  min_size           = 2
  vpc_zone_identifier = module.services_vpc.private_subnets
  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_attachment" "alb" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn   = aws_lb_target_group.alb_tg.arn
}


resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP/HTTPS traffic from internet"
  vpc_id      = module.services_vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  tags = merge (local.common_tags, {
    Name = "alb-sg"
  })
}

resource "aws_security_group" "application_http" {
  name        = "application-http"
  description = "Allow HTTP/HTTPS traffic from consumers"
  vpc_id      = module.services_vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    security_groups = [aws_security_group.alb_sg.id]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  tags = merge (local.common_tags, {
    Name = "app-sg"
  })
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

