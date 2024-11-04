# Using Terraform to build Route53 Private Hosted Zone across VPCs
This project demonstrates how to use Terraform to Amazon Route53 Private Hosted Zone and share with VPCs in the same AWS Region

## Prerequisites
Before you begin, ensure you have the following:

- 2 AWS accounts
- Terraform installed locally
- AWS CLI installed and configured with appropriate access credentials profiles for the 2 AWS accounts

## Architecture
<!-- ![Diagram](cross-account-privatelink-cross-account.webp) -->

---

## Project Structure
```bash
|- provider.tf
|- local.tf
|- main.tf
|- output.tf
|- route53.tf
|- tgw.tf
|- variables.tf
|- terraform.tfvars

```
---
## Getting Started

Clone this repository:

   ```bash
   git clone https://github.com/FonNkwenti/tf-route53-phz-cross-vpc.git
   ```


### Set up the PrivateLink Endpoint Service in the Service Producer's account
1. Navigate to the project directory:
   ```bash
   cd tf-route53-phz-cross-vpc/
   ```
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Review and modify `variables.tf` if required
4. Create a `terraform.tfvars` file in the root directory and pass in values for the variables.
   ```bash
      region               = "eu-west-1"
      account_id           = <<aws_account_id_for_service_producer>>
      environment          = "dev"
      project_name         = "tf-route53-phz-cross-vpc"
      service_name         = "route53"
      cost_center          = "237"
   ```
5. Apply the Terraform configure:
   ```bash
   terraform apply --auto-approve
   ```
6. Your will have the following outputs: 
   ```bash
   Apply complete! Resources: 27 added, 0 changed, 0 destroyed.

   Outputs:


   ```
7.   


## Testing
1. Connect to the EC2 instance using the EC2 Instance connect Terraform output command
2. Test connectivity to the Endpoint service via the interface VPC endpoint
   ```bash
      sh-4.2$ curl http://myapp.internal
      <html>
      <head>
         <title>Instance Information</title>
      </head>
      <body>
         <h1>Instance Information</h1>
         <p><strong>Instance Name:</strong> i-0cbd519ffe7583c5d</p>
         <p><strong>Private IP:</strong> 10.255.10.40</p>
         <p><strong>Public IP:</strong> No public IP assigned</p>
         <p><strong>Availability Zone:</strong> eu-west-1a</p>
         <p><strong>Region:</strong> eu-west-1</p>
      </body>
      </html>
   ```

## Clean up

### Remove all resources created by Terraform in the Service Consumer's account
1. Navigate to the  `tf-route53-phz-cross-vpc` directory:
   ```bash
   cd  tf-route53-phz-cross-vpc/
   ```
2. Destroy all Terraform resources:
   ```bash
   terraform destroy --auto-apply
   ```
---



<!-- ## Step-by-step Turial -->


## License

This project is licensed under the MIT License - see the `LICENSE` file for details.
