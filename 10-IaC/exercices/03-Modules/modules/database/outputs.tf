output "connection_string" {
  value = "Server=${local.container_name};Database=${var.database_name};Uid=${var.user_name};Pwd=${var.user_password};"
}
