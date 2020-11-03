resource "aws_elb" "petclinic" {
  name = "petclinic-${var.environment}"
  security_groups = var.security_groups
  subnets = var.subnets
  internal = false

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 8080
    instance_protocol = "http"
  }

  health_check {
    target = "HTTP:8080/actuator/health"
    timeout = 10
    interval = 11
    unhealthy_threshold = 2
    healthy_threshold = 2
  }

  cross_zone_load_balancing = true
  idle_timeout = 60
  connection_draining = true
  connection_draining_timeout = 60

  tags = {
    Name = "spring-petclinic-${var.environment}"
  }
}
