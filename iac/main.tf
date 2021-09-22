locals {
  aws_profile = "default"
  account_id = data.aws_caller_identity.current.account_id
  ecr_repo_url = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}

provider "aws" {
  region = var.aws_region
  profile = local.aws_profile
}

resource "aws_cloudwatch_log_group" "dummyCW" {
  name = var.cloudwatch_group
}

resource "aws_vpc" "dummy_vpc" {
  cidr_block = var.vpc_cdir
  enable_dns_hostnames = true
  enable_dns_support   = true
}
