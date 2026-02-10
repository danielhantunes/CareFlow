output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "instance_sg_id" {
  value = aws_security_group.instance.id
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
