## To use this file to create a key-pair, 
## just uncomment the '/*** ... ***/' block

/***

# To generate a private key
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  #count = fileexists("${path.module}/${var.key_name}.pem") ? 0 : 1

  key_name = var.key_name
  public_key = tls_private_key.rsa.public_key_openssh
  
  tags = {
    group = var.stack_name
    Name  = "${var.stack_name}-${var.env}-key_pair-${var.rnd_id}"
  }
}

# To save the private key to a local file with .pem extension
resource "local_file" "this" {
  count = fileexists("${path.module}/${var.key_name}.pem") ? 0 : 1

  content         = tls_private_key.rsa.private_key_pem
  filename        = "${path.module}/${var.key_name}.pem"
  file_permission = "0400"
}

output "key-pair" {
  description = "stw EC2 key-pair"
  value       = aws_key_pair.this.key_name
}

***/