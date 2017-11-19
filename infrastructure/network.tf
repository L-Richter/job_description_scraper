resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "data_backend_1" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 4, 1)}"
  availability_zone = "${var.region}a"
}

resource "aws_subnet" "data_backend_2" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 4, 2)}"
  availability_zone = "${var.region}e"
}

resource "aws_security_group" "allow_db_connect" {
  name        = "allow_db_connect"
  vpc_id      = "${aws_vpc.main.id}"
  
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}
