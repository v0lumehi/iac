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
write_files:
  - content: |
      DB_HOST="${aws_db_instance.nodejs_db.address}"
      DB_DB="${aws_db_instance.nodejs_db.name}"
      DB_USER="${aws_db_instance.nodejs_db.username}"
      DB_PASS="${aws_db_instance.nodejs_db.password}"
    owner: ubuntu:ubuntu
    path: /etc/nodejs.env
    permissions: '0644'
runcmd:
  - [ systemctl, daemon-reload ]
  - [ systemctl, enable, hello.service ]
  - [ systemctl, start, --no-block, hello.service ]
EOT

  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"

  key_name = "${var.prefix}"

  vpc_security_group_ids = [
    "${aws_security_group.nodejs_rds_demo_instance.id}",
  ]

  tags {
    Name = "${var.prefix}-nodejs-demo-instance"
  }
}

resource "aws_security_group" "nodejs_rds_demo_instance" {
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb.id}"]
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
