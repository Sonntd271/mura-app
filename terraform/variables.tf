variable "region" {
  type = string
  default = "us-east-1"
}

variable "zones" {
  type = map(any)
  default = {
    a = "us-east-1a"
    b = "us-east-1b"
  }
}

variable "myip" {
  type = string
  default = "myip" # Replace this
}

variable "amis" {
  type = map(any)
  default = {
    us-east-1 = "ami-0fc5d935ebf8bc3bc"
  }
}

variable "user" {
    type = string
    default = "ubuntu"
}
