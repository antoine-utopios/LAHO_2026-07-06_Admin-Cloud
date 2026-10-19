output "webserver_urls" {
  value = { for name, port in var.web_servers : name => "http://localhost:${port}" }
}

output "connection_string" {
  value = "Server=${docker_container.database.name};Database=testDB;Uid=user;Pwd=password;"
}
