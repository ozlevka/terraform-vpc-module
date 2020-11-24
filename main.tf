resource "aws_vpc" "network" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true #gives you an internal domain name
    enable_dns_hostnames = true #gives you an internal host name
    enable_classiclink = false
    instance_tenancy = "default"    
    tags = {
        Name = "${var.project_name}-vpc"
    }
}

# Subnets : public
resource "aws_subnet" "public" {
  count = length(var.azs)
  vpc_id = aws_vpc.network.id
  cidr_block = cidrsubnet(var.vpc_cidr, var.cidr_bytes,count.index)
  availability_zone = "${var.aws_region}${element(var.azs,count.index)}"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-${var.aws_region}${element(var.azs,count.index)}"
  }
}

resource "aws_internet_gateway" "network_igw" {
    vpc_id = aws_vpc.network.id
    tags = {
        Name = "${var.project_name}-igw"
    }
}

resource "aws_route_table" "network_rtb" {
    vpc_id = aws_vpc.network.id
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = aws_internet_gateway.network_igw.id
    }
    
    tags = {
        Name = "${var.project_name}_rtb"
    }
}

# Route table association with public subnets
resource "aws_route_table_association" "rtb_asc" {
  count = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.public.*.id,count.index)
  route_table_id = aws_route_table.network_rtb.id
}

resource "aws_security_group" "project_network" {
    vpc_id = aws_vpc.network.id
    name   = "${var.project_name}-default-sg"
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 0
        to_port   = 0
        protocol  = -1
        self      = true
    }

    tags = {
        Name = "${var.project_name}-ssh-enabled"
    }

    depends_on = [aws_vpc.network]

    dynamic "ingress" {
        for_each = [for ing in var.sg_ingress_networks:{
            from_port   = ing.from_port
            to_port     = ing.to_port
            protocol    = ing.protocol
            description = ing.description
            cidr_blocks = ing.cidr_blocks
        }]

        content {
            from_port   = ingress.value.from_port
            to_port     = ingress.value.to_port
            protocol    = ingress.value.protocol
            description = ingress.value.description
            cidr_blocks = ingress.value.cidr_blocks
        }
    }
}



