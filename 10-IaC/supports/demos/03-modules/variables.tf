variable "web_servers" {
  type        = map(number)
  description = "Les ports externe des serveurs webs"
  default = {
    "web"   = 8090
    "admin" = 8091
    "shop"  = 8092
  }
}
