# output.tf

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.axa_wassim_vpc.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.axa_wassim_public_subnet_1.id
}
output "public_subnet_id_2" {
  description = "The ID of the public subnet"
  value       = aws_subnet.axa_wassim_public_subnet_2.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = aws_subnet.axa_wassim_private_subnet.id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.axa_wassim_igw.id
}

output "public_security_group_id" {
  description = "The ID of the public security group"
  value       = aws_security_group.axa_wassim_public_sg.id
}

output "private_security_group_id" {
  description = "The ID of the private security group"
  value       = aws_security_group.axa_wassim_private_sg.id
}

output "load_balancer_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.axa_wassim_lb.dns_name
}

output "autoscaling_group_name" {
  description = "The name of the Auto Scaling Group"
  value       = aws_autoscaling_group.axa_wassim_asg.name
}

output "private_instance_id" {
  description = "The ID of the private EC2 instance"
  value       = aws_instance.axa_wassim_private_ec2.id
}
