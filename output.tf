
# VPC ID
output "vpc_id" {
  value = aws_vpc.vpc_dev.id
}

# ALB DNS NAME
output "alb_dns" {
  value = aws_lb.alb01.dns_name
}

# BASTION HOST IP ADDRESS
output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

output "hostname" {
  value = aws_route53_record.www.name
}
