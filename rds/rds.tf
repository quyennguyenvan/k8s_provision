resource "random_password" "password" {
  length  = 16
  special = false
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = var.db_indentifier

  engine                = var.db_engine
  engine_version        = var.db_engine_version
  instance_class        = var.db_instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  name                  = var.db_name
  username              = var.db_username_login
  password              = random_password.password.result
  port                  = var.db_port

  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  multi_az                            = var.multi_az
  vpc_security_group_ids              = [aws_security_group.db-sg.id]
  maintenance_window                  = "Mon:00:00-Mon:03:00"
  backup_window                       = "03:00-06:00"
  backup_retention_period             = var.backup_retention_period
  monitoring_interval                 = "30"
  monitoring_role_name                = "${var.db_indentifier}_MonitoringRole"
  create_monitoring_role              = true
  subnet_ids                          = var.db_subnet_ids
  db_subnet_group_name                = var.db_subnet_group_id
  family                              = var.db_parameter_family_group
  major_engine_version                = var.major_engine_version
  deletion_protection                 = var.deletion_protection
  cross_region_replica                = var.cross_region_replica
  publicly_accessible                 = var.publicly_accessible
  apply_immediately                   = var.apply_immediately
  storage_encrypted                   = var.storage_encrypted
  storage_type                        = var.storage_type
  delete_automated_backups            = var.delete_automated_backups
  create_db_option_group              = var.create_db_option_group
  option_group_timeouts               = var.option_group_timeouts
  tags                                = var.default_tags

}

#SSM
resource "aws_ssm_parameter" "default_ssm_parameter_identifier" {
  count     = var.enable_ssm_storage_sensitive_data ? 1 : 0
  name      = format("/rds/db/%s/identifier", var.db_indentifier)
  value     = var.db_indentifier
  type      = "String"
  tags      = var.default_tags
  overwrite = true
}

resource "aws_ssm_parameter" "default_ssm_parameter_endpoint" {
  count     = var.enable_ssm_storage_sensitive_data ? 1 : 0
  name      = format("/rds/db/%s/endpoint", var.db_indentifier)
  value     = module.db.db_instance_endpoint
  type      = "String"
  tags      = var.default_tags
  overwrite = true
}

resource "aws_ssm_parameter" "default_postgres_ssm_parameter_username" {
  count     = var.enable_ssm_storage_sensitive_data ? 1 : 0
  name      = format("/rds/db/%s/superuser/username", var.db_indentifier)
  value     = module.db.db_instance_username
  type      = "String"
  tags      = var.default_tags
  overwrite = true
}

resource "aws_ssm_parameter" "default_ssm_parameter_password" {
  count     = var.enable_ssm_storage_sensitive_data ? 1 : 0
  name      = format("/rds/db/%s/superuser/password", var.db_indentifier)
  value     = module.db.db_master_password
  type      = "String"
  tags      = var.default_tags
  overwrite = true
}
resource "aws_ssm_parameter" "default_db_name" {
  count     = var.enable_ssm_storage_sensitive_data ? 1 : 0
  name      = format("/rds/db/%s/dbname", var.db_name)
  value     = module.db.db_instance_name
  type      = "String"
  tags      = var.default_tags
  overwrite = true
}

#==========================================================
# Output
#==========================================================
output "db_instance_address" {
  value = module.db.db_instance_address
}
output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = module.db.db_instance_arn
}
output "db_instance_name" {
  description = "The database name"
  value       = module.db.db_instance_name
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = module.db.db_instance_username
  sensitive   = false
}

output "db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = random_password.password.result
  sensitive   = false
}
