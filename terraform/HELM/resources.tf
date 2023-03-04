
resource "helm_release" "app" {
  
  name             = var.app_name
  repository       = var.helm_repository
  chart            = var.chart_name
  namespace        = var.namespace
  version          = var.chart_version
  create_namespace = true 
  
  dynamic "set" {
    for_each = var.value_sets
    content {
      name = set.key
      value = set.value
    }
  }  
}


resource "aws_lb_target_group" "target_group" {
  name     = "${var.app_name}-lb-tg"
  port     = var.value_sets.node_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    port = var.value_sets.node_port
    path = "/isAlive"
    protocol = "HTTP"
  }
}


resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = var.auto_scale_group
  lb_target_group_arn    = aws_lb_target_group.target_group.arn
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = var.listener_arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
