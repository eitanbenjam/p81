subnets = [
    {
      name = "eitan_task1"
      cidr = "10.0.13.0/24"
      availability_zone = "us-east-2a"
      
    },
    {
      name = "eitan_task2"
      cidr = "10.0.14.0/24"
      availability_zone = "us-east-2b"
    }    
]

eks_name = "eitan_eks"
vpc_name = "eitan_vpc"

tags = {
  
    "Name" = "zabbix"
    "Owner" = "Nati"
    "Department" = "Core"
    "Temp" = "True"  
}

charts = {  
  eitan-perimeter81-task = {
    namespace = "eitan"
    app_name = "eitan-perimeter81-task"
    helm_repository = "oci://369131898292.dkr.ecr.us-east-2.amazonaws.com"
    chart_version = "1.0.0"
    chart_name = "eitan-perimeter81-task-chart"
    value_sets = {
      repository = "369131898292.dkr.ecr.us-east-2.amazonaws.com"
      tag = "1.0.0"
      deploy_mode = "stage"
      replicas = 1
      pullPolicy = "Always"
      node_port = 32141

    }
  }  
}
