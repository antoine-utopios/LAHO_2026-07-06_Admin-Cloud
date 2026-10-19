output "website_urls" {
  value = { for name, outputs in module.websites : name => outputs.url }
}