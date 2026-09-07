docker exec -it "gitlab-runner-01" gitlab-runner register \
  --url "https://gitlab.com" \
  --token "$TOKEN" \
  --name "runner-01" \
  --executor "docker" \
  --docker-image "docker:29" \
  --docker-volumes "//var/run/docker.sock:/var/run/docker.sock" \
  --docker-volumes "/cache"