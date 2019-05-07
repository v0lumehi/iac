data "aws_route53_zone" "main" {
  name = "${var.dns_zone}"
}

data "aws_ami" "nodejs_demo" {
  most_recent = true
  owners = ["self", "099720109477"]

  filter {
    name = "name"
    values = ["*nodejs-demo-*"]
  }
  filter {
    name = "state"
    values = ["available"]
  }
}

resource "aws_instance" "nodejs_demo" {
  count = "${var.host_count}"
  ami = "${data.aws_ami.nodejs_demo.id}"
  instance_type = "t3.small"

  user_data = <<EOT
#cloud-config
preserve_hostname: false
manage_etc_hosts: true
hostname: nodejs-demo-${count.index + 1}
fqdn: nodejs-demo-${count.index + 1}
EOT

  associate_public_ip_address = true
  subnet_id = "${data.aws_subnet.subnet.id}"

  key_name = "${var.prefix}"
  vpc_security_group_ids = [
    "${aws_security_group.nodejs_demo.id}"
  ]

  tags {
    Name = "${var.prefix}"
  }
}

resource "aws_security_group" "nodejs_demo" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.prefix}"
  }


}

resource "aws_route53_record" "www" {
  count = "${var.host_count}"
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "${var.prefix}-${count.index + 1}"
  type    = "A"
  ttl     = "60"
  records = ["${element(aws_instance.nodejs_demo.*.public_ip, count.index)}"]
}
