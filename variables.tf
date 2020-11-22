variable "vpc_cidr" {
   type = string
   description = "Cidr block for created VPC"
}

variable "project_name" {
  type        = string
  description = "Describe your current project name"
}

variable "cidr_bytes" {
   type   = number
   description = "CIDR calculation byte see https://www.terraform.io/docs/configuration/functions/cidrsubnet.html by default 8"
   default = 8
}

variable "azs" {
   type = list(string)
   description = "Availability zones for using in specific VPC"
}

variable "aws_region" {
   type = string
   description = "AWS region to create network"
}

variable "sg_ingress_networks" {
   type = list(object({
      from_port   = number
      to_port     = number
      cidr_blocks  = list(string)
      description = string
      protocol    = string
   }))
   default       = []
   description   = "List of ingress networks definitions for default security group" 
}