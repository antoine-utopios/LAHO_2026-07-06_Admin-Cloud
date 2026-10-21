# variable "webservers_config" {
#   type = map(object({
#     coontainer_name = string
#     ports = list(object({
#       internal = number
#       external = number
#     }))
#     env = set(string)
#   }))

#   default = {
#     "web" = {
#         coontainer_name = "web"
#         ports = [{ 
#             internal = 80 
#             external = 8080
#         }]
#         env = ["DB_URL=http://toto.example"]
#     }
#     "shop" = {
#         coontainer_name = "shop"
#         ports = [{ 
#             internal = 80 
#             external = 8081
#         }]
#         env = []
#     }
#     "admin" = {
#         coontainer_name = "admin"
#         ports = [{ 
#             internal = 80 
#             external = 8082
#         }]
#         env = ["REDIS_NAME=bidule"]
#     }
    
#   }
# }