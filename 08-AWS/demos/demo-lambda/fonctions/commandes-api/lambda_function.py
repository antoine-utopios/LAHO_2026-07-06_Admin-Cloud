"""API HTTP de gestion des commandes (déclencheur : API Gateway HTTP API, format 2.0).

Routes :
  GET  /                 page web (liste + formulaire)
  GET  /commandes        liste des commandes (JSON)
  POST /commandes        créer une commande (JSON)
  GET  /commandes/{id}   détail d'une commande (JSON)
"""
import base64
import html
import json
import os
import uuid
from datetime import datetime, timezone
from decimal import Decimal, InvalidOperation

import boto3

# Créé une seule fois par environnement d'exécution, puis réutilisé entre les invocations.
TABLE = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])
APP_VERSION = os.environ.get("APP_VERSION", "v1")
COULEUR = os.environ.get("APP_COULEUR", "#2563eb")

# True uniquement pour la première invocation d'un environnement : c'est le démarrage à froid.
demarrage_a_froid = True


def lambda_handler(event, context):
    global demarrage_a_froid
    froid, demarrage_a_froid = demarrage_a_froid, False

    route = event.get("routeKey", "")
    print(json.dumps({"route": route, "demarrage_a_froid": froid, "version": context.function_version}))

    if route == "GET /":
        return page_html(context, froid)
    if route == "GET /commandes":
        return reponse(200, {"commandes": lister()})
    if route == "POST /commandes":
        return creer(event)
    if route == "GET /commandes/{id}":
        item = TABLE.get_item(Key={"id": event["pathParameters"]["id"]}).get("Item")
        return reponse(200, item) if item else reponse(404, {"erreur": "commande introuvable"})
    return reponse(404, {"erreur": f"route inconnue : {route}"})


def creer(event):
    try:
        corps = event.get("body") or "{}"
        if event.get("isBase64Encoded"):
            corps = base64.b64decode(corps).decode()
        donnees = json.loads(corps)
        client = str(donnees["client"]).strip()
        produit = str(donnees["produit"]).strip()
        quantite = int(donnees["quantite"])
        prix = Decimal(str(donnees["prix"]))
        if not client or not produit or quantite <= 0 or prix < 0:
            raise ValueError
    except (KeyError, ValueError, TypeError, InvalidOperation, json.JSONDecodeError):
        return reponse(400, {"erreur": "champs attendus : client, produit, quantite (> 0), prix (>= 0)"})

    commande = {
        "id": uuid.uuid4().hex[:8],
        "client": client,
        "produit": produit,
        "quantite": quantite,
        "prix": prix,
        "total": prix * quantite,
        "source": "api",
        "cree_le": datetime.now(timezone.utc).isoformat(timespec="seconds"),
    }
    TABLE.put_item(Item=commande)
    return reponse(201, commande)


def lister():
    items, kwargs = [], {}
    while True:
        page = TABLE.scan(**kwargs)
        items += page["Items"]
        if "LastEvaluatedKey" not in page:
            break
        kwargs["ExclusiveStartKey"] = page["LastEvaluatedKey"]
    return sorted(items, key=lambda c: c.get("cree_le", ""), reverse=True)


def en_json(valeur):
    if isinstance(valeur, Decimal):
        return int(valeur) if valeur == valeur.to_integral_value() else float(valeur)
    raise TypeError


def reponse(statut, corps):
    return {
        "statusCode": statut,
        "headers": {"Content-Type": "application/json; charset=utf-8"},
        "body": json.dumps(corps, default=en_json, ensure_ascii=False),
    }


def page_html(context, froid):
    lignes = "".join(
        f"<tr><td>{html.escape(c['id'])}</td><td>{html.escape(c['client'])}</td>"
        f"<td>{html.escape(c['produit'])}</td><td class='n'>{c['quantite']}</td>"
        f"<td class='n'>{c['total']:.2f} €</td><td>{html.escape(c['source'])}</td></tr>"
        for c in lister()
    ) or "<tr><td colspan='6' class='vide'>Aucune commande pour le moment.</td></tr>"
    page = PAGE.format(
        couleur=COULEUR, version=html.escape(APP_VERSION), lignes=lignes,
        fonction=html.escape(context.function_name), version_lambda=html.escape(context.function_version),
        memoire=context.memory_limit_in_mb, requete=html.escape(context.aws_request_id),
        froid="oui (démarrage à froid)" if froid else "non (environnement réutilisé)",
    )
    return {"statusCode": 200, "headers": {"Content-Type": "text/html; charset=utf-8"}, "body": page}


PAGE = """<!doctype html><html lang="fr"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1"><title>Commandes</title>
<style>
body{{margin:0;font-family:system-ui,sans-serif;background:#f5f6f8;color:#1f2937}}
header{{background:{couleur};color:#fff;padding:14px 24px;display:flex;justify-content:space-between;align-items:center}}
header b{{font-size:1.1rem}} .badge{{background:rgba(255,255,255,.2);padding:3px 10px;border-radius:99px}}
main{{max-width:960px;margin:24px auto;padding:0 16px;display:grid;gap:20px}}
form{{display:flex;flex-wrap:wrap;gap:8px;background:#fff;padding:16px;border-radius:8px}}
input{{padding:8px;border:1px solid #d1d5db;border-radius:6px;font:inherit}}
button{{background:{couleur};color:#fff;border:0;padding:8px 16px;border-radius:6px;font:inherit;cursor:pointer}}
table{{width:100%;border-collapse:collapse;background:#fff;border-radius:8px;overflow:hidden}}
th,td{{padding:9px 12px;border-bottom:1px solid #e5e7eb;text-align:left}} th{{font-size:.8rem;color:#6b7280;text-transform:uppercase}}
.n{{text-align:right}} .vide{{color:#6b7280}} #msg{{color:#dc2626}}
footer{{max-width:960px;margin:0 auto 32px;padding:0 16px;font-size:.85rem;color:#4b5563;display:flex;flex-wrap:wrap;gap:6px 24px}}
</style></head><body>
<header><b>Commandes · AWS Lambda</b><span class="badge">{version}</span></header>
<main>
<form id="f">
<input name="client" placeholder="Client" required>
<input name="produit" placeholder="Produit" required>
<input name="quantite" type="number" min="1" value="1" required>
<input name="prix" type="number" min="0" step="0.01" placeholder="Prix unitaire" required>
<button>Créer la commande</button><span id="msg"></span>
</form>
<table><thead><tr><th>Id</th><th>Client</th><th>Produit</th><th class="n">Qté</th><th class="n">Total</th><th>Source</th></tr></thead>
<tbody>{lignes}</tbody></table>
</main>
<footer><span><b>Fonction :</b> {fonction}</span><span><b>Version Lambda :</b> {version_lambda}</span>
<span><b>Mémoire :</b> {memoire} Mo</span><span><b>Démarrage à froid :</b> {froid}</span><span><b>Requête :</b> {requete}</span></footer>
<script>
document.getElementById('f').addEventListener('submit', async e => {{
  e.preventDefault();
  const d = Object.fromEntries(new FormData(e.target));
  const r = await fetch('commandes', {{method: 'POST', headers: {{'Content-Type': 'application/json'}}, body: JSON.stringify(d)}});
  if (r.ok) location.reload(); else document.getElementById('msg').textContent = (await r.json()).erreur;
}});
</script>
</body></html>"""
