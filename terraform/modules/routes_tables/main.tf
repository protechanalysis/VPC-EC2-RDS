resource "aws_route_table" "dev_route_table" {
  vpc_id = var.vpc_id

  dynamic "route" {
    for_each = var.type == "public" || var.type == "private" ? [1] : []
    content {
      cidr_block     = var.route_cidr
      gateway_id     = var.type == "public"  ? var.gateway_id     : null
    }
  }

  tags = var.tags
}


resource "aws_route_table_association" "subnet_association" {
  for_each = var.subnet_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.dev_route_table.id
}
