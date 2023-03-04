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
}

variable "vpc_name" {
  type = string
}

variable "subnets" {
  type = list
}
