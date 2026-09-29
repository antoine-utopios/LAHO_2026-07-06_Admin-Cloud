# syntax=docker/dockerfile:1
# =============================================================================
# StockLine — image de production de l'API FastAPI
# Multi-stage : une étape "builder" installe les dépendances dans un venv,
# l'image finale ne contient que le venv et le code (pas pip cache, pas gcc).
# =============================================================================

# ---------- Étape 1 : builder — installation des dépendances ----------
FROM python:3.12-slim AS builder

WORKDIR /app

# On copie SEULEMENT requirements.txt d'abord : tant qu'il ne change pas,
# cette couche (et le pip install) reste en cache même si le code change.
COPY requirements.txt .

# Le venv rend les dépendances copiables d'une étape à l'autre en un COPY.
# psycopg2-binary est ajouté explicitement : il est commenté dans le
# requirements.txt du dépôt (SQLite par défaut en local), mais en conteneur
# la base cible est PostgreSQL.
RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir --upgrade pip \
    && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt \
    && /opt/venv/bin/pip install --no-cache-dir psycopg2-binary==2.9.10

# ---------- Étape 2 : image finale — la plus petite possible ----------
FROM python:3.12-slim

# Utilisateur applicatif dédié : le processus ne tourne PAS en root.
RUN groupadd --system stockline \
    && useradd --system --gid stockline --create-home stockline

WORKDIR /app

# Les dépendances viennent de l'étape builder, rien d'autre.
COPY --from=builder /opt/venv /opt/venv

# Le code applicatif en dernier : c'est lui qui change le plus souvent.
COPY --chown=stockline:stockline app/ ./app/

# /app doit être inscriptible par l'utilisateur applicatif pour le mode
# SQLite par défaut (docker run sans DATABASE_URL). Avec PostgreSQL,
# ce droit ne sert plus mais ne coûte rien.
RUN chown stockline:stockline /app

ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1

USER stockline

# Documentation du port d'écoute (n'ouvre rien : c'est -p / ports: qui publie).
EXPOSE 8000

# Le démon interroge /sante : l'endpoint vérifie l'API ET la base de données.
# python -c remplace curl, absent de l'image slim.
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD python -c "import sys, urllib.request; \
r = urllib.request.urlopen('http://127.0.0.1:8000/sante', timeout=2); \
sys.exit(0 if r.status == 200 else 1)"

# Forme exec (liste JSON) : uvicorn est PID 1 et reçoit les signaux (SIGTERM).
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
