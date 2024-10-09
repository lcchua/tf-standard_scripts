
#============ VPC =============
# Note that when a VPC is created, a main route table it created by default
# that is responsible for enabling the flow of network traffic within the VPC

resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    group     = var.stack_name
    form_type = "Terraform Resources"
    Name      = "${var.stack_name}-${var.env}-vpc-${var.rnd_id}"
  }
}
output "vpc-id" {
  description = "stw vpc"
  value       = aws_vpc.this.id
}


#============ SUBNETS =============

# Public Subnets
resource "aws_subnet" "public" {
  count = var.subnets_count.public // adjust number of public subnets to create

  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = element(local.availability_zones, count.index) // add 1 subnet per az in cycle 
  map_public_ip_on_launch = true

  tags = {
    group     = var.stack_name
    form_type = "Terraform Resources"
    Name      = "${var.stack_name}-${var.env}-public-subnet-${count.index + 1}-${var.rnd_id}"
  }
}
output "public-subnet" {
  description = "stw subnet public"
  value       = aws_subnet.public[*].id
}

# Private Subnets
resource "aws_subnet" "private" {
  count = var.subnets_count.private # adjust number of public subnets to create

  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.${count.index + var.subnets_count.public}.0/24"
  availability_zone = element(local.availability_zones, count.index) // add 1 subnet per az in cycle

  tags = {
    group     = var.stack_name
    form_type = "Terraform Resources"
    Name      = "${var.stack_name}-${var.env}-private-subnet-${count.index + 1}-${var.rnd_id}"
  }
}
output "private-subnet" {
  description = "stw subnet private"
  value       = aws_subnet.private[*].id
}


#============ INTERNET GATEWAY =============

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    group     = var.stack_name
    form_type = "Terraform Resources"
    Name      = "${var.stack_name}-${var.env}-igw-${var.rnd_id}"
  }
}
output "igw" {
  description = "stw igw"
  value       = aws_internet_gateway.this.id
}


#============ EIP + NAT GATEWAY =============

# To create and allocate a EIP as associated with a 'vpc' to 
# each EC2 instance of the application(s) being deployed
resource "aws_eip" "this" {
  count = var.subnets_count.public

  # To uncomment if there is only there are multiple EC2 instances 
  # with multiple public subnets
  #instance = aws_instance.ec2[count.index].id
  domain = "vpc"

  tags = {
    group     = var.stack_name
    form_type = "Terraform Resources"
    Name      = "${var.stack_name}-${var.env}-eip-${count.index + 1}-${var.rnd_id}"
  }
}
output "eip" {
  description = "stw EIP"
  value       = aws_eip.this[*].id
}

# To allocate a public NAT GW to each private subnet
resource "aws_nat_gateway" "this_public" {
  count = var.subnets_count.public

  allocation_id = aws_eip.this[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    group     = var.stack_name
    form_type = "Terraform Resources"
    Name      = "${var.stack_name}-${var.env}-nat-gw-${count.index + 1}-${var.rnd_id}"
  }
}
output "nat-gw" {
  description = "stw NAT gateway"
  value       = aws_nat_gateway.this_public[*].id
}


#============ ROUTE TABLES =============

# Private subnets route tables and associations
resource "aws_route_table" "private_subnet" {
  count = var.subnets_count.private

  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.this_public[count.index].id
  }

  tags = {
    group     = var.stack_name
    form_type = "Terraform Resources"
    Name      = "${var.stack_name}-${var.env}-private-rt-${count.index + 1}-${var.rnd_id}"
  }
}
resource "aws_route_table_association" "private_subnet" {
  count = var.subnets_count.private

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_subnet[count.index].id
}

output "private-route-table" {
  description = "stw private subnet route table"
  value       = aws_route_table.private_subnet[*].id
}

# Public subnets route tables and associations
resource "aws_route_table" "public_subnet" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    group     = var.stack_name
    form_type = "Terraform Resources"
    Name      = "${var.stack_name}-${var.env}-public-rt-${var.rnd_id}"
  }
}
resource "aws_route_table_association" "public_subnet" {
  count = var.subnets_count.public

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_subnet.id
}
output "public-route-table" {
  description = "stw public subnet route table"
  value       = aws_route_table.public_subnet[*].id
}


#============ VPC ENDPOINT FOR S3 =============

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = concat([aws_route_table.public_subnet.id],
  aws_route_table.private_subnet[*].id)

  tags = {
    group     = var.stack_name
    form_type = "Terraform Resources"
    Name      = "${var.stack_name}-${var.env}-vpc-endpoint-s3-${var.rnd_id}"
  }
}
output "vpce-s3" {
  description = "stw vpc endpoint s3"
  value       = aws_vpc_endpoint.s3.id
}


#============ DB SUBNET GROUP =============

resource "aws_db_subnet_group" "this" {
  name       = "${var.stack_name}-${var.env}-db-subnet-grp-${var.rnd_id}"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]

  tags = {
    group     = var.stack_name
    form_type = "Terraform Resources"
    Name      = "${var.stack_name}-${var.env}-db-subnet-grp-${var.rnd_id}"
  }
}
