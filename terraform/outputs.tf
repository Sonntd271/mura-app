output "kops-public-ip" {
  value = aws_instance.mura-kops.public_ip
}