# ec2 instance
resource "aws_instance" "my_ec2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  associate_public_ip_address = true
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  user_data = var.user_data

  tags = {
    Name = "${var.region}-my_ec2"
  }
}