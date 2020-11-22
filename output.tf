output "subnet_ids" {
    value = tolist(aws_subnet.public.*.id)
}

output "subnets" {
    value = aws_subnet.public
}

output "vpc_id" {
    value = aws_vpc.network.id
}

output "sg_id" {
    value = aws_security_group.project_network.id
}