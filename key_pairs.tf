# To generate a private key
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# To create AWS key pair resource using the public key
resource "aws_key_pair" "this" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa.public_key_openssh

  tags = {
    group = var.stack_name
    Name  = "${var.stack_name}-${var.env}-key_pair-${var.rnd_id}"
  }
}

# To save the private key to a local file with .pem extension
resource "local_file" "this" {
  content         = tls_private_key.rsa.private_key_pem
  filename        = "${var.working_dir}/${var.key_name}.pem"
  file_permission = "0400"
}

output "key-pair" {
  description = "stw EC2 key-pair"
  value       = aws_key_pair.this.key_pair_id
}
