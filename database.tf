
/* Uncomment as needed
data "aws_rds_engine_version" "latest" {
  engine      = var.settings.database.engine
  latest = true
}
*/
resource "aws_db_instance" "this" {
  allocated_storage = var.settings.database.allocate_storage
  engine            = var.settings.database.engine
  engine_version    = var.settings.database.engine_version
  #engine_version          = data.aws_rds_engine_version.latest.version   // uncomment as needed
  instance_class = var.settings.database.instance_class
  identifier     = "${var.stack_name}-${var.env}-db-server-${var.rnd_id}"
  #db_name                 = var.settings.database.db_name    // uncomment as needed
  username               = var.settings.database.db_username
  password               = aws_secretsmanager_secret_version.this_db.secret_string
  db_subnet_group_name   = aws_db_subnet_group.this.id
  vpc_security_group_ids = [aws_security_group.db_server.id]
  skip_final_snapshot    = var.settings.database.skip_final_snapshot

  tags = {
    group     = var.stack_name
    form_type = "Terraform Resources"
    Name      = "${var.stack_name}-${var.env}-db-server-${var.rnd_id}"
  }
}

output "database_endpoint" {
  description = "The endpoint of the database"
  value       = aws_db_instance.this.address
}
output "database_port" {
  description = "The port of the database"
  value       = aws_db_instance.this.port
}
output "database_version" {
  description = "The version of the database"
  value       = aws_db_instance.this.engine_version
}