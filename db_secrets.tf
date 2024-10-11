
# Generate a random pwd for the database
resource "random_password" "this" {
  length           = 16
  special          = true
  override_special = "_!%^"
}

# Generate a random identifier for the secret resource
resource "random_id" "suffix_db" {
  byte_length = 2
}

resource "aws_secretsmanager_secret" "this_db" {
  name = "${var.stack_name}-${var.env}-db-secret-${var.rnd_id}-${random_id.suffix_db.id}"

  tags = {
    group     = var.stack_name
    form_type = "Terraform Resources"
    Name      = "${var.stack_name}-${var.env}-db-secret-${var.rnd_id}-${random_id.suffix_db.id}"
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
