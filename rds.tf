resource "aws_security_group" "nodejs_rds_demo_db" {
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = ["${aws_security_group.nodejs_rds_demo_instance.id}"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.prefix}-nodejs-demo"
  }
}

resource "aws_db_subnet_group" "nodejs_db" {
  name       = "${var.prefix}-main"
  subnet_ids = ["${aws_subnet.private.*.id}"]

  tags = {
    Name = "${var.prefix}-db-subnet-group"
  }
}

resource "aws_db_instance" "nodejs_db" {
  skip_final_snapshot  = true
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.medium"
  name                 = "mydb"
  username             = "test"
  password             = "testtest"
  parameter_group_name = "default.mysql5.7"
  identifier           = "${var.prefix}-nodejs-db"
  db_subnet_group_name = "${aws_db_subnet_group.nodejs_db.name}"
  vpc_security_group_ids = ["${aws_security_group.nodejs_rds_demo_db.id}"]
}
