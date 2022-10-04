# Database Migration Service requires the below IAM Roles to be created before
# replication instances can be created. See the DMS Documentation for
# additional information: https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Security.html#CHAP_Security.APIRole
#  * dms-vpc-role
#  * dms-cloudwatch-logs-role
#  * dms-access-for-endpoint

data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "dms-access-for-endpoint" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "${var.dms_instance_name}-dms-access-for-endpoint"
}

resource "aws_iam_role_policy_attachment" "dms-access-for-endpoint-AmazonDMSRedshiftS3Role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
  role       = aws_iam_role.dms-access-for-endpoint.name
}

resource "aws_iam_role" "dms-cloudwatch-logs-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "${var.dms_instance_name}-dms-cloudwatch-logs-role"
}

resource "aws_iam_role_policy_attachment" "dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
  role       = aws_iam_role.dms-cloudwatch-logs-role.name
}

resource "aws_iam_role" "dms-vpc-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "${var.dms_instance_name}-dms-vpc-role"
}

resource "aws_iam_role_policy_attachment" "dms-vpc-role-AmazonDMSVPCManagementRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms-vpc-role.name
}

# Create a new replication instance
resource "aws_dms_replication_instance" "dms_instance" {
  allocated_storage            = var.target_allocated_storage
  apply_immediately            = var.upgrade_apply_immediately
  auto_minor_version_upgrade   = true
  availability_zone            = var.dms_availability_zone
  engine_version               = var.engine_version
  kms_key_arn                  = var.dms_replication_instance_kms_key_arn
  multi_az                     = var.dms_replication_instance_multi_az
  preferred_maintenance_window = "sun:10:30-sun:14:30"
  publicly_accessible          = false
  replication_instance_class   = var.dms_instance_class
  replication_instance_id      = var.dms_instance_name
  replication_subnet_group_id  = aws_dms_replication_subnet_group.dms-replication-subnet-group.id

  tags = {
    Name = var.dms_instance_name
  }

  vpc_security_group_ids = var.source_vpc_security_group_ids

  depends_on = [
    aws_iam_role_policy_attachment.dms-access-for-endpoint-AmazonDMSRedshiftS3Role,
    aws_iam_role_policy_attachment.dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole,
    aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole
  ]
}

resource "aws_dms_replication_subnet_group" "dms-replication-subnet-group" {
  replication_subnet_group_description = "DMS replication subnet group for ${var.dms_instance_name}"
  replication_subnet_group_id          = "${var.dms_instance_name}-dms-replication"

  subnet_ids = var.source_subnet_ids

  tags = {
    Name = "${var.dms_instance_name}-dms-replication"
  }
}

resource "aws_dms_endpoint" "source" {
  certificate_arn             = var.certificate_arn
  database_name               = var.source_database_name
  server_name                 = var.source_address
  endpoint_id                 = "${var.dms_instance_name}-source"
  endpoint_type               = "source"
  engine_name                 = var.source_engine
  extra_connection_attributes = var.extra_connection_attributes
  kms_key_arn                 = var.dms_replication_instance_kms_key_arn
  password                    = var.source_password
  port                        = var.source_port
  ssl_mode                    = "none"

  tags = {
    Name = "${var.dms_instance_name}-source"
  }

  username = var.source_username
}

resource "aws_dms_endpoint" "target" {
  certificate_arn             = var.certificate_arn
  database_name               = aws_db_instance.target_master_instance.db_name
  server_name                 = aws_db_instance.target_master_instance.address
  endpoint_id                 = "${var.dms_instance_name}-target"
  endpoint_type               = "target"
  engine_name                 = var.target_engine
  extra_connection_attributes = var.extra_connection_attributes
  kms_key_arn                 = var.dms_replication_instance_kms_key_arn
  port                        = var.source_port
  ssl_mode                    = "none"
  username                    = var.source_username
  password                    = var.source_password

  tags = {
    Name = "${var.dms_instance_name}-target"
  }

}

resource "aws_dms_replication_task" "initial" {
  migration_type            = "full-load-and-cdc"
  replication_instance_arn  = aws_dms_replication_instance.dms_instance.replication_instance_arn
  replication_task_id       = var.dms_instance_name
  source_endpoint_arn       = aws_dms_endpoint.source.endpoint_arn
  table_mappings            = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"%\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"
  start_replication_task    = false

  tags = {
    Name = "${var.dms_instance_name}-task"
  }

  target_endpoint_arn = aws_dms_endpoint.target.endpoint_arn
}