output "bastion-public-ip" {
  value = aws_eip.bastion-eip.public_ip
}

output "private-server-ip" {
  value = aws_instance.private-server.private_ip
}