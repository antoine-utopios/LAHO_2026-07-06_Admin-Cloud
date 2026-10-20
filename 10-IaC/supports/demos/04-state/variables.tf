variable "web_servers" {
  type = map(number)
  description = "Les ports externe des serveurs webs"
  default = {
    "web" = 8080
    "shop" = 8081
  }
}