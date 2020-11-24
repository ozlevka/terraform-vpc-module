provider "aws" {
    region  = "us-east-1"
    profile = "2auth" 
}

module "ww-vpc" {
    source              = "../"
    aws_region          = "us-east-1"
    project_name        = "vpc-module-test"
    azs                 = ["a","b","c","d","f"] 
    vpc_cidr            = "172.25.0.0/16"
    cidr_bytes          = 7 
    enable_peering      = true
    peering_vpc_id      = "vpc-088350d85ac6af536"
    peering_rtb_id      = "rtb-014dc2988975a6319"
    peering_sg_id       = "sg-039240e6e1665cd9b"
    route53_zone_id     = "Z0270810106Q46U1V1RLC"
    sg_ingress_networks = [
        {
           from_port   = 22,
           to_port     = 22,
           cidr_blocks  = ["31.154.47.228/32", "84.229.88.180/32"]
           protocol    = "tcp"
           description = "Just from WFH"
       }
    ]
}