resource "aws_lb" "main" {
  name               = "${var.project_name}-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [for s in aws_subnet.public : s.id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-tg"
  port     = 80 # Any port, as we forward IP traffic
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"

  stickiness {
    type    = "source_ip"
    enabled = true
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80" # Any port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_target_group_attachment" "snat" {
  for_each = aws_instance.public_snat

  target_group_arn = aws_lb_target_group.main.arn
  target_id        = each.value.id
}