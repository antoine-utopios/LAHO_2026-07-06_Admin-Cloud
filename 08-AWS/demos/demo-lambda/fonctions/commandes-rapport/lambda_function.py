"""Rapport périodique des commandes (déclencheur : règle EventBridge planifiée).

Calcule le nombre de commandes, le chiffre d'affaires, le top 3 des produits et la répartition par
source, puis écrit le rapport en JSON dans s3://<BUCKET_NAME>/rapports/.
"""
import json
import os
from collections import Counter
from datetime import datetime, timezone
from decimal import Decimal

import boto3

S3 = boto3.client("s3")
TABLE = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])
BUCKET = os.environ["BUCKET_NAME"]


def lambda_handler(event, context):
    commandes, kwargs = [], {}
    while True:
        page = TABLE.scan(**kwargs)
        commandes += page["Items"]
        if "LastEvaluatedKey" not in page:
            break
        kwargs["ExclusiveStartKey"] = page["LastEvaluatedKey"]

    ca_par_produit = Counter()
    for c in commandes:
        ca_par_produit[c["produit"]] += c["total"]

    maintenant = datetime.now(timezone.utc)
    rapport = {
        "genere_le": maintenant.isoformat(timespec="seconds"),
        "declencheur": event.get("source", "manuel"),
        "nb_commandes": len(commandes),
        "chiffre_affaires": sum((c["total"] for c in commandes), Decimal(0)),
        "top_produits": [{"produit": p, "ca": ca} for p, ca in ca_par_produit.most_common(3)],
        "par_source": Counter("api" if c["source"] == "api" else "import" for c in commandes),
    }

    cle = f"rapports/rapport-{maintenant:%Y%m%d-%H%M%S}.json"
    corps = json.dumps(rapport, default=float, ensure_ascii=False, indent=2)
    S3.put_object(Bucket=BUCKET, Key=cle, Body=corps.encode(), ContentType="application/json")
    print(json.dumps({"rapport": f"s3://{BUCKET}/{cle}", "nb_commandes": len(commandes),
                      "chiffre_affaires": float(rapport["chiffre_affaires"])}, ensure_ascii=False))
    return {"rapport": cle, "nb_commandes": len(commandes)}
