variable "region" {
    type = string
    default = "us-east-2"
}

variable "availability_zone_1" {
  type = string
  default = "us-east-2a"
}

variable "availability_zone_2" {
  type = string
  default = "us-east-2b"
}


variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "subnets" {
  type = list
}

variable "eks_name" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "tags" {
  type = map
}

variable "charts" {
    type = map
    
}
