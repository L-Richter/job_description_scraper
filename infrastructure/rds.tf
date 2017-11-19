resource "aws_db_subnet_group" "postgresql" {
  subnet_ids = ["${aws_subnet.data_backend_1.id}",
                "${aws_subnet.data_backend_2.id}"]
}


resource "aws_db_instance" "postgresql" {
  allocated_storage          = "8"
  engine                     = "postgres"
  engine_version             = "9.6.5"
  identifier                 = "pg-descriptions"
  instance_class             = "db.t2.micro"
  storage_type               = "gp2"
  name                       = "descriptions"
  password                   = "${var.database_password}"
  username                   = "${var.database_username}"
  backup_retention_period    = "4"
  backup_window              = "06:00-07:00"
  multi_az                   = "false"
  port                       = "5432"
  publicly_accessible        = "false"
  db_subnet_group_name       = "${aws_db_subnet_group.postgresql.name}"
}
