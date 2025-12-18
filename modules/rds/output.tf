output "rds_resource_ids" {
  value = {
    for k, db in aws_db_instance.rds : k => db.resource_id
  }
}

output "rds_usernames" {
  value = {
    for k, db in var.rds : k => db.db_username
  }
}