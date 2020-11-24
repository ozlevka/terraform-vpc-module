# ww-terraform-vpc-module

Usage:

```HCL
module "ww-vpc" {
    source              = "git@github.com:windward-ltd/ww-terraform-vpc-module.git"
    aws_region          = "us-east-1"
    project_name        = "vpc-module-test"
    azs                 = ["a","b","c","d","f"] 
    vpc_cidr            = "172.25.0.0/16"
    cidr_bytes          = 8 
    sg_ingress_networks = var.sg_ingress
}
```
Also check [test file](https://github.com/windward-ltd/ww-terraform-vpc-module/blob/036a1d8edc90d57b0d55c01af9daba9a7cd4a3fe/test/main.tf#L6-L27) for example how to enable VPC to VPC peering connection.

* source => github url. You need ssh-client installed. Then use ```ssh-add [path to github key]```
* aws_region => AWS region when VPC will be installed
* project_name => this variable will be using in AWS objects names
* azs => avaliabilty zones when subnets will be created
* vpc_cidr => Cidr of VPC
* cidr_bytes => [IPs amount in subnet](https://www.terraform.io/docs/configuration/functions/cidrsubnet.html#netmasks-and-subnets) 
* sg_ingress_networks => security group variable. See example below

## Security group variable definition example
In this example 22 port defined for main WW VPC and for Open vpn.
```HCL
variable "sg_ingress" {
    type = list(object({
      from_port  = number
      to_port    = number
      cidr_blocks = list(string)
      description = string
      protocol    = string
   }))

   default    = [
       {
           from_port   = 22,
           to_port     = 22,
           cidr_blocks  = ["172.31.0.0/16", "172.27.0.0/16"]
           protocol    = "tcp"
           description = "Just from WFH"
       }
   ]
}
```