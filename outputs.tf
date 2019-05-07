output "public-ip" {
  value = "${aws_instance.nodejs_demo.*.public_ip}"
}

output "a-record-name" {
  value = "${aws_route53_record.www.*.name}"
}
