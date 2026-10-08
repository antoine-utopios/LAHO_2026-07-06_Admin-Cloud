#!/usr/bin/env bash
# CORRECTION — Partie 3 : copie du code et démarrage des conteneurs sur les 3 VM.
# Les VM back et db n'ont pas d'IP publique : on passe par vm-front en rebond SSH (-J).
set -euo pipefail
cd "$(dirname "$0")/.."

RG=${RG:-rg-tp-3tiers}
ADMIN=azureuser
FRONT_IP=$(az vm show -d -g "$RG" -n vm-front --query publicIps -o tsv)
SSH_OPTS=(-o StrictHostKeyChecking=accept-new)
JUMP=(-J "$ADMIN@$FRONT_IP")

# Secrets générés une fois, partagés entre vm-back et vm-db
ENV_FILE=$(mktemp)
cat > "$ENV_FILE" <<EOF
MYSQL_ROOT_PASSWORD=$(openssl rand -hex 16)
DB_NAME=tpdb
DB_USER=appuser
DB_PASSWORD=$(openssl rand -hex 16)
EOF

# Le front d'abord : enregistre sa clé d'hôte (nécessaire pour le rebond)
ssh "${SSH_OPTS[@]}" "$ADMIN@$FRONT_IP" "cloud-init status --wait >/dev/null && mkdir -p ~/app"

echo ">> vm-db"
ssh "${SSH_OPTS[@]}" "${JUMP[@]}" "$ADMIN@10.0.3.4" "cloud-init status --wait >/dev/null && mkdir -p ~/app/db"
scp "${SSH_OPTS[@]}" "${JUMP[@]}" azure/deploy/vm-db/compose.yml "$ADMIN@10.0.3.4:app/"
scp "${SSH_OPTS[@]}" "${JUMP[@]}" db/init.sql "$ADMIN@10.0.3.4:app/db/"
scp "${SSH_OPTS[@]}" "${JUMP[@]}" "$ENV_FILE" "$ADMIN@10.0.3.4:app/.env"
ssh "${SSH_OPTS[@]}" "${JUMP[@]}" "$ADMIN@10.0.3.4" "cd ~/app && sudo docker compose up -d"

echo ">> vm-back"
ssh "${SSH_OPTS[@]}" "${JUMP[@]}" "$ADMIN@10.0.2.4" "cloud-init status --wait >/dev/null && mkdir -p ~/app"
scp "${SSH_OPTS[@]}" "${JUMP[@]}" azure/deploy/vm-back/compose.yml "$ADMIN@10.0.2.4:app/"
scp "${SSH_OPTS[@]}" "${JUMP[@]}" -r backend "$ADMIN@10.0.2.4:app/"
scp "${SSH_OPTS[@]}" "${JUMP[@]}" "$ENV_FILE" "$ADMIN@10.0.2.4:app/.env"
ssh "${SSH_OPTS[@]}" "${JUMP[@]}" "$ADMIN@10.0.2.4" "cd ~/app && sudo docker compose up -d --build"

echo ">> vm-front"
scp "${SSH_OPTS[@]}" azure/deploy/vm-front/compose.yml "$ADMIN@$FRONT_IP:app/"
scp "${SSH_OPTS[@]}" -r frontend "$ADMIN@$FRONT_IP:app/"
ssh "${SSH_OPTS[@]}" "$ADMIN@$FRONT_IP" "cd ~/app && sudo docker compose up -d --build"

rm -f "$ENV_FILE"
echo ">> Application disponible sur http://$FRONT_IP"
