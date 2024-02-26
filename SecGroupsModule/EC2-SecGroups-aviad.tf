data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}


locals {
    inbound_ports = [22, 80, 443]
}

resource "aws_security_group" "terraform" {
    name = "terraform"
    description = "terraform security group for EC2 instance"

    dynamic "ingress"{
        for_each = local.inbound_ports
        content {
            from_port   = ingress.value
            to_port     = ingress.value
            protocol    = "tcp"
            cidr_blocks = ingress.value == 22? ["${chomp(data.http.myip.response_body)}/32"] : [ "0.0.0.0/0" ]
        }
    }
    egress {
        protocol = "tcp"
        from_port = 0
        to_port = 0
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}
output "security_group_id" {
  value = aws_security_group.terraform.id
}