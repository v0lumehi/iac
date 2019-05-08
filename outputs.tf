output "public-ip" {
  value = "${aws_instance.nodejs_rds_demo.*.public_ip}"
}

output "a-record-name-instance" {
  value = "${aws_route53_record.www.*.name}"
}
