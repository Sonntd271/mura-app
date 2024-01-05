provider "aws" {
  region = var.region
}

resource "aws_key_pair" "stack-key" {
  key_name = "stack-key"
  public_key = file("../stack-key.pub")
}

# ---------- Memcache ---------- #
resource "aws_elasticache_cluster" "memcached" {
  cluster_id = "mura-memcached"
  engine = "memcached"
  node_type = "cache.t2.micro"
  num_cache_nodes = 1
  parameter_group_name = "default.memcached1.4"
  port = 11211
  subnet_group_name = aws_elasticache_subnet_group.mc-subnet.name
  tags = {
    Name = "mura-memcached"
    Project = "mura"
  }
}

resource "aws_elasticache_subnet_group" "mc-subnet" {
  name = "mc-subnet"
  subnet_ids = [ aws_subnet.mura-priv-1.id, aws_subnet.mura-priv-2.id ]
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