#!/bin/bash

# Update and upgrade
apt update -y && apt upgrade -y

# Install basic utilities
apt install -y apache2 mysql-client

# Enable and start Apache
systemctl enable apache2
systemctl start apache2

# Set up a simple web page
echo "<h1>Welcome to your Terraform-deployed EC2 instance!</h1>" > /var/www/html/index.html
