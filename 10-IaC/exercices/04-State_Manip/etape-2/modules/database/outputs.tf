output "connection_string" {
  value = "Server=${var.container_name};Database=${var.database_name};Uid=root;Pwd=${var.root_password};"
}
