resource "aws_instance" "rukshanBastion" {
  ami = "ami-cb076fb4"
  instance_type = "t2.micro"
  key_name = "RukshanPCS"
  subnet_id = "${aws_subnet.rukshanvpc-public-subnet.id}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.rukshan-sg.id}"]

  tags {
    Name = "rukshanBastion"
    t_AppID = "Cloud Governance"
    t_awscon = "Pilot"
    t_cmdb = "No"
    t_cost_centre = "PCS"
    t_dcl = "2"
    t_environment = "Test"
    t_name = "RukshanBastion"
    t_owner_individual = "rukshan.kothwala@pearson.com"
    t_responsible_individuals = "rukshan.kothwala@pearson.com"
    t_pillar = "Foundation"
    t_role = "App"
    t_shut = "No"
  }

}
