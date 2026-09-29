# StockLine conteneurisée — bloc CL-CONT (jours 1-3)

Version Docker de l'application fil rouge : l'API FastAPI de `code/stockline/`
empaquetée en image (multi-stage, non-root, HEALTHCHECK) et orchestrée par
docker compose avec PostgreSQL 16 et un front nginx (statique + reverse proxy).

## Contenu

```text
stockline-docker/
├── Dockerfile          # image de l'API : multi-stage, USER non-root, HEALTHCHECK /sante
├── .dockerignore       # ce qui n'entre jamais dans le contexte de build
├── compose.yaml        # pile complète : api (build) + db (postgres:16) + front (nginx)
├── nginx.conf          # front : statique + reverse proxy /api/ -> api:8000
├── front/index.html    # front adapté : fetch vers /api (même origine, via nginx)
├── .env.example        # modèle de configuration (à copier vers .env)
└── README.md
```

## Préparer le contexte de build

Le Dockerfile conteneurise **l'application du dépôt telle qu'elle existe**
(`code/stockline/`). Le contexte de build doit contenir `app/` et
`requirements.txt` ; copiez-les depuis le fil rouge :

```bash
cd code/13-cl-cont/stockline-docker
cp -r ../../stockline/app ../../stockline/requirements.txt .
```

> Pourquoi une copie et pas un chemin `../../stockline` dans `build:` ?
> Pour que le `.dockerignore` et le Dockerfile vivent avec leur contexte,
> et que le dossier soit autonome (c'est aussi ce que fera un dépôt réel :
> le Dockerfile à la racine du code qu'il empaquette).

Note : `psycopg2-binary` est commenté dans le `requirements.txt` du dépôt
(SQLite par défaut en local). Le Dockerfile l'installe explicitement — en
conteneur, la base cible est PostgreSQL.

## Démarrer la pile

```bash
cp .env.example .env          # puis éditez POSTGRES_PASSWORD
docker compose up -d --build
docker compose ps             # les 3 services, api et db "healthy"
```

- Front : <http://localhost:8080> (nginx sert la page et proxifie `/api/`)
- API directe (dev) : <http://localhost:8000/docs>

Test rapide :

```bash
curl -s http://localhost:8080/api/sante
# {"statut":"ok","base_de_donnees":"ok","version":"1.0.0"}

curl -s -X POST http://localhost:8080/api/produits \
  -H "Content-Type: application/json" \
  -d '{"reference": "SSD-500", "nom": "Disque SSD 500 Go", "prix_unitaire": 59.90, "seuil_alerte": 5}'
```

## Vérifier la persistance

```bash
docker compose down       # stoppe et supprime les conteneurs
docker compose up -d      # les produits sont toujours là (volume donnees-db)

docker compose down -v    # ATTENTION : -v supprime AUSSI le volume => données perdues
```

## Construire l'image seule (jour 2)

```bash
docker build -t stockline-api:1.0.0 .
docker run -d --name stockline-test -p 8000:8000 stockline-api:1.0.0
curl http://localhost:8000/sante   # SQLite par défaut : la base vit DANS le conteneur
docker rm -f stockline-test
```

## Pousser sur ECR

Voir `../push-ecr.sh` (et la démo `demos/13-cl-cont/demo-2-2-ecr-push.md`).
