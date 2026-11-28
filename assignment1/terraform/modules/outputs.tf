output "vpc_id" {
  description = "Id of the VPC."
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "Public subnet ids."
  value       = { for k, s in aws_subnet.public : k => s.id }
}

output "instance_ids" {
  description = "Web instance ids."
  value       = aws_instance.web[*].id
}

output "public_ips" {
  description = "Web instance public IPs."
  value       = aws_instance.web[*].public_ip
}

output "security_group_id" {
  description = "Web security group id."
  value       = aws_security_group.web.id
}

output "alarm_names" {
  description = "CloudWatch alarm names."
  value       = aws_cloudwatch_metric_alarm.cpu_high[*].alarm_name
}
