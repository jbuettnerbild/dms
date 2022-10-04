# dms
Terraform module for AWS DMS 


# overview
    the module create a target RDS Instance and if set also the replicas for the master instance.
    Its also create a dms instance and endpoints for source and target RDS Instance. And a migration 
    task that not startet automaticly. 

# example
```
module "dms" {
  count  = var.enable_dms_replica ? 1 : 0
  source = "../../modules/dms"

  depends_on = [aws_db_instance.master, random_string.database_pass]

  dms_instance_name = var.override_db_master_name != "" ? var.override_db_master_name : "${local.basename}"

  source_address                       = aws_db_instance.master.address
  source_subnet_ids                    = data.terraform_remote_state.db-vpc.outputs.private_subnets
  source_vpc_security_group_ids        = [aws_security_group.sg-db.id]
  source_database_name                 = aws_db_instance.master.db_name
  source_engine                        = var.engine
  source_password                      = random_string.database_pass.result
  source_username                      = var.username
  source_port                          = var.port
  source_instance_subnet_group_name    = aws_db_subnet_group.default.name
  dms_replication_instance_kms_key_arn = data.aws_kms_key.dms.arn

  target_engine                        = var.engine
  target_db_multi_az                   = var.db_multi_az
  target_allocated_storage             = var.target_allocated_storage != "" ? var.target_allocated_storage : var.allocated_storage
  target_instance_name                 = var.target_instance_name
  target_instance_type                 = var.target_instance_type
  target_instance_engine_version       = var.target_instance_engine_version
  target_instance_parameter_group_name = var.target_instance_parameter_group_name
  target_replica_count                 = var.replica_count
  target_storage_encrypted             = var.target_storage_encrypted
  target_instance_kms_key_id           = var.target_storage_encrypted ? data.aws_kms_key.rds.arn : null
}
```

# ToDos
+ Set the rds.logical_replication parameter in your DB CLUSTER parameter group to 1
+ Set wal_sender_timeout parameter to 0 in your DB CLUSTER parameter group
    + see https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.PostgreSQL.html#CHAP_Source.PostgreSQL.RDSPostgreSQL
+ reboot the source RDS Instance
    + use AWS Systems Manager for schedule reboot.
    + see https://aws.amazon.com/de/blogs/database/schedule-amazon-rds-stop-and-start-using-aws-systems-manager/
+ start manually the migration task
    + on errors see https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Tasks.AssessmentReport1.html
+ take care of hibernate sequence
    + AWS DMS doesn't migrate your secondary indexes, sequences, default values, stored procedures, triggers, synonyms, views, and other schema objects that aren't specifically related to data migration.
+ switch the application to the target RDS Instance
+ Stop the migration task
+ Remove the target Instance and Replicas from terraform state before removing all resources.
    + `terragrunt state rm "module.dms[0].aws_db_instance.target_master_instance"`

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.target_master_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_instance.target_read_replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_dms_endpoint.source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_endpoint) | resource |
| [aws_dms_endpoint.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_endpoint) | resource |
| [aws_dms_replication_instance.dms_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_replication_instance) | resource |
| [aws_dms_replication_subnet_group.dms-replication-subnet-group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_replication_subnet_group) | resource |
| [aws_dms_replication_task.initial](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_replication_task) | resource |
| [aws_iam_role.dms-access-for-endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.dms-cloudwatch-logs-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.dms-vpc-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.dms-access-for-endpoint-AmazonDMSRedshiftS3Role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.dms_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | (Optional, Default: empty string) ARN for the certificate. | `string` | `""` | no |
| <a name="input_dms_availability_zone"></a> [dms\_availability\_zone](#input\_dms\_availability\_zone) | n/a | `string` | `"eu-central-1a"` | no |
| <a name="input_dms_instance_class"></a> [dms\_instance\_class](#input\_dms\_instance\_class) | n/a | `string` | `"dms.t3.micro"` | no |
| <a name="input_dms_instance_name"></a> [dms\_instance\_name](#input\_dms\_instance\_name) | n/a | `string` | n/a | yes |
| <a name="input_dms_replication_instance_kms_key_arn"></a> [dms\_replication\_instance\_kms\_key\_arn](#input\_dms\_replication\_instance\_kms\_key\_arn) | n/a | `string` | `null` | no |
| <a name="input_dms_replication_instance_multi_az"></a> [dms\_replication\_instance\_multi\_az](#input\_dms\_replication\_instance\_multi\_az) | n/a | `bool` | `false` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | n/a | `string` | `"3.4.7"` | no |
| <a name="input_extra_connection_attributes"></a> [extra\_connection\_attributes](#input\_extra\_connection\_attributes) | (Optional) Additional attributes associated with the connection. For available attributes see Using Extra Connection Attributes with AWS Database Migration Service. | `string` | `""` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | n/a | `string` | `null` | no |
| <a name="input_source_address"></a> [source\_address](#input\_source\_address) | endpoint address of source | `string` | n/a | yes |
| <a name="input_source_database_name"></a> [source\_database\_name](#input\_source\_database\_name) | Required) Database endpoint identifier. Identifiers must contain from 1 to 255 alphanumeric characters or hyphens, begin with a letter, contain only ASCII letters, digits, and hyphens, not end with a hyphen, and not contain two consecutive hyphens. | `string` | `"source"` | no |
| <a name="input_source_engine"></a> [source\_engine](#input\_source\_engine) | (Required) Type of engine for the source endpoint. Valid values are aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, elasticsearch, kafka, kinesis, mariadb, mongodb, mysql, opensearch, oracle, postgres, redshift, s3, sqlserver, sybase. Please note that some of engine names are available only for target endpoint type (e.g. redshift). | `string` | n/a | yes |
| <a name="input_source_instance_subnet_group_name"></a> [source\_instance\_subnet\_group\_name](#input\_source\_instance\_subnet\_group\_name) | n/a | `string` | n/a | yes |
| <a name="input_source_password"></a> [source\_password](#input\_source\_password) | (Optional) Password to be used to login to the endpoint database. | `string` | `"test"` | no |
| <a name="input_source_port"></a> [source\_port](#input\_source\_port) | n/a | `number` | `5432` | no |
| <a name="input_source_subnet_ids"></a> [source\_subnet\_ids](#input\_source\_subnet\_ids) | n/a | `list(string)` | `[]` | no |
| <a name="input_source_username"></a> [source\_username](#input\_source\_username) | (Optional) User name to be used to login to the endpoint database. | `string` | `"test"` | no |
| <a name="input_source_vpc_security_group_ids"></a> [source\_vpc\_security\_group\_ids](#input\_source\_vpc\_security\_group\_ids) | n/a | `list(string)` | `[]` | no |
| <a name="input_target_allocated_storage"></a> [target\_allocated\_storage](#input\_target\_allocated\_storage) | The acclocated storage of the target database | `number` | `20` | no |
| <a name="input_target_availability_zones"></a> [target\_availability\_zones](#input\_target\_availability\_zones) | AZ for the replicas | `list(string)` | <pre>[<br>  "eu-central-1a",<br>  "eu-central-1b",<br>  "eu-central-1c"<br>]</pre> | no |
| <a name="input_target_db_multi_az"></a> [target\_db\_multi\_az](#input\_target\_db\_multi\_az) | (Optional) Specifies if the target RDS instance is multi-AZ | `bool` | `false` | no |
| <a name="input_target_engine"></a> [target\_engine](#input\_target\_engine) | (Required) Type of engine for the target endpoint. Valid values are aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, elasticsearch, kafka, kinesis, mariadb, mongodb, mysql, opensearch, oracle, postgres, redshift, s3, sqlserver, sybase. Please note that some of engine names are available only for target endpoint type (e.g. redshift). | `string` | n/a | yes |
| <a name="input_target_instance_engine_version"></a> [target\_instance\_engine\_version](#input\_target\_instance\_engine\_version) | the engine version of the target db | `string` | `"13.4"` | no |
| <a name="input_target_instance_kms_key_id"></a> [target\_instance\_kms\_key\_id](#input\_target\_instance\_kms\_key\_id) | n/a | `string` | `null` | no |
| <a name="input_target_instance_name"></a> [target\_instance\_name](#input\_target\_instance\_name) | Name of the target replica | `string` | `"test"` | no |
| <a name="input_target_instance_parameter_group_name"></a> [target\_instance\_parameter\_group\_name](#input\_target\_instance\_parameter\_group\_name) | n/a | `string` | n/a | yes |
| <a name="input_target_instance_type"></a> [target\_instance\_type](#input\_target\_instance\_type) | instance type of the target instance | `string` | `"db.t3.micro"` | no |
| <a name="input_target_replica_count"></a> [target\_replica\_count](#input\_target\_replica\_count) | Amount of the target read replicas | `number` | `0` | no |
| <a name="input_target_storage_encrypted"></a> [target\_storage\_encrypted](#input\_target\_storage\_encrypted) | (Optional) Specifies whether the DB instance is encrypted. The default is true if not specified. | `bool` | `true` | no |
| <a name="input_target_storage_type"></a> [target\_storage\_type](#input\_target\_storage\_type) | n/a | `string` | `"gp2"` | no |
| <a name="input_upgrade_apply_immediately"></a> [upgrade\_apply\_immediately](#input\_upgrade\_apply\_immediately) | (Optional) Specifies whether any database modifications are applied immediately, or during the next maintenance window. Default is false. See Amazon RDS Documentation for more information. | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->