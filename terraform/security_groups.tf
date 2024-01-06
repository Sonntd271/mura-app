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

resource "aws_security_group" "mura-mysql-sg" {
  vpc_id = aws_vpc.mura.id
  name = "mura-mysql-sg"
  description = "Security group for MySQL Database"

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
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [ aws_security_group.mura-kops-sg.id ]
  }

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [ aws_security_group.mura-kops-sg.id ]
  }

  tags = {
    Name = "mura-mysql-sg"
    Project = "mura"
  }
}

resource "aws_security_group" "mura-memcache-sg" {
  vpc_id = aws_vpc.mura.id
  name = "mura-memcache-sg"
  description = "Security group for Memcached"

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

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [ aws_security_group.mura-kops-sg.id ]
  }

  ingress {
    from_port = 11211
    to_port = 11211
    protocol = "tcp"
    security_groups = [ aws_security_group.mura-kops-sg.id ]
  }

  tags = {
    Name = "mura-memcache-sg"
    Project = "mura"
  }
}