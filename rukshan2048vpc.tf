#Define the common tags for all resources

locals {
  common_tags = {
    t_AppID = "Cloud Governance"
    t_awscon = "Pilot"
    t_cmdb = "No"
    t_cost_centre = "PCS"
    t_dcl = "2"
    t_environment = "Test"
    t_owner_individual = "rukshan.kothwala@pearson.com"
    t_responsible_individuals = "rukshan.kothwala@pearson.com"
    t_pillar = "Foundation"
    t_role = "App"
    t_shut = "No" 
 }
}

#Create VPC in pcs-poc Account

resource "aws_vpc" "rukshanvpc" {
  cidr_block = "10.23.0.0/16"
  enable_dns_hostnames = true

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "rukshanvpc",
      "t_name", "rukshanvpc"
    )
  )}"

}

#Create Public Subnet

resource "aws_subnet" "rukshanvpc-public-subnet" {
  vpc_id = "${aws_vpc.rukshanvpc.id}"
  cidr_block = "10.23.1.0/24"
  availability_zone = "us-east-1a"

 tags = "${merge(
    local.common_tags,
    map(
      "Name", "rukshanvpc-public-subnet",
      "t_name", "rukshanvpc-public-subnet"
    )
  )}"

}


#Create Private Subnet

resource "aws_subnet" "rukshanvpc-private-subnet" {
  vpc_id = "${aws_vpc.rukshanvpc.id}"
  cidr_block = "10.23.2.0/24"
  availability_zone = "us-east-1b"

 tags = "${merge(
    local.common_tags,
    map(
      "Name", "rukshanvpc-private-subnet",
      "t_name", "rukshanvpc-private-subnet"
    )
  )}"

}

#Create Internet Gateway

resource "aws_internet_gateway" "rukshan-gw" {
  vpc_id = "${aws_vpc.rukshanvpc.id}"

 tags = "${merge(
    local.common_tags,
    map(
      "Name", "rukshan-IG",
      "t_name", "rukshan-IG"
    )
  )}"

}

#Create Elastic IP
resource "aws_eip" "rukshan_eip" {
  vpc      = true
  depends_on = ["aws_internet_gateway.rukshan-gw"]
}

#Create NAT Gateway
resource "aws_nat_gateway" "rukshan-nat" {
    allocation_id = "${aws_eip.rukshan_eip.id}"
    subnet_id = "${aws_subnet.rukshanvpc-public-subnet.id}"
    depends_on = ["aws_internet_gateway.rukshan-gw"]
}

#Create Route Table

resource "aws_route_table" "rukshan-public-route" {
  vpc_id = "${aws_vpc.rukshanvpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.rukshan-gw.id}"
  }
 
 tags = "${merge(
    local.common_tags,
    map(
      "Name", "rukshan-route",
      "t_name", "rukshan-route"
    )
  )}"

}

#Create private route table
resource "aws_route_table" "rukshan_private_route_table" {
    vpc_id = "${aws_vpc.rukshanvpc.id}"

    tags = "${merge(
    local.common_tags,
    map(
      "Name", "rukshan_private_route_table",
      "t_name", "rukshan_private_route_table"
    )
  )}"
       
    }

resource "aws_route" "rukshan_private_route" {
	route_table_id  = "${aws_route_table.rukshan_private_route_table.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.rukshan-nat.id}"
}

#Assign the private route table to public
resource "aws_route_table_association" "rukshan-private-route" {
  subnet_id = "${aws_subnet.rukshanvpc-private-subnet.id}"
  route_table_id = "${aws_route_table.rukshan_private_route_table.id}"
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "rukshan-public-route" {
  subnet_id = "${aws_subnet.rukshanvpc-public-subnet.id}"
  route_table_id = "${aws_route_table.rukshan-public-route.id}"
}

#Create Security groups
resource "aws_security_group" "rukshan-sg" {
  name = "rukshan-sg"
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

  vpc_id="${aws_vpc.rukshanvpc.id}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "rukshan-sg",
      "t_name", "rukshan-sg"
    )
  )}"

}
