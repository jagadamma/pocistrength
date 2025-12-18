

  resource "aws_route_table" "public_subnet_route_table" {
  count  = length(var.public_subnet_route_tables)
  vpc_id = var.vpc_id

  dynamic "route" {
    for_each = var.internet_gateway_id != null && var.internet_gateway_id != "" ? [1] : []
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = var.internet_gateway_id
    }
  }

  tags = merge(
    var.common_tags,
    { Name = lookup(var.public_subnet_route_tables[count.index], "name") }, 
    try(lookup(var.public_subnet_route_tables[count.index], "tags", {}), {})
  )
   

   
  }


resource "aws_route_table_association" "public_subnet_route_table_association" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public_subnets.*.id[count.index%length(var.public_subnets)]
  route_table_id = aws_route_table.public_subnet_route_table.*.id[0]
}

#resource "aws_route_table" "private_subnet_route_table" {
#  count  = length(var.private_subnet_route_tables)
#  vpc_id = var.vpc_id
#  
#  route {
#    cidr_block                 = "0.0.0.0/0"
#    nat_gateway_id             = element(aws_nat_gateway.nat_gateway[*].id, count.index)
#  }
#
#    tags = merge(
#   var.common_tags,
#    { Name = lookup(var.private_subnet_route_tables[count.index], "name") }, 
#    try(lookup(var.private_subnet_route_tables[count.index], "tags", {}), {})
#  )
#  
#  }

resource "aws_route_table" "private_subnet_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[0].id
  }

  tags = merge(
    var.common_tags,
    { Name = "private-nat-rt" }
  )
}



  #resource "aws_route_table_association" "private_subnet_route_table_association" {
  #  count          = length(var.private_subnets)
  #  subnet_id      = aws_subnet.private_subnets.*.id[count.index%length(var.private_subnets)]
  #  route_table_id = aws_route_table.private_subnet_route_table.*.id[count.index % length(var.private_subnet_route_tables)]
  #}

resource "aws_route_table_association" "private_subnet_route_table_association" {
  for_each = {
    for subnet in aws_subnet.private_subnets :
    subnet.id => aws_route_table.private_subnet_route_table.id
  }

  subnet_id      = each.key
  route_table_id = each.value
}



#resource "aws_route_table" "db_subnet_route_table" {
#  count  = length(var.db_subnet_route_tables)
#  vpc_id = var.vpc_id
  
#  route {
#    cidr_block                 = "0.0.0.0/0"
#    nat_gateway_id             = element(aws_nat_gateway.nat_gateway[*].id, count.index)
#  }
  
#    tags = merge(
#    var.common_tags,
#    { Name = lookup(var.db_subnet_route_tables[count.index], "name") }, 
#    try(lookup(var.db_subnet_route_tables[count.index], "tags", {}), {})
#  )
  
#  }


#resource "aws_route_table_association" "db_subnet_route_table_association" {
#  count          = length(var.db_subnets)
#  subnet_id      = aws_subnet.db_subnets.*.id[count.index%length(var.db_subnets)]
#  route_table_id = aws_route_table.db_subnet_route_table.*.id[count.index % length(var.db_subnet_route_tables)]
#}
