output "dns_cert_verification_record" {
  value = aws_amplify_domain_association.primary.certificate_verification_dns_record
}


output "dns_record" {
  value = aws_amplify_domain_association.primary.sub_domain[*].dns_record
}
