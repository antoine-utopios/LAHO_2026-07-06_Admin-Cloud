output "website_urls" {
  value = { for name, outputs in module.websites : name => outputs.url }
}

output "connection_strings" {
    value = {
        "database_a" = module.database_mysql.connection_string
        "database_b" = module.database_mysql_bis.connection_string
    }
}