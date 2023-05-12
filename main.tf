module "vpc" {
  source                                 = "./network"
  vpc_cidr                               = local.aws_account_env_config[terraform.workspace].vpc_cidr
  vpc_name                               = local.aws_account_env_config[terraform.workspace].vpc_name
  enable_nat_gateway                     = local.aws_account_env_config[terraform.workspace].enable_nat_gateway
  single_nat_gateway                     = local.aws_account_env_config[terraform.workspace].single_nat_gateway
  enable_dns_hostnames                   = local.aws_account_env_config[terraform.workspace].enable_dns_hostnames
  create_database_subnet_group           = local.aws_account_env_config[terraform.workspace].create_database_subnet_group
  create_database_subnet_route_table     = local.aws_account_env_config[terraform.workspace].create_database_subnet_route_table
  create_database_internet_gateway_route = local.aws_account_env_config[terraform.workspace].create_database_internet_gateway_route
  enable_flow_log                        = local.aws_account_env_config[terraform.workspace].enable_flow_log
  create_flow_log_cloudwatch_iam_role    = local.aws_account_env_config[terraform.workspace].create_flow_log_cloudwatch_iam_role
  create_flow_log_cloudwatch_log_group   = local.aws_account_env_config[terraform.workspace].create_flow_log_cloudwatch_log_group
  default_tags = merge(
    local.aws_account_env_config[terraform.workspace].extend_tag,
    var.default_tag
  )
}

module "rds" {
  depends_on                          = [module.vpc]
  source                              = "./rds"
  for_each                            = local.aws_account_env_config[terraform.workspace].rds
  db_indentifier                      = each.value.db_indentifier
  db_engine                           = each.value.db_engine
  db_engine_version                   = each.value.db_engine_version
  db_instance_class                   = each.value.db_instance_class
  allocated_storage                   = each.value.allocated_storage
  max_allocated_storage               = each.value.max_allocated_storage
  db_name                             = each.value.db_name
  db_username_login                   = each.value.db_username_login
  db_port                             = each.value.db_port
  iam_database_authentication_enabled = each.value.iam_database_authentication_enabled
  multi_az                            = each.value.multi_az
  backup_retention_period             = each.value.backup_retention_period
  db_subnet_ids                       = module.vpc.vpc_private_subnet_ids
  db_subnet_group_id                  = module.vpc.vpc_db_subnet_group_id
  db_parameter_family_group           = each.value.db_parameter_family_group
  major_engine_version                = each.value.major_engine_version
  deletion_protection                 = each.value.deletion_protection
  cross_region_replica                = each.value.cross_region_replica
  publicly_accessible                 = each.value.publicly_accessible
  apply_immediately                   = each.value.apply_immediately
  storage_encrypted                   = each.value.storage_encrypted
  storage_type                        = each.value.storage_type
  delete_automated_backups            = each.value.delete_automated_backups
  create_db_option_group              = each.value.create_db_option_group
  option_group_timeouts               = each.value.option_group_timeouts
  enable_ssm_storage_sensitive_data   = each.value.enable_ssm_storage_sensitive_data
  vpc_cidr                            = module.vpc.vpc_cidr
  vpc_id                              = module.vpc.vpc_id
  default_tags                        = var.default_tag
}

module "ec2config" {
  depends_on = [module.vpc]
  source     = "./ec2instance_config"

  key_pair_name       = local.aws_account_env_config[terraform.workspace].key_pair.key_name_prefix
  key_pair_public_key = local.aws_account_env_config[terraform.workspace].key_pair.key_pair_public_key
  for_each            = local.aws_account_env_config[terraform.workspace].sgs
  sg_name             = each.value.name
  sg_description      = each.value.description
  sg_sets             = each.value.sg_sets
  vpc_id              = module.vpc.vpc_id
  default_tags        = var.default_tag
}


module "eks" {
  depends_on = [
    module.vpc
  ]
  source = "./eks"

  vpc_id                                         = module.vpc.vpc_id
  private_subnet_ids                             = module.vpc.vpc_private_subnet_ids
  control_plane_subnet_ids                       = module.vpc.intra_subnet_id
  env_prefix                                     = local.aws_account_env_config[terraform.workspace].env_prefix
  cluster_name                                   = local.aws_account_env_config[terraform.workspace].eks_config.cluster_name
  cluster_version                                = local.aws_account_env_config[terraform.workspace].eks_config.cluster_version
  max_size                                       = local.aws_account_env_config[terraform.workspace].eks_config.max_size
  eks_managed_node_group_defaults_instance_types = local.aws_account_env_config[terraform.workspace].eks_config.eks_managed_node_group_defaults_instance_types
  manage_aws_auth_configmap                      = local.aws_account_env_config[terraform.workspace].eks_config.manage_aws_auth_configmap
  instance_types                                 = local.aws_account_env_config[terraform.workspace].eks_config.instance_types
  aws_auth_users                                 = local.aws_account_env_config[terraform.workspace].eks_config.aws_auth_users
  aws_auth_accounts                              = local.aws_account_env_config[terraform.workspace].eks_config.aws_auth_accounts
  cluster_endpoint_public_access_cidrs           = local.aws_account_env_config[terraform.workspace].eks_config.cluster_endpoint_public_access_cidrs
  default_tags                                   = var.default_tag
}
