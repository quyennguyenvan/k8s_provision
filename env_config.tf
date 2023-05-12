variable "default_tag" {
  description = "The default tag of resources"
  type        = map(string)
  default = {
    "ProvisionedBy" = "Terraform"
    "Owner"         = "DevOpsTeam"
  }
}

locals {
  aws_account_env_config = {
    dev = {
      env_prefix = "zero_prefix"
      vpc_name   = "zero_dev_vpc"
      vpc_cidr   = "10.10.0.0/16"

      enable_nat_gateway     = true
      single_nat_gateway     = false
      one_nat_gateway_per_az = true
      enable_dns_hostnames   = true

      create_database_subnet_group           = true
      create_database_subnet_route_table     = false
      create_database_internet_gateway_route = false

      enable_flow_log                      = true
      create_flow_log_cloudwatch_iam_role  = true
      create_flow_log_cloudwatch_log_group = true
      key_pair = {
        key_name_prefix     = "zero_key"
        key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfgkVcyp2O3BEK4pIBOc1LrJ05bNAj4Sh0DVc2LEZSdEi0XYo44kW7oz3y2YvCozhpjKe8mWMwa7WtjuF7jLdDT7T8LQcYWnDJLdIsQ8RTJ68S8AwjmuwoSHf5hZ3K1aklA1HC+Ub8kyYW8RdVK/xBolrrN0syZIOQR4PkDjV9U9KSSH5a9sz8b32MSE4ZR9BtZdggYbw2GHs8XVD1ySuI7nCMIA1nfEJMC5cyV+LnbeLJNINph3enXPOh3BN0BL54IykEQUzT51ApMM+yWcyHiFV8NQWfjagvTzSEKf92btz3mGcaVMovHXjuBkt/6vyxIIlvEQiWmrZpr0RtRjMd rsa-key-20211210"
      }
      kms_name = "zero_dev"

      eks_config = {
        cluster_name                                   = "zero-app-dev-env"
        cluster_version                                = "1.24"
        max_size                                       = 10
        eks_managed_node_group_defaults_instance_types = ["t2.medium"]
        instance_type                                  = "t2.medium"
        instance_types                                 = ["t2.medium"]
        manage_aws_auth_configmap                      = true
        aws_auth_users = [
          {
            userarn  = "arn:aws:iam::629526135429:user/joe-dev"
            username = "joe-dev"
            groups   = ["system:masters"]
          },
        ]
        aws_auth_accounts                    = ["629526135429", ]
        cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
      }
      sgs = {
        "remote_access" = {
          name        = "zero_default_sg_admi"
          description = "allow remote access for admin ssh and rdp"
          sg_sets = [{
            from_port = 3389
            to_port   = 3389
            source    = ["10.10.0.0/16"]
            protocol  = "TCP"
            },
            {
              from_port = 22
              to_port   = 22
              protocol  = "TCP"
              source    = ["10.10.0.0/16"]
          }]
        }
      }
      rds = {
        "mysql" = {
          db_indentifier                      = "ezappservices"
          db_engine                           = "mariadb"
          db_engine_version                   = "10.5.12"
          db_instance_class                   = "db.t2.medium"
          allocated_storage                   = 50
          max_allocated_storage               = 100
          db_name                             = "zero_db_app"
          db_username_login                   = "zerodbadmin"
          db_port                             = "3306"
          iam_database_authentication_enabled = false
          multi_az                            = false
          backup_retention_period             = 30
          db_parameter_family_group           = "mariadb10.5"
          major_engine_version                = "10.5"
          deletion_protection                 = false #for dev mode
          cross_region_replica                = false
          publicly_accessible                 = false
          apply_immediately                   = true
          storage_encrypted                   = true
          storage_type                        = "gp2"
          delete_automated_backups            = true
          create_db_option_group              = false
          option_group_timeouts = {
            "delete" : "5m"
          }
          enable_ssm_storage_sensitive_data = true
        }
      }
      extend_tag = {
        "env" = "dev"
      }
    }
  }
}
