resource "aws_instance" "padmaBastion" {
  ami = "ami-cb076fb4"
  instance_type = "t2.micro"
  key_name = "My_new_private_pearson_usest1"
  subnet_id = "${aws_subnet.padma_vpc-public-subnet.id}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.padma-sg.id}"]

  tags {
    Name = "padmaBastion"
    t_AppID = "Cloud Governance"
    t_awscon = "Pilot"
    t_cmdb = "No"
    t_cost_centre = "PCS"
    t_dcl = "2"
    t_environment = "Test"
    t_name = "padmaBastion"
    t_owner_individual = "padma.priyanjith@pearson.com"
    t_responsible_individuals = "padma.priyanjith@pearson.com"
    t_pillar = "Foundation"
    t_role = "App"
    t_shut = "No"
  }

}
