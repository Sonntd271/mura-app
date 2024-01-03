resource "aws_vpc" "mura" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "mura-vpc"
  }
}

resource "aws_subnet" "mura-pub-1" {
  vpc_id = aws_vpc.mura.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = var.zones.a
  tags = {
    Name = "mura-pub-1"
  }
}

resource "aws_subnet" "mura-pub-2" {
  vpc_id = aws_vpc.mura.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = var.zones.b
  tags = {
    Name = "mura-pub-2"
  }
}

resource "aws_subnet" "mura-priv-1" {
  vpc_id = aws_vpc.mura.id
  cidr_block = "10.0.3.0/24"
  availability_zone = var.zones.a
  tags = {
    Name = "mura-priv-1"
  }
}

resource "aws_subnet" "mura-priv-2" {
  vpc_id = aws_vpc.mura.id
  cidr_block = "10.0.4.0/24"
  availability_zone = var.zones.b
  tags = {
    Name = "mura-priv-2"
  }
}

resource "aws_internet_gateway" "mura-igw" {
  vpc_id = aws_vpc.mura.id
  tags = {
    Name = "mura-igw"
  }
}

resource "aws_eip" "mura-nat-eip" {
  instance = null
  tags = {
    Name = "mura-nat-eip"
  }
}

resource "aws_nat_gateway" "mura-nat" {
  subnet_id = aws_subnet.mura-pub-1.id
  allocation_id = aws_eip.mura-nat-eip.id
  tags = {
    Name = "mura-nat"
  }
}

resource "aws_route_table" "mura-pub-rt" {
  vpc_id = aws_vpc.mura.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mura-igw.id
  }
  tags = {
    Name = "mura-pub-rt"
  }
}

resource "aws_route_table" "mura-priv-rt" {
  vpc_id = aws_vpc.mura.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.mura-nat.id
  }
  tags = {
    Name = "mura-priv-rt"
  }
}

resource "aws_route_table_association" "mura-pub-1-assc" {
  subnet_id = aws_subnet.mura-pub-1.id
  route_table_id = aws_route_table.mura-pub-rt.id
}

resource "aws_route_table_association" "mura-pub-2-assc" {
  subnet_id = aws_subnet.mura-pub-2.id
  route_table_id = aws_route_table.mura-pub-rt.id
}

resource "aws_route_table_association" "mura-priv-1-assc" {
  subnet_id = aws_subnet.mura-priv-1.id
  route_table_id = aws_route_table.mura-priv-rt.id
}

resource "aws_route_table_association" "mura-priv-2-assc" {
  subnet_id = aws_subnet.mura-priv-2.id
  route_table_id = aws_route_table.mura-priv-rt.id
}