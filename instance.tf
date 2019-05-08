data "aws_route53_zone" "main" {
  name = "${var.dns_zone}"
}

data "aws_ami" "nodejs_rds_demo" {
  most_recent = true
  owners      = ["self", "099720109477"]

  filter {
    name   = "name"
    values = ["nodejs-rds-demo-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "nodejs_rds_demo" {
  count         = "${var.host_count}"
  ami           = "${data.aws_ami.nodejs_rds_demo.id}"
  instance_type = "t3.small"

  user_data = <<EOT
#cloud-config
preserve_hostname: false
manage_etc_hosts: true
hostname: nodejs-rds-demo-${count.index + 1}
fqdn: nodejs-rds-demo-${count.index + 1}
EOT

  associate_public_ip_address = true
  subnet_id                   = "${element(aws_subnet.public.*.id, count.index)}"

  key_name = "${var.prefix}"

  vpc_security_group_ids = [
    "${aws_security_group.nodejs_rds_demo_instance.id}",
  ]

  tags {
    Name = "${var.prefix}-nodejs-demo-instance"
  }

  connection {
    type  = "ssh"
    user  = "ubuntu"
    agent = true
  }

  provisioner "file" {
    content     = "${data.template_file.nodejsenv.rendered}"
    destination = "/tmp/nodejs.env"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/nodejs.env /etc/",
      "sudo systemctl enable hello.service",
      "sudo systemctl start hello.service",
    ]
  }
}

resource "aws_security_group" "nodejs_rds_demo_instance" {
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.prefix}"
  }
}

resource "aws_route53_record" "www" {
  count   = "${var.host_count}"
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "${var.prefix}-${count.index + 1}-nodejs-rds-demo"
  type    = "A"
  ttl     = "60"
  records = ["${element(aws_instance.nodejs_rds_demo.*.public_ip, count.index)}"]
}

data "template_file" "nodejsenv" {
  template = "${file("./templates/nodejsenv.tpl")}"

  vars = {
    template_db_host     = "${aws_db_instance.nodejs_db.address}"
    template_db_name     = "${aws_db_instance.nodejs_db.name}"
    template_db_user     = "${aws_db_instance.nodejs_db.username}"
    template_db_password = "${aws_db_instance.nodejs_db.password}"
  }
}
