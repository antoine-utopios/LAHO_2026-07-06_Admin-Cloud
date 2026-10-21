variable "targets" {
  type        = map(number)
  description = "Les différents services et leur port externe"

  default = {
    web1 = 2221
    web2 = 2222
    db1  = 2223
  }
}