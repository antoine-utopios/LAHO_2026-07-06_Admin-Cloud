variable "webservers_config" {
  type = map(number)
  default = {
    "web" = 8080
    "shop" = 8081
    "admin" = 8082
  }
}
