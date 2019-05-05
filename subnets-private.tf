// Private subnets

resource "aws_subnet" "private" {
  count = 3

  cidr_block = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 10 )}"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${element(var.azs, count.index)}"

  tags {
    Name = "${var.prefix}-private-${count.index}"
  }
}

// Route Table for private subnets
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"

  // Route all non-local traffic to the NAT Gateway
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags {
    Name = "${var.prefix}-private"
  }
}

// Attach the private subnets to the private route table
resource "aws_route_table_association" "private" {
  count = "${length(var.azs)}"
  route_table_id = "${aws_route_table.private.id}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
}

// Create elastic ip for the NAT Gateway
resource "aws_eip" "nat" {
  // Internet gateway must exist before Elastic IP can be created
  depends_on = ["aws_internet_gateway.public"]
  vpc = true

  tags {
    Name = "${var.prefix}-natgw"
  }
}

// Create a NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  // Select the first private subnet
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}" // Yes, count.index works even without count
}