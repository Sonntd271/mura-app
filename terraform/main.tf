provider "aws" {
  region = var.region
}

resource "aws_key_pair" "stack-key" {
  key_name = "stack-key"
  public_key = file("../stack-key.pub")
}

# ---------- kOps ---------- #
resource "aws_instance" "mura-kops" {
  ami = var.amis[var.region]
  instance_type = "t2.micro"
  key_name = aws_key_pair.stack-key.key_name
  subnet_id = aws_subnet.mura-pub-1.id
  vpc_security_group_ids = [ aws_security_group.mura-kops-sg.id ]
  tags = {
    Name = "mura-kops"
    Project = "mura"
  }

  provisioner "file" {
    source = "../scripts/kops.sh"
    destination = "/tmp/kops.sh"
  }

  provisioner "remote-exec" {
    inline = [ 
      "sudo chmod u+x /tmp/kops.sh",
      "sudo /tmp/kops.sh",
      "cd"
    ]
  }

  connection {
    user = var.user
    private_key = file("../stack-key")
    host = self.public_ip
  }
}

# ---------- Memcache ---------- #
resource "aws_instance" "mura-memcache" {
  ami = var.amis[var.region]
  instance_type = "t2.micro"
  key_name = aws_key_pair.stack-key.key_name
  subnet_id = aws_subnet.mura-priv-1.id
  vpc_security_group_ids = [ aws_security_group.mura-memcache-sg.id ]
  tags = {
    Name = "mura-memcache"
    Project = "mura"
  }

  provisioner "file" {
    source = "../scripts/memcache.sh"
    destination = "/tmp/memcache.sh"
  }

  provisioner "remote-exec" {
    inline = [ 
      "sudo chmod u+x /tmp/memcache.sh",
      "sudo /tmp/memcache.sh",
      "cd"
    ]
  }

  connection {
    user = var.user
    private_key = file("../stack-key")
    bastion_host = aws_instance.mura-kops.private_ip
    host = aws_instance.mura-kops.public_ip
  }
}

# ---------- MySQL ---------- #
resource "aws_instance" "mura-mysql" {
  ami = var.amis[var.region]
  instance_type = "t2.micro"
  key_name = aws_key_pair.stack-key.key_name
  subnet_id = aws_subnet.mura-priv-1.id
  vpc_security_group_ids = [ aws_security_group.mura-mysql-sg.id ]
  tags = {
    Name = "mura-mysql"
    Project = "mura"
  }

  provisioner "file" {
    source = "../scripts/mysql.sh"
    destination = "/tmp/mysql.sh"
  }

  provisioner "file" {
    source = "../scripts/db-setup.sql"
    destination = "/tmp/db-setup.sql"
  }

  provisioner "remote-exec" {
    inline = [ 
      "sudo chmod u+x /tmp/mysql.sh",
      "sudo chmod u+r /tmp/db-setup.sql",
      "sudo /tmp/mysql.sh",
      "cd"
    ]
  }

  connection {
    user = var.user
    private_key = file("../stack-key")
    bastion_host = aws_instance.mura-kops.private_ip
    host = aws_instance.mura-kops.public_ip
  }
}