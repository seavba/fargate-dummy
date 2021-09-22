###############################################################################
# AWS VPC
###############################################################################

variable "aws_region" {
  default = "eu-west-1"
}

variable "azs" {
  default = "eu-west-1a,eu-west-1b,eu-west-1c"
}

variable "vpc_name" {
  default = "vpc_dummy"
}

variable "vpc_cdir" {
  default = "10.99.0.0/16"
}


###############################################################################
# Dummy ECS
###############################################################################

variable "num_containers" {
  default = 2
}

variable "cloudwatch_group" {
  default = "dummyCW"
}

variable "ecr_image_tag" {
  default = "latest"
}

variable "ecr_repo" {
  default = "docker_images/dummy"
}

variable "ingress_rules" {
    type = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_block  = string
    }))
    default     = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_block  = "0.0.0.0/0"
        },
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_block  = "0.0.0.0/0"
        },
    ]
}

###############################################################################
# HTTPS and DNS
###############################################################################

variable "domain_name" {
  default = "dummybis.ssans.es"
}

variable "zone_name" {
  default = "ssans.es"
}

###############################################################################
# DATA BLOCK
###############################################################################

data "aws_caller_identity" "current" {}
