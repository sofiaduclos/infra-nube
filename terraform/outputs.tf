output "static_site_url" {
  value = module.static_site.url
}

output "pwa_url" {
  value = module.pwa.url
}

# Output the Load Balancer URL
output "load_balancer_url" {
  value = module.lb.load_balancer_dns_name
}