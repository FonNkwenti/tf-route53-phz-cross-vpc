output "client_instance_private_ip" {
  value = module.client_instance.private_ip
}

output "connect_to_client_instance" { 
    description = "The AWS cli command to connect to your EC2 instance through the connect point"
    value = "aws ec2-instance-connect ssh --instance-id ${module.client_instance.id} --os-user ec2-user --connection-type eice --region ${var.main_region}"
}

output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "alb_alias_fqdn" {
  value = aws_route53_record.alb_alias.fqdn 
}
