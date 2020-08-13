/*
resource "aws_db_instance" "default" {
  depends_on             = ["aws_security_group.default"]
  identifier             = "${var.identifier}"
  allocated_storage      = "${var.storage}"
  engine                 = "${var.engine}"
  engine_version         = "${lookup(var.engine_version, var.engine)}"
  instance_class         = "${var.instance_class}"
  name                   = "${var.db_name}"
  username               = "${var.username}"
  password               = "${var.password}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.default.id}"
  #below property is only for testing.
  skip_final_snapshot     = "true"
  backup_retention_period = 30
  kms_key_id              = "${aws_kms_key.ny_key1.key_id}"

  tags = {
    Name        = "NY RDS Database"
    Environment = "Dev"
    "app:name"  = "test-rds"
    #owner       = "NY"
    #version     = "1.0"
  }
}

resource "aws_db_subnet_group" "default" {
  name        = "main_subnet_group"
  description = "Our main group of subnets"
  subnet_ids  = ["${aws_subnet.subnet_1.id}", "${aws_subnet.subnet_2.id}"]
}


resource "aws_kms_key" "ny_key1" {
  description             = "KMS key 1"
  deletion_window_in_days = 10
}
*/