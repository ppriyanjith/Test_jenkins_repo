resource "aws_instance" "rukshan2048" {
  ami = "ami-cb076fb4"
  instance_type = "t2.micro"
  key_name = "RukshanPCS"
  subnet_id = "${aws_subnet.rukshanvpc-private-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.rukshan-sg.id}"]
  user_data = "${file("install.sh")}" 

  tags {
    Name = "rukshan2048"
    t_AppID = "Cloud Governance"
    t_awscon = "Pilot"
    t_cmdb = "No"
    t_cost_centre = "PCS"
    t_dcl = "2"
    t_environment = "Test"
    t_name = "Rukshan2048"
    t_owner_individual = "rukshan.kothwala@pearson.com"
    t_responsible_individuals = "rukshan.kothwala@pearson.com"
    t_pillar = "Foundation"
    t_role = "App"
    t_shut = "No"
  }

}

resource "aws_elb" "rukshan2048ELB" {
  name = "rukshan2048ELB"

  subnets         = ["${aws_subnet.rukshanvpc-private-subnet.id}", "${aws_subnet.rukshanvpc-public-subnet.id}"]
  security_groups = ["${aws_security_group.rukshan-sg.id}"]
  instances       = ["${aws_instance.rukshan2048.id}"]

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
    Name = "rukshan2048ELB"
    t_AppID = "Cloud Governance"
    t_awscon = "Pilot"
    t_cmdb = "No"
    t_cost_centre = "PCS"
    t_dcl = "2"
    t_environment = "Test"
    t_name = "Rukshan2048ELB"
    t_owner_individual = "rukshan.kothwala@pearson.com"
    t_responsible_individuals = "rukshan.kothwala@pearson.com"
    t_pillar = "Foundation"
    t_role = "App"
    t_shut = "No"
  }
}
