variable "namespace" {
    type = string
    
}

variable "app_name" {
  type = string
}

variable "helm_repository" {
  type = string
}

variable "chart_version" {
  type = string
}
variable "chart_name" {
  type = string  
}

variable "value_sets" {
  type = map
}

variable "eks_name" {
  type = string  
}

variable "vpc_id" {
  type = string  
}

variable "alb" {
  type = string  
}

variable "listener_arn" {
  type = string
  
}

variable "auto_scale_group" {
  type = string
  
}