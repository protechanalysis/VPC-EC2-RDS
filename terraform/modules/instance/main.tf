data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_key_pair" "manual_key_pair" {
  key_name = "ec2_test_key" 
}

resource "aws_instance" "web-test" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id = var.public_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids = var.security_group_id
  iam_instance_profile = var.instance_profile_name
  key_name = data.aws_key_pair.manual_key_pair.key_name
  user_data = var.user_data
  user_data_replace_on_change = true

  tags = var.tags
}
