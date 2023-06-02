output "api_host" {
  value = aws_route53_record.api.name
}

output "api_fqdn" {
  value = join("", ["https://", aws_route53_record.api.name])
}
