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

###############################################################################
# HTTPS and DNS
###############################################################################

data "aws_route53_zone" "primary" {
  name         = "${var.zone_name}"
}

resource "aws_route53_record" "cert_for_domain" {
  zone_id     = data.aws_route53_zone.primary.zone_id
  name        = "${var.domain_name}"
  type        = "CNAME"
  ttl         = "5"
  records     = [aws_alb.dummy_load_balancer.dns_name]
  depends_on  = [aws_alb.dummy_load_balancer]
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.domain_name}"
  validation_method = "DNS"
}

resource "aws_route53_record" "validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.primary.zone_id
}

resource "aws_acm_certificate_validation" "validation_task" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_record : record.fqdn]
}
