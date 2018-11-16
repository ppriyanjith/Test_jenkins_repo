resource "aws_instance" "padma2048" {
  ami = "ami-0ac019f4fcb7cb7e6"
  instance_type = "t2.micro"
  key_name = "My_new_private_pearson_usest1"
  subnet_id = "${aws_subnet.padma_vpc-private-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.padma-sg.id}"]
  user_data = "${file("install.sh")}" 

  tags {
    Name = "padma2048"
    t_AppID = "Cloud Governance"
    t_awscon = "Pilot"
    t_cmdb = "No"
    t_cost_centre = "PCS"
    t_dcl = "2"
    t_environment = "Test"
    t_name = "padma2048"
    t_owner_individual = "padma.priyanjith@pearson.com"
    t_responsible_individuals = "padma.priyanjith@pearson.com"
    t_pillar = "Foundation"
    t_role = "App"
    t_shut = "No"
  }

}

resource "aws_elb" "padma2048ELB" {
  name = "padma2048ELB"

  subnets         = ["${aws_subnet.padma_vpc-private-subnet.id}", "${aws_subnet.padma_vpc-public-subnet.id}"]
  security_groups = ["${aws_security_group.padma-sg.id}"]
  instances       = ["${aws_instance.padma2048.id}"]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8080"
    interval            = 30
  }
  
  tags {
    Name = "padma2048ELB"
    t_AppID = "Cloud Governance"
    t_awscon = "Pilot"
    t_cmdb = "No"
    t_cost_centre = "PCS"
    t_dcl = "2"
    t_environment = "Test"
    t_name = "padma2048ELB"
    t_owner_individual = "padma.priyanjith@pearson.com"
    t_responsible_individuals = "padma.priyanjith@pearson.com"
    t_pillar = "Foundation"
    t_role = "App"
    t_shut = "No"
  }
}
