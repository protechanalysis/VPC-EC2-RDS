resource "aws_subnet" "dev_subnet" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(var.tags, {
    Name = "${each.value.name}"
  })
}
