# perimeter_eitan
# repository goal
Create python script that return index.html file incase url is /index.htlm , else return the client geo location
1. script should run as a docker container
2. docker container should run in kubernetes
## Installation

in order to run the earnix_eitan server u need to perform the following steps:
1. clone repository :
```
git clone git clone https://github.com/eitanbenjam/p81.git
```
2. after repository cloned to your filesystem, we need to start docker-regitry container
```
cd p81/terraform
terraform init # will download all needed dependencies
terraform plan # will plan the action needed and show what will be perform
terraform apply -auto-approve # will start deploy
```
terraform will start deploying all the component
at the end you will see load-balancer DNS address
```
Outputs:
load_balancer_url = "earnixAlb-1171883708.us-east-1.elb.amazonaws.com"
```
to test:
open browser and browse to:
1. http://{loadbalancer-dns}/index.html
   you should get html file that says hello from eitan
2. http://{loadbalancer-dns}/<something>
   you should get info about your location
## Script:
echo_server.py is a python script that uses flask library as http server.
it has 2 apis:
//index.html - will load the index.html file and send it as a response
//isAlive - for kubernetes isAlive machanism
on other urls it fetch client ip (is AWS: uses X-Forwarded-For header , else get it from flask)

## HELM
chart as 3 template:
1. configMap.yaml - specify the deploy_mode env param
2. service.yaml - create nodePort service for the container
3. deployment.yaml - will create the pod

all values can be set in values.yaml 

## Terraform
### modules:
1. VPC - module that build a VPC with all the subnets
2. HELM - module that bring up helm chart and connect it to load balancer (create target group and add it to listener)
3. EKS - an existing module from https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v19.10.0 that create EKS cluster
### resource (in all.tf):
1. eks security group - allow 443 and 80 from outside, and kubernetes internal communication
2. alb security group - allow 443 and 80 from internet
3. application load balancer - for internet requetsts
4. listener on port 80 - for internet requetsts

## EKS
the docker image should already exist in ECR , it you dont have ECR there is terraform deployment to start it under ecr folder 

