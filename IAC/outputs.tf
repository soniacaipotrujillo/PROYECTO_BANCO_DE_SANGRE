output "ec2_public_ip" {
  description = "IP pública de la instancia EC2"
  value       = aws_instance.banco_sangre_ec2.public_ip
}

output "ec2_public_dns" {
  description = "DNS público de la instancia EC2"
  value       = aws_instance.banco_sangre_ec2.public_dns
}

