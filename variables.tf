variable "target_allocated_storage" {
  type = number
  description = "The acclocated storage of the target database"
  default = 20
}

variable "upgrade_apply_immediately" {
  type = bool
  default = false
  description = "(Optional) Specifies whether any database modifications are applied immediately, or during the next maintenance window. Default is false. See Amazon RDS Documentation for more information."
}

variable "dms_availability_zone" {
  type = string
  default = "eu-central-1a"
}

variable "engine_version" {
  type = string
  default = "3.4.7"
}

variable "kms_key_arn" {
  type = string
  default = null
}

variable "target_db_multi_az" {
  default = false
  type    = bool
  description = "(Optional) Specifies if the target RDS instance is multi-AZ"
}

variable "dms_instance_class" {
  type = string
  default = "dms.t3.micro"
}

variable "dms_instance_name" {
  type = string
}

variable "source_subnet_ids" {
  type = list(string)
  default = []
}

variable "source_vpc_security_group_ids" {
  type = list(string)
  default = []
}

variable "target_storage_encrypted" {
  default = true
  type = bool
  description = "(Optional) Specifies whether the DB instance is encrypted. The default is true if not specified."
}

variable "source_database_name" {
  type = string
  default = "source"
  description = "Required) Database endpoint identifier. Identifiers must contain from 1 to 255 alphanumeric characters or hyphens, begin with a letter, contain only ASCII letters, digits, and hyphens, not end with a hyphen, and not contain two consecutive hyphens."
}

variable "source_address" {
  type = string
  description = "endpoint address of source"
}

variable "source_engine" {
  type = string
  description = "(Required) Type of engine for the source endpoint. Valid values are aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, elasticsearch, kafka, kinesis, mariadb, mongodb, mysql, opensearch, oracle, postgres, redshift, s3, sqlserver, sybase. Please note that some of engine names are available only for target endpoint type (e.g. redshift)."
}

variable "target_engine" {
  type = string
  description = "(Required) Type of engine for the target endpoint. Valid values are aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, elasticsearch, kafka, kinesis, mariadb, mongodb, mysql, opensearch, oracle, postgres, redshift, s3, sqlserver, sybase. Please note that some of engine names are available only for target endpoint type (e.g. redshift)."
}

variable "extra_connection_attributes" {
  type = string
  default = ""
  description = "(Optional) Additional attributes associated with the connection. For available attributes see Using Extra Connection Attributes with AWS Database Migration Service."
}

variable "source_password" {
  type = string
  default = "test"
  description = "(Optional) Password to be used to login to the endpoint database."
}

variable "source_username" {
  type = string
  default = "test"
  description = "(Optional) User name to be used to login to the endpoint database."
}

variable "certificate_arn" {
  type = string
  default = ""
  description = "(Optional, Default: empty string) ARN for the certificate."
}

variable "source_port" {
  default = 5432
}

variable "target_instance_name" {
  type = string
  default = "test"
  description = "Name of the target replica"
}

variable "target_instance_engine_version" {
  type = string
  default = "13.4"
  description = "the engine version of the target db"
}

variable "target_instance_type" {
  type = string
  default = "db.t3.micro"
  description = "instance type of the target instance"
}

variable "target_instance_parameter_group_name" {
  type = string
}

variable "target_instance_kms_key_id" {
  type = string
  default = null
}

variable "source_instance_subnet_group_name" {
  type = string
}

variable "target_replica_count" {
  type        = number
  default     = 0
  description = "Amount of the target read replicas"
}

variable "target_storage_type" {
  type = string
  default = "gp2"
}

variable "target_availability_zones" {
  type        = list(string)
  default     = [
    "eu-central-1a",
    "eu-central-1b",
    "eu-central-1c"]
  description = "AZ for the replicas"
}

variable "dms_replication_instance_multi_az" {
  type = bool
  default = false
}

variable "dms_replication_instance_kms_key_arn" {
  type = string
  default = null
}