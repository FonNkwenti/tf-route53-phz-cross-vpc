variable "main_region" {
  type    = string
  default = "us-east-1"
}

variable "account_id" {
  type    = number
  default = 123456789012
}
variable "app_name" {
  type    = string
  default = "my_app"
}

variable "environment" {
  description = "The environment for deployment"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "The name of the project"
  default     = "tf-project-name"
  type        = string
}

variable "cost_center" {
  description = "Cost center or budget code"
  type        = string
  default     = "237"
}

variable "service_name" {
  description = "Type of application"
  type        = string
  default     = "web"
}
variable "service_ami" {
  description = "AMI of private service"
  type        = string
  default     = "ami-1234564f06d663d2"
}


variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR block of the VPC"
}

variable "ssh_key_pair" {
  type        = string
  description = "name of existing SSH key pair"

}