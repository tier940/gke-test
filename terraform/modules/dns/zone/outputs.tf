output "private" {
  value = zipmap(keys(google_dns_managed_zone.private), values(google_dns_managed_zone.private)[*])
}

output "public" {
  value = zipmap(keys(google_dns_managed_zone.public), values(google_dns_managed_zone.public)[*])
}
