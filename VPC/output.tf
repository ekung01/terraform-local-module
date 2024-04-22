#security group output

output "security_group_id" {
  description = "The ID of the security group"
  value = aws_security_group.my-sg.id
}

#subnet output

output "public_subnet1_id" {
  description = "The ID of the public subnet"
  value = aws_subnet.publicSubnet1.id
}

output "public_subnet2_id" {
  description = "The ID of the public subnet"
  value = aws_subnet.publicSubnet2.id
}
