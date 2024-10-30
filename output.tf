

output "services_instance_private_ip" {
  value = module.services_instance.private_ip
}
output "client_instance_private_ip" {
  value = module.client_instance.private_ip
}


output "cli_cmd" { 
    description = "The AWS cli command to connect to your EC2 instance through the connect point"
    value = "aws ec2-instance-connect ssh --instance-id ${module.services_instance.id} --os-user ec2-user --connection-type eice --region ${var.main_region}"
}

output "connect_to_client_instance" { 
    description = "The AWS cli command to connect to your EC2 instance through the connect point"
    value = "aws ec2-instance-connect ssh --instance-id ${module.client_instance.id} --os-user ec2-user --connection-type eice --region ${var.main_region}"
}