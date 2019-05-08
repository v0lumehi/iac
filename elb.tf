data "aws_route53_zone" "main" {
  name = "${var.dns_zone}"
}

# Create a new load balancer
resource "aws_elb" "nodejs_demo" {
  count              = "${var.loadbalancer_count}"
  name               = "${var.prefix}-nodejs-elb"

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 443
    lb_protocol       = "https"
    ssl_certificate_id = "${var.certificate_arn}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }

  instances                   = ["${aws_instance.nodejs_rds_demo.*.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  subnets = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.elb.id}"]

  tags = {
    Name = "${var.prefix}-elb"
  }
}

resource "aws_security_group" "elb" {
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "${var.prefix}-elb-sec-group"
  }
}

resource "aws_route53_record" "www" {
  count = "${var.loadbalancer_count}"
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "${var.prefix}-${count.index + 1}"
  type = "A"

  alias {
    name = "${aws_elb.nodejs_demo.dns_name}"
    zone_id = "${aws_elb.nodejs_demo.zone_id}"
    evaluate_target_health = true
  }
}
