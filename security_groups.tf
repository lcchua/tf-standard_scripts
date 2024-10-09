#============ SECURITY GROUP =============

# EC2 Security Group
resource "aws_security_group" "web_app_server" {
  name   = "${var.stack_name}-${var.env}-web-app-server-${var.rnd_id}"
  vpc_id = aws_vpc.this.id

  # SSH - inbound rule that allows SSH traffic only from your IP addr
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #cidr_blocks = ["${var.my_ip}/32"]
  }
  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Custom HTTP for nodejs web app
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    group     = var.stack_name
    form_type = "Terraform Resources"
    Name      = "${var.stack_name}-${var.env}-web-app-server-${var.rnd_id}"
  }
}
output "web-app-server-sg" {
  description = "stw ec2 web app server security group"
  value       = aws_security_group.web_app_server.id
}

# RDS Security Group
resource "aws_security_group" "db_server" {
  name   = "${var.stack_name}-${var.env}-db-server-${var.rnd_id}"
  vpc_id = aws_vpc.this.id

  ingress {
    from_port       = "3306"
    to_port         = "3306"
    protocol        = "tcp"
    security_groups = [aws_security_group.web_app_server.id]
  }

  tags = {
    group     = var.stack_name
    form_type = "Terraform Resources"
    Name      = "${var.stack_name}-${var.env}-db-server-${var.rnd_id}"
  }
}
output "db-server-sg" {
  description = "stw db server security group"
  value       = aws_security_group.db_server.id
}

