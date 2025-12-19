resource "aws_eip" "nat_eip" {
  tags = merge(
    var.common_tags,
    { Name = lookup(var.nat_gateways[0], "name") }
  )
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = merge(
    var.common_tags,
    { Name = lookup(var.nat_gateways[0], "name") }
  )
}
