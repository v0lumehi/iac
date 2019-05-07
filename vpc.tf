data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = ["run_ami"]
  }
}

data "aws_subnet" "subnet" {
  vpc_id = "${data.aws_vpc.vpc.id}"
  availability_zone = "eu-west-1b"
}
