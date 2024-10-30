
resource "aws_route53_zone" "my_app" {
  name     = var.app_name
  vpc {
    vpc_id = module.services_vpc.vpc_id
  }
  comment = "Private hosted zone for ${var.app_name}"

  tags = {
    Name = "${local.name}-phz"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "my_app" {
  zone_id = aws_route53_zone.my_app.id
  name    = "server.${var.app_name}"
  type    = "A"
  ttl     = 300
  records = [ module.services_instance.private_ip ]

  lifecycle {
    create_before_destroy = true
  }
}


##############


resource "aws_route53_zone_association" "client_vpc_association" {
  zone_id = aws_route53_zone.my_app.id
  vpc_id  = module.client_vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}



