resource "aws_eip" "elastic_ip" {
  count = length(var.nat_gateways)
  tags = merge(
    var.common_tags,  
    { Name = lookup(var.nat_gateways[count.index], "name") },                                       # Common tags from env
    try(lookup(var.nat_gateways[count.index], "tags", {}), {}) # Optional per-NAT tags
  )

}

resource "aws_nat_gateway" "nat_gateway" {
  count         = length(var.nat_gateways)
  allocation_id = aws_eip.elastic_ip.*.id[count.index]
  subnet_id     = aws_subnet.public_subnets.*.id[count.index]
  tags = merge(
    var.common_tags,       
    { Name = lookup(var.nat_gateways[count.index], "name") },                                  # Common tags from env
    try(lookup(var.nat_gateways[count.index], "tags", {}), {}) # Optional per-NAT tags
  )

}