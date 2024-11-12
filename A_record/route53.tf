
resource "aws_route53_zone" "phz" {
  name      = var.service_name
  vpc {
    vpc_id  = module.services_vpc.vpc_id
  }
  comment   = "Private hosted zone for ${var.service_name}"

  tags      = merge(local.common_tags, {
    Name    = "${var.service_name}-phz"
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [ vpc ]
  }
}

resource "aws_route53_record" "instance_a" {
  zone_id                 = aws_route53_zone.phz.id
  name                    = "app.${var.service_name}"
  type                    = "A"
  ttl                     = 300
  records                 = [ module.services_instance.private_ip ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_zone_association" "client_vpc_association" {
  zone_id = aws_route53_zone.phz.id
  vpc_id  = module.client_vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}



