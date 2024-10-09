
resource "random_password" "this" {
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "this_db" {
  name = "${var.stack_name}-${var.env}-db-secret-${var.rnd_id}"

  tags = {
    group     = var.stack_name
    form_type = "Terraform Resources"
    Name      = "${var.stack_name}-${var.env}-db-secret-${var.rnd_id}"
  }
}

resource "aws_secretsmanager_secret_version" "this_db" {
  secret_id     = aws_secretsmanager_secret.this_db.id
  secret_string = random_password.this.result
}

output "secret_arn" {
  description = "The ARN of the secret for reference"
  value       = aws_secretsmanager_secret.this_db.arn
}
