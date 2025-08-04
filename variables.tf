variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-northeast-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
  default = "key-pair" # キーペア名を記載
}

variable "my_ip" {
  description = "Your local IP address for SSH access"
  type        = string
  default = "1.21.51.15/32"
}