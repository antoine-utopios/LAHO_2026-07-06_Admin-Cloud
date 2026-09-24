# Guide pour l'instalation du runner:

## docker.compose.yml

```yml
services:
  gitlab-runner:
    image: 'gitlab/gitlab-runner:latest'
    container_name: gitlab-runner
    restart: always
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - runner_config:/etc/gitlab-runner
volumes:
  runner_config:
```

## Sous Windows (bash)

```bash
docker compose up -d
MSYS_NO_PATHCONV=1 docker exec -it gitlab-runner gitlab-runner register \
  --non-interactive \
  --url "https://gitlab.com/" \
  --token "ton token" \
  --executor "docker" \
  --docker-image "docker:24.0.5" \
  --description "Runner Windows" \
  --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
  --docker-volumes "/cache"
```

## Sous Mac/Linux 

```bash
docker exec -it gitlab-runner gitlab-runner register \
  --non-interactive \
  --url "https://gitlab.com/" \
  --token "VOTRE_TOKEN_GITLAB" \
  --executor "docker" \
  --docker-image "docker:24.0.5" \
  --description "Runner Mac avec Socket" \
  --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
  --docker-volumes "/cache"
```