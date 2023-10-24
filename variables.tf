# VPC
variable "vpc_block" {
  description = "VPC block in CIDR notation"
  type = string
  default = "10.14.0.0/16"
}

variable "public_block" {
  description = "Public subnet block in CIDR notation"
  type = string
  default = "10.14.0.0/24"
}

variable "private_block" {
  description = "Private subnet block in CIDR notation"
  type = string
  default = "10.14.1.0/24"
}

# EC2
variable "instance_type" {
  description = "Type of EC2 instance"
  type = string
  default = "t2.micro"
}

variable "instance_ami" {
  description = "AMI image ID"
  type = string
  default = "ami-0afcbcee3dfbce929"
}

variable "load_balancer_ip_address" { 
  description = "The load balancer becomes the bastion host"
  type = string
  default = "10.14.0.11"
}

variable "app_server_1_ip_address" {
  description = "Application server"
  type = string
  default = "10.14.1.11"
}

variable "app_server_2_ip_address" {
  description = "Application server"
  type = string
  default = "10.14.1.12"
}
