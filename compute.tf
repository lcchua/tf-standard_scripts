
#============ ACI FILTER - DYNAMIC IMAGE SELECTION =============
data "aws_ami" "this" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "description"
    values = ["*Amazon Linux 2023 AMI*"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-2023.5.20240722.0-kernel-6.1-x86_64", "amazon/al2023-ami-2023.5.20241001.1-kernel-6.1-x86_64"]
  }
  # To uncomment the additional filter and indicate the specific image-id 
  # in case the above AMI filtered results change over time
  /*
  filter {
    name   = "image-id"
    values = ["ami-0427090fd1714168b", "ami-0fff1b9a61dec8a5f"]
  }
*/
}
output "ami" {
  description = "stw ami"
  value       = data.aws_ami.this.id
}

#============ EC2 INSTANCE CREATION WITH AUTO-INSTALLATION =============
resource "aws_instance" "ec2" {
  count = var.settings.web_app.count // adjust the number of EC2 instances to create

  ami           = data.aws_ami.this.id
  instance_type = var.settings.web_app.instance_type
  #instance_type = var.instance_type  // uncomment if the "settings" var is not used instead
  key_name = var.key_name

  # Uncomment the appropriate subnet_id value assignment as accordingly
  #subnet_id                   = element(aws_subnet.public[*].id, 0)
  subnet_id                   = aws_subnet.public[count.index].id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web_app_server.id]

  # To update the previously created EC2 with a user data script passed in.
  # This is to convert your EC2 into a HTTPD web server.
  user_data_replace_on_change = true // to trigger a destroy and recreate
  user_data                   = file("${path.module}/as_install.sh")

  # Enable detailed monitoring
  monitoring = true

  tags = {
    group     = var.stack_name
    form_type = "Terraform Resources"
    Name      = "${var.stack_name}-${var.env}-ec2-server-${var.rnd_id}"
  }
}
output "ec2" {
  description = "stw EC2 instance"
  value       = aws_instance.ec2[*].id
}
output "user-data" {
  description = "stw EC2 user data"
  value       = "${path.module}/as_install.sh"
}
output "ec2_web_public_dns" {
  description = "The public DNS address of the ec2 web app"
  value       = aws_eip.this[*].public_dns
  # Wait for the EIPs to be created and dsitributed
  depends_on = [aws_eip.this]
}