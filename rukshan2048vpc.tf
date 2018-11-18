#Define the common tags for all resources

locals {
  common_tags = {
    t_AppID = "Cloud Governance"
    t_awscon = "Pilot"
    t_cmdb = "No"
    t_cost_centre = "PCS"
    t_dcl = "2"
    t_environment = "Test"
    t_owner_individual = "padma.priyanjith@pearson.com"
    t_responsible_individuals = "padma.priyanjith@pearson.com"
    t_pillar = "Foundation"
    t_role = "App"
    t_shut = "No" 
 }
}

#Create VPC in pcs-poc Account

resource "aws_vpc" "padma_vpc" {
  cidr_block = "10.23.0.0/16"
  enable_dns_hostnames = true

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "padma_vpc",
      "t_name", "padma_vpc"
    )
  )}"

}

#Create Public Subnet

resource "aws_subnet" "padma_vpc-public-subnet" {
  vpc_id = "${aws_vpc.padma_vpc.id}"
  cidr_block = "10.23.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

 tags = "${merge(
    local.common_tags,
    map(
      "Name", "padma_vpc-public-subnet",
      "t_name", "padma_vpc-public-subnet"
    )
  )}"

}


#Create Private Subnet

resource "aws_subnet" "padma_vpc-private-subnet" {
  vpc_id = "${aws_vpc.padma_vpc.id}"
  cidr_block = "10.23.2.0/24"
  availability_zone = "us-east-1b"

 tags = "${merge(
    local.common_tags,
    map(
      "Name", "padma_vpc-private-subnet",
      "t_name", "padma_vpc-private-subnet"
    )
  )}"

}

#Create Internet Gateway

resource "aws_internet_gateway" "padma-gw" {
  vpc_id = "${aws_vpc.padma_vpc.id}"

 tags = "${merge(
    local.common_tags,
    map(
      "Name", "padma-IG",
      "t_name", "padma-IG"
    )
  )}"

}

#Create Elastic IP
resource "aws_eip" "padma_eip" {
  vpc      = true
  depends_on = ["aws_internet_gateway.padma-gw"]
}

#Create NAT Gateway
resource "aws_nat_gateway" "padma-nat" {
    allocation_id = "${aws_eip.padma_eip.id}"
    subnet_id = "${aws_subnet.padma_vpc-public-subnet.id}"
    depends_on = ["aws_internet_gateway.padma-gw"]
}

#Create Route Table

resource "aws_route_table" "padma-public-route" {
  vpc_id = "${aws_vpc.padma_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.padma-gw.id}"
  }
 
 tags = "${merge(
    local.common_tags,
    map(
      "Name", "padma-route",
      "t_name", "padma-route"
    )
  )}"

}

#Create private route table
resource "aws_route_table" "padma_private_route_table" {
    vpc_id = "${aws_vpc.padma_vpc.id}"

    tags = "${merge(
    local.common_tags,
    map(
      "Name", "padma_private_route_table",
      "t_name", "padma_private_route_table"
    )
  )}"
       
    }

resource "aws_route" "padma_private_route" {
	route_table_id  = "${aws_route_table.padma_private_route_table.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.padma-nat.id}"
}

#Assign the private route table to public
resource "aws_route_table_association" "padma-private-route" {
  subnet_id = "${aws_subnet.padma_vpc-private-subnet.id}"
  route_table_id = "${aws_route_table.padma_private_route_table.id}"
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "padma-public-route" {
  subnet_id = "${aws_subnet.padma_vpc-public-subnet.id}"
  route_table_id = "${aws_route_table.padma-public-route.id}"
}

#Create Security groups
resource "aws_security_group" "padma-sg" {
  name = "padma-sg"
  description = "This is to open required ports"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.padma_vpc.id}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "padma-sg",
      "t_name", "padma-sg"
    )
  )}"

}
