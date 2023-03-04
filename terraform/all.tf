module "vpc" {
  source = "./VPC"
  region = var.region
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
  subnets = var.subnets
}



resource "aws_security_group" "eks" {
    name        = "${var.eks_name} eks cluster SG"
    description = "Allow traffic"
    vpc_id      = module.vpc.vpc_id

    ingress {
      description      = "World"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    tags = merge({
      Name = "EKS ${var.eks_name}",
      "kubernetes.io/cluster/${var.eks_name}": "owned"
    }, var.tags)
}


data "aws_subnet_ids" "eitan_vpc_subnets" {
  vpc_id = module.vpc.vpc_id
  depends_on = [
    module.vpc
  ]
}

module "eks" {
  source       = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v19.10.0"
  cluster_name = var.eks_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids = data.aws_subnet_ids.eitan_vpc_subnets.ids
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
      ami_type               = "AL2_x86_64"
      disk_size              = 50
      instance_types         = ["t3.medium", "t3.large"]
      vpc_security_group_ids = [aws_security_group.eks.id]
    }

    eks_managed_node_groups = {
      green = {
        min_size     = 1
        max_size     = 1
        desired_size = 1

        instance_types = ["t3.medium"]
        capacity_type  = "SPOT"
        labels = var.tags 
        taints = {
        }
        tags = var.tags
      }
    }

    tags = var.tags
}


resource "aws_security_group" "alb_sg" {
    name        = "alb SG"
    description = "Allow traffic"
    vpc_id      = module.vpc.vpc_id

    ingress {
      description      = "World"
      from_port        = 80
      to_port          = 80
      protocol         = "TCP"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    ingress {
      description      = "World"
      from_port        = 443
      to_port          = 443
      protocol         = "TCP"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    tags = var.tags
}


resource "aws_lb" "eitan_alb" {
  name               = "eitan-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnet_ids.eitan_vpc_subnets.ids

  enable_deletion_protection = false  
  tags = var.tags
}



resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.eitan_alb.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }
}


provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.eks_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.eks_name]
      command     = "aws"
    }
  }
}

module "HELM" {
  for_each = var.charts
  source = "./HELM"
  eks_name = var.eks_name
  namespace = each.value.namespace
  app_name = each.key
  vpc_id = module.vpc.vpc_id
  alb = aws_lb.eitan_alb.arn
  listener_arn = aws_lb_listener.front_end.arn
  auto_scale_group = module.eks.eks_managed_node_groups_autoscaling_group_names[0]
  chart_version = each.value.chart_version
  helm_repository = each.value.helm_repository
  chart_name = each.value.chart_name
  value_sets = each.value.value_sets
  
}


output "load_balancer_url" {
  value = aws_lb.eitan_alb.dns_name
}