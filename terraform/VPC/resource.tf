resource "aws_vpc" "this" {
  cidr_block       = var.vpc_cidr
  #instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.vpc_name}_vpc"
  }
}


resource "aws_subnet" "vpc_subnets" {
  count = "${length(var.subnets)}"
  vpc_id     = aws_vpc.this.id
  availability_zone = var.subnets[count.index].availability_zone
  map_public_ip_on_launch = true
  cidr_block = var.subnets[count.index].cidr  

  tags = {
    Name = "${var.subnets[count.index].name}"
    
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "ig-${var.vpc_name}"
  }
}


resource "aws_default_route_table" "default_gateway" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }  
}

output "vpc_id" {
  value = aws_vpc.this.id
  
}

output "vpc_subnets_ids" {
  value = aws_subnet.vpc_subnets[0].id
  
}


