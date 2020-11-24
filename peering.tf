provider "aws" {
    alias  = "source"
    region = var.aws_region
}

provider "aws" {
    alias  = "dest"
    region = var.peering_region == null ? var.aws_region : var.peering_region
}

data "aws_route_tables" "source_vpc_rts" {
  count    = var.enable_peering? 1 : 0
  provider = aws.source
  vpc_id   = aws_vpc.network.id
}

data "aws_route_tables" "dst_vpc_rts" {
  count    = var.enable_peering? 1 : 0  
  provider = aws.dest
  vpc_id   = var.peering_vpc_id
}

resource "aws_vpc_peering_connection" "peering" {
  count    = var.enable_peering? 1 : 0
  provider    = aws.source
  vpc_id      = aws_vpc.network.id
  peer_vpc_id = var.peering_vpc_id
  peer_region = var.peering_region

  tags = {
      
  }
}

resource "aws_route" "dst_rt" {
  count    = var.enable_peering? 1 : 0
  provider                  = aws.dest
  route_table_id            = var.peering_rtb_id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  count    = var.enable_peering? 1 : 0
  provider                  = aws.dest
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
  auto_accept               = true

  tags = {

  }
}

data "aws_vpc" "dst_vpc" {
    count    = var.enable_peering? 1 : 0
    provider  = aws.dest
    id = var.peering_vpc_id
}

resource "aws_route" "source_rt" {
  count    = var.enable_peering? 1 : 0
  provider                  = aws.source
  route_table_id            = aws_route_table.network_rtb.id
  destination_cidr_block    = data.aws_vpc.dst_vpc[0].cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}

resource "aws_security_group_rule" "src_sg_rule" {
  count    = var.enable_peering? 1 : 0
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = [data.aws_vpc.dst_vpc[0].cidr_block]
  security_group_id = aws_security_group.project_network.id
}

resource "aws_security_group_rule" "dst_sg_rule" {
  count    = var.enable_peering? 1 : 0
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = [aws_vpc.network.cidr_block]
  security_group_id = var.peering_sg_id
}

resource "aws_route53_vpc_association_authorization" "peering" {
  count    = var.enable_peering? 1 : 0
  vpc_id  = aws_vpc.network.id
  zone_id = var.route53_zone_id
}

resource "aws_route53_zone_association" "peering" {
  count    = var.enable_peering? 1 : 0
  provider = aws.source

  vpc_id  = aws_route53_vpc_association_authorization.peering[0].vpc_id
  zone_id = aws_route53_vpc_association_authorization.peering[0].zone_id
}
