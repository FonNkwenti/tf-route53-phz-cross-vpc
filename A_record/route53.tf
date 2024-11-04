
resource "aws_route53_zone" "my_service" {
  name     = var.service_name
  vpc {
    vpc_id = module.services_vpc.vpc_id
  }
  comment = "Private hosted zone for ${var.service_name}"

  tags = {
    Name = "${var.service_name}-phz"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [ vpc ]
  }
}

resource "aws_route53_record" "my_app" {
  zone_id = aws_route53_zone.my_service.id
  name    = "app.${var.service_name}"
  type    = "A"
  ttl     = 300
  records = [ module.services_instance.private_ip ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_zone_association" "client_vpc_association" {
  zone_id = aws_route53_zone.my_service.id
  vpc_id  = module.client_vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}



