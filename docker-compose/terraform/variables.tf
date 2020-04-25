variable "amis" {
  default = "ami-007776654941e2586"
}

variable "region" {
  description = "This variable is for region"
  default = "us-east-1"
}

# variable "instance_count" {
#   description = "This variable is for number of instances"
#   default = 1
# }

variable "subnet_id" {
  default = "subnet-05987147d33749486"
}

variable "identifier" {
  description = "This variable is for identifier"
  default = "mysql"
}

variable "name" {
  description = "This variable is for name of the instance"
  default = "test-server"
}

variable "resource_for" {
  description = "This variable is for which resource is used this instance"
  default = "test-server"
}

variable "env" {
  description = "This variable is for enviroment"
  default = "dev"
}

variable "group" {
  description = "This variable is for group"
  default = "mysql"
}

variable "application" {
  description = "This variable is for application name"
  default = "mysql"
}

variable "vpc_id" {
  description = "This variable is for vpc id"
  default = "vpc-0c96e92df7cab6910"
}

variable "key_name" {
  description = "This variable is for ssh key name"
  default = "garland"
}


variable "instance_type" {
  description = "This variable is for instance type"
  default = "t3.micro"
}

variable "monitoring" {
  description = "This variable is for cloud watch monitoring. by default it is false"
  default = "false"
} 

variable "vpc_security_group_ids" {
 description = "This variable is for security groups"
 default = "sg-05987147d33749486"
}
 
variable "disable_api_termination" {
 description = "This variable is for api termination. by defaut this is true"
 default ="false"
 }
 