// Public subnets

resource "aws_subnet" "public" {
  count = 3

  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index )}"
  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "${element(var.azs, count.index)}"

  tags {
    Name = "${var.prefix}-public-${count.index}"
  }
}

// Route Table for public subnets
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  // Route all non-local traffic to the internet
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public.id}"
  }

  tags {
    Name = "${var.prefix}-public"
  }
}

// Attach the public subnets to the public route table
resource "aws_route_table_association" "public" {
  count          = "${length(var.azs)}"
  route_table_id = "${aws_route_table.public.id}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
}

// Create a Internet Gateway (needed for useing public IPs in EC2)
resource "aws_internet_gateway" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.prefix}-igw"
  }
}
