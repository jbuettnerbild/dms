resource "aws_db_instance" "target_master_instance" {
  identifier                  = "${var.target_instance_name}-master"
  db_name                     = var.source_database_name
  allocated_storage           = var.target_allocated_storage
  max_allocated_storage       = var.target_allocated_storage * 2
  engine                      = var.target_engine
  engine_version              = var.target_instance_engine_version
  instance_class              = var.target_instance_type
  password                    = var.source_password
  username                    = var.source_username
  db_subnet_group_name        = var.source_instance_subnet_group_name
  parameter_group_name        = var.target_instance_parameter_group_name
  vpc_security_group_ids      = var.source_vpc_security_group_ids
  multi_az                    = var.target_db_multi_az
  storage_type                = var.target_storage_type
  publicly_accessible         = false
  port                        = var.source_port
  backup_retention_period     = 5
  apply_immediately           = var.upgrade_apply_immediately
  kms_key_id                  = var.target_instance_kms_key_id
  storage_encrypted           = var.target_storage_encrypted
  copy_tags_to_snapshot       = true
  allow_major_version_upgrade = true
  skip_final_snapshot         = true
  final_snapshot_identifier   = "${var.target_instance_name}-dms-target-final-${uuid()}"
}

resource "aws_db_instance" "target_read_replica" {
  count = var.target_replica_count

  identifier             = "${var.target_instance_name}-replica${count.index + 1}"
  replicate_source_db    = aws_db_instance.target_master_instance.identifier
  availability_zone      = element(var.target_availability_zones, count.index)
  allocated_storage      = var.target_allocated_storage
  max_allocated_storage  = var.target_allocated_storage * 2
  instance_class         = var.target_instance_type
  apply_immediately      = true
  kms_key_id             = var.target_instance_kms_key_id
  storage_encrypted      = var.target_storage_encrypted
  vpc_security_group_ids = var.source_vpc_security_group_ids
  parameter_group_name   = var.target_instance_parameter_group_name
  skip_final_snapshot    = true
  storage_type           = var.target_storage_type
  publicly_accessible    = false
  port                   = var.source_port
}