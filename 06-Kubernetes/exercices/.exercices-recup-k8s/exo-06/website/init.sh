#!/bin/sh
# Récupère la première IP du conteneur
IP=$(hostname -i)

cat > /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>Réplica NGINX</title>
  <style>
    body { font-family: sans-serif; display: flex; justify-content: center;
           align-items: center; height: 100vh; margin: 0; background: #f0f4f8; }
    .card { background: white; padding: 2rem 3rem; border-radius: 12px;
            box-shadow: 0 4px 16px rgba(0,0,0,.1); text-align: center; }
    h1 { color: #2d6a4f; }
    code { background: #e8f4ea; padding: .2rem .6rem; border-radius: 4px; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Adresse IP du conteneur</h1>
    <p><code>${IP}</code></p>
  </div>
</body>
</html>
EOF

exec nginx -g "daemon off;"