output "public-ip" {
  value = "${aws_instance.nodejs_rds_demo.*.public_ip}"
}

output "loadbalancer" {
  value = "${aws_elb.nodejs_demo.*.dns_name}"
}

output "FQDN" {
  value = "${aws_route53_record.www.*.fqdn}"
}
