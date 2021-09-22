resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.dummy_vpc.id
}

resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.dummy_vpc.id}"
  count             = "${length(split(",", var.azs))}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  cidr_block        = "10.99.${count.index}.0/24"
}

# Route the public subnet traffic through the IGW
resource "aws_route" "default" {
  route_table_id         = aws_vpc.dummy_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_alb" "dummy_load_balancer" {
  name                 = "dummyLB"
  load_balancer_type   = "application"
  subnets              = aws_subnet.private.*.id
  security_groups      = ["${aws_security_group.dummy_security_group.id}"]
}

resource "aws_lb_target_group" "dummyTG" {
  name        = "dummyTG"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${aws_vpc.dummy_vpc.id}"
  deregistration_delay = 30
  depends_on = [aws_alb.dummy_load_balancer]
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn         = "${aws_alb.dummy_load_balancer.arn}"
  port                      = "443"
  protocol                  = "HTTPS"
  ssl_policy                = "ELBSecurityPolicy-2016-08"
  certificate_arn           = aws_acm_certificate_validation.validation_task.certificate_arn
  default_action {
    type                    = "forward"
    target_group_arn        = "${aws_lb_target_group.dummyTG.arn}"
  }
  depends_on                = [aws_acm_certificate_validation.validation_task]
}

# Creating a security group for the load balancer:
resource "aws_security_group" "dummy_security_group" {
  name = "dummy_security_group"
  vpc_id = "${aws_vpc.dummy_vpc.id}"

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }

}

resource "aws_security_group_rule" "ingress_rules" {
  count = length(var.ingress_rules)

  type              = "ingress"
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  protocol          = var.ingress_rules[count.index].protocol
  cidr_blocks       = [var.ingress_rules[count.index].cidr_block]
  security_group_id = aws_security_group.dummy_security_group.id
}
