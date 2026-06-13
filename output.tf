output "instance_public_ip" {
  value = aws_instance.my_ec2_custom.public_ip
}