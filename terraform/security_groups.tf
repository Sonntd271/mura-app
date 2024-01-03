resource "aws_security_group" "mura-kops-sg" {
  vpc_id = aws_vpc.mura.id
  name = "mura-kops-sg"
  description = "Security group for kOps controller"

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ var.myip ]
  }

  tags = {
    Name = "mura-kops-sg"
    Project = "mura"
  }
}