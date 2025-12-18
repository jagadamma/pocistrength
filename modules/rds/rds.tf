resource "aws_db_subnet_group" "rds_sg" {
  for_each = var.rds

  name       = each.value.subnet_group_name
  subnet_ids = var.private_subnet_ids
  tags = merge(
  var.common_tags,
  {
    Name = each.value.subnet_group_name
  }
)

}


### RDS Parameter Group ###

resource "aws_db_parameter_group" "rds_pg" {
  for_each   = var.rds

  name        = each.value.parameter_group_name
  family      = each.value.parameter_group_family
  description = "Parameter group for ${each.key}"
  tags = merge(
    var.common_tags,
    {
    Name = each.value.parameter_group_name
  }
  )
}
  

data "aws_secretsmanager_secret" "rds_secrets" {
  for_each = var.rds
  name     = "${each.value.db_identifier}-secrets"

  depends_on = [aws_secretsmanager_secret.rds_secret]
}

data "aws_secretsmanager_secret_version" "rds_secrets_version" {
  for_each  = var.rds
  secret_id = data.aws_secretsmanager_secret.rds_secrets[each.key].id
}  

### RDS ###
resource "aws_db_instance" "rds" {
  for_each = var.rds

  identifier           = each.value.db_identifier
  instance_class       = each.value.instance_class
  allocated_storage    = each.value.allocated_storage
  engine               = each.value.engine
  engine_version       = each.value.engine_version
  db_name              = each.value.db_name
  username             = each.value.db_username
  password             = data.aws_secretsmanager_secret_version.rds_secrets_version[each.key].secret_string

  auto_minor_version_upgrade = each.value.auto_minor_version_upgrade
  backup_retention_period    = each.value.backup_retention_period
  copy_tags_to_snapshot      = each.value.copy_tags_to_snapshot
  db_subnet_group_name       = aws_db_subnet_group.rds_sg[each.key].name
  parameter_group_name       = aws_db_parameter_group.rds_pg[each.key].name
  monitoring_interval        = 0  # Disable Enhanced Monitoring
  #enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  performance_insights_enabled = each.value.performance_insights_enabled
  performance_insights_retention_period = each.value.performance_insights_retention_period
  multi_az                   = each.value.multi_az
  publicly_accessible        = each.value.publicly_accessible
  skip_final_snapshot        = each.value.skip_final_snapshot
  storage_encrypted          = each.value.storage_encrypted
  storage_type               = each.value.storage_type
  vpc_security_group_ids     = [aws_security_group.db_sg[each.key].id]
  deletion_protection        = each.value.deletion_protection
  kms_key_id                 = aws_kms_key.kms[each.key].arn

  tags = merge(
    var.common_tags,
    {
      Name = each.value.db_identifier
    }
  )
}


