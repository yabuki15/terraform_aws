output "bastion_public_dns" {
  description = "Public DNS of the bastion host for SSH access."
  value       = aws_instance.bastion.public_dns
}

output "private_instance_ips" {
  description = "Private IP addresses of the private instances."
  value       = { for k, inst in aws_instance.private : k => inst.private_ip }
}

output "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer."
  value       = aws_lb.main.dns_name
}