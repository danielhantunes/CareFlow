output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "instance_id" {
  value = aws_instance.private.id
}

output "instance_private_ip" {
  value = aws_instance.private.private_ip
}

output "ssm_endpoint_ids" {
  value = [
    aws_vpc_endpoint.ssm.id,
    aws_vpc_endpoint.ssmmessages.id,
    aws_vpc_endpoint.ec2messages.id
  ]
}
