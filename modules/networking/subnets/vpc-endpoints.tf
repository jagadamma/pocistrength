resource "aws_security_group" "vpc_endpoints_sg" {
  name_prefix = "${var.name_prefix}-vpc-endpoints-sg"
  description = "Associated to ECR/s3 VPC Endpoints"
  vpc_id      = var.vpc_id
 
  ingress {
    description     = "Allow Nodes to pull images from ECR via VPC endpoints"
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [var.ecs_security_group_id]
  }
    tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-vpc-interface-endpoints-sg"
    }
  )

}
 
##############################
# VPC Endpoint (ecr.dkr)
##############################
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
 
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]
  subnet_ids         = aws_subnet.private_subnets[*].id
 
   tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-docker-vpc-endpoint"
    }
  )

}


##############################
# VPC Endpoint (ecr.api)
##############################
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
 
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]
  subnet_ids         = aws_subnet.private_subnets[*].id 
 
  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-ecr-vpc-endpoint"
    }
  )

}



##############################
# VPC Endpoints (S3)
##############################
resource "aws_vpc_endpoint" "gateway_endpoint_for_s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-s3-gateway-endpoint"
    }
  )

}

resource "aws_vpc_endpoint_route_table_association" "s3_gateway_endpoint_association_private_route_table" {
  count           = length(var.private_subnet_route_tables)
  route_table_id  = aws_route_table.private_subnet_route_table.*.id[count.index]
  vpc_endpoint_id = aws_vpc_endpoint.gateway_endpoint_for_s3.id
}

resource "aws_vpc_endpoint_route_table_association" "s3_gateway_endpoint_association_public_route_table" {
  count           = length(var.public_subnet_route_tables)
  route_table_id  = aws_route_table.public_subnet_route_table.*.id[count.index]
  vpc_endpoint_id = aws_vpc_endpoint.gateway_endpoint_for_s3.id
}

resource "aws_security_group" "security_group_for_vpc_interface_endpoints" {
  name   = "${var.name_prefix}-vpc-interface-endpoints"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow traffic on port 443 "
  }
  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-vpc-interface-endpoints"
    }
  )

}
