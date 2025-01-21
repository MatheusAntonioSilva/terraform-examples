# Precisa de dominio comprado com certificado

# resource "aws_acm_certificate" "cert" {
#   domain_name               = var.domain
#   subject_alternative_names = ["*.${var.domain}"]
#   validation_method         = "DNS"
# }

# resource "aws_route53_record" "cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   name    = each.value.name
#   type    = each.value.type
#   zone_id = aws_route53_zone.primary.id
#   ttl     = 60
# }
# resource "aws_acm_certificate_validation" "cert" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
# }