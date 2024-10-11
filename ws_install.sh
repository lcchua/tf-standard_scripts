#!/bin/bash

# Once the EC2 instance is running and ready, can 
# "curl http://<ec2 public ip address>:80"
# to see the display message below

yum update -y
yum install httpd -y
# yum install docker -y
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo "<h1>Hello World! $(hostname -f)</h1>" > /var/www/html/index.html
reboot

# After reboot, SSH into the EC2 server and run the following commands to check:
#   i) httpd -v
#   ii) sudo systemctl status httpd
# After which, go to browser and run http://<ec2_publc_ip>