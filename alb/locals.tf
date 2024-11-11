data "aws_availability_zones" "available" {
}

data "aws_caller_identity" "main" {
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

}

locals {
  dir_name = basename(path.cwd)
  name     = "${var.project_name}-${var.environment}"

  services_vpc_cidr = "10.15.0.0/16"
  client_vpc_cidr   = "10.10.0.0/16"

  main_azs = slice(data.aws_availability_zones.available.names, 0, 2)
  main_az1 = data.aws_availability_zones.available.names[0]
  main_az2 = data.aws_availability_zones.available.names[1]

  main_ami = data.aws_ami.amazon_linux_2.id

  instance_name = "${local.name}-saas"

  common_tags = {
    Service = var.service_name
  }

    user_data = <<-EOT
    #!/bin/bash
        
    # Install necessary packages
    yum update -y
    yum install -y httpd curl

    # Start the web server
    systemctl start httpd
    systemctl enable httpd

    # Get instance metadata
    INSTANCE_NAME=$(curl http://169.254.169.254/latest/meta-data/instance-id)
    PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
    # PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
    AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
    if [ -z "$PUBLIC_IP" ]; then
        PUBLIC_IP="No public IP assigned"
    fi

    # Create a simple HTML file to display the instance information
    cat <<EOF > /var/www/html/index.html
    <html>
    <head>
        <title>Instance Information</title>
    </head>
    <body>
        <h1>Instance Information</h1>
        <p><strong>Instance Name:</strong> $INSTANCE_NAME</p>
        <p><strong>Private IP:</strong> $PRIVATE_IP</p>
        <p><strong>Public IP:</strong> $PUBLIC_IP</p>
        <p><strong>Availability Zone:</strong> $AVAILABILITY_ZONE</p>
        <p><strong>Region:</strong> $REGION</p>
    </body>
    </html>
  EOT

}

