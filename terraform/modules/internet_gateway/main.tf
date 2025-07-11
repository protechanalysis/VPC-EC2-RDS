resource "aws_internet_gateway" "test_internet_gateway" {
  vpc_id = var.vpc_id

  tags = {
    Name = var.name
  }
}
