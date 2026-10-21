moved {
  from = docker_container.web
  to = docker_container.servers["web"]
}
moved {
  from = docker_container.shop
  to = docker_container.servers["shop"]
}
moved {
  from = docker_container.admin
  to = docker_container.servers["admin"]
}