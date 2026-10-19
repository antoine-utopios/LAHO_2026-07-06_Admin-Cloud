output "image_name" {
  value = var.image_name
}

output "urls" {
  value = { for name, port in var.web_servers : name => "http://localhost:${port}" }
}