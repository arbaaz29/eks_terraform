# # Get all ALB ARNs in the region
# data "aws_lbs" "all" {}

# # Get details of each ALB
# data "aws_lb" "details" {
#   for_each = toset(data.aws_lbs.all.arns)
#   arn      = each.value
# }

# # Get the Route53 zone
# data "aws_route53_zone" "spring" {
#   name         = "spring-e-commerce.academy"
#   private_zone = false
# }

# # Create a CNAME record pointing to the first ALB (for example)
# resource "aws_route53_record" "alb" {
#   zone_id = data.aws_route53_zone.spring.zone_id
#   name    = "argocd.spring-e-commerce.academy"
#   type    = "CNAME"
#   ttl     = 300

#   # Use the DNS name of the first ALB in the list
#   records = [
#     values(data.aws_lb.details)[0].dns_name
#   ]
# }
