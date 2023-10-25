# Configure VPC 
resource "aws_vpc" "TERRAFORM-PROJ" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "TERRAFORM-PROJ"
  }
}

#  Configure Public Subnet
resource "aws_subnet" "Prod-pub-sub1" {
  vpc_id     = aws_vpc.TERRAFORM-PROJ.id
  cidr_block = "10.0.5.0/24"

  tags = {
    Name = "Prod-pub-sub1"
  }
}

resource "aws_subnet" "Prod-pub-sub2" {
  vpc_id     = aws_vpc.TERRAFORM-PROJ.id
  cidr_block = "10.0.6.0/24"

  tags = {
    Name = "Prod-pub-sub2"
  }
}

#  Configure Private Subnet
resource "aws_subnet" "Prod-priv-sub1" {
  vpc_id     = aws_vpc.TERRAFORM-PROJ.id
  cidr_block = "10.0.7.0/24"

  tags = {
    Name = "Prod-priv-sub1"
  }
}

resource "aws_subnet" "prod-priv-sub2" {
  vpc_id     = aws_vpc.TERRAFORM-PROJ.id
  cidr_block = "10.0.8.0/24"

  tags = {
    Name = "prod-priv-sub2"
  }
}

# Configure Public Route Table
resource "aws_route_table" "Prod-pub-route-table" {
  vpc_id = aws_vpc.TERRAFORM-PROJ.id

  tags = {
    Name = "Prod-pub-route-table"
  }
}

# Configure Private Route Table
resource "aws_route_table" "Prod-priv-route-table" {
  vpc_id = aws_vpc.TERRAFORM-PROJ.id

  tags = {
    Name = "Prod-priv-route-table"
  }
}

# Configure Public Route Table Association
resource "aws_route_table_association" "Prod-pub-route-table_association_1" {
  subnet_id      = aws_subnet.Prod-pub-sub1.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

resource "aws_route_table_association" "Prod-pub-route-table_association_2" {
  subnet_id      = aws_subnet.Prod-pub-sub2.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

# Configure Private Route Table Association
resource "aws_route_table_association" "Prod-priv-route-table_association_1" {
  subnet_id      = aws_subnet.Prod-priv-sub1.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}

resource "aws_route_table_association" "Prod-priv-route-table_association_2" {
  subnet_id      = aws_subnet.prod-priv-sub2.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}

# Configure Internet Gateway
resource "aws_internet_gateway" "Prod-igw" {
  vpc_id = aws_vpc.TERRAFORM-PROJ.id

  tags = {
    Name = "Prod-igw"
  }
}

# Configure AWS Route
resource "aws_route" "public_internet_gateway_route" {
  route_table_id = aws_route_table.Prod-pub-route-table.id
  gateway_id                = aws_internet_gateway.Prod-igw.id
  destination_cidr_block    = "0.0.0.0/0"
}


# Configure Elastic IP Address
resource "aws_eip" "Prod_Elastic_IP" {
  tags = {
    Name = "Prod_Elastic_IP"
  }
}

# Configure NAT Gateway
resource "aws_nat_gateway" "Prod-Nat-gateway" {
  allocation_id = aws_eip.Prod_Elastic_IP.id
  subnet_id     = aws_subnet.Prod-pub-sub1.id

  tags = {
    Name = "Prod-Nat-gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.Prod-igw]
}


# NAT Associate with Priv route
resource "aws_route" "NAT-gateway-route" {
  route_table_id = aws_route_table.Prod-priv-route-table.id
  gateway_id = aws_nat_gateway.Prod-Nat-gateway.id
  destination_cidr_block = "0.0.0.0/0"
}