variable "project_name" {
  description = "The name of the project."
  type        = string
  default     = "nlb-snat-test"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-northeast-1"
}

variable "my_ip" {
  description = "Your local IP address for SSH access"
  type        = string
  default = "1.21.51.15/32"
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
  default = "key-pair"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}
