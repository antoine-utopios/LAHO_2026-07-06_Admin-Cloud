"""Import de commandes depuis un fichier CSV (déclencheur : S3, création d'objet dans imports/).

Format attendu (avec en-tête) :  client,produit,quantite,prix
Les lignes invalides sont ignorées et listées dans les logs ; les autres sont écrites dans DynamoDB.
"""
import csv
import io
import json
import os
import urllib.parse
import uuid
from datetime import datetime, timezone
from decimal import Decimal, InvalidOperation

import boto3

S3 = boto3.client("s3")
TABLE = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])


def lambda_handler(event, context):
    resultats = [importer(r["s3"]["bucket"]["name"], urllib.parse.unquote_plus(r["s3"]["object"]["key"]))
                 for r in event["Records"]]
    return {"fichiers": resultats}


def importer(bucket, cle):
    contenu = S3.get_object(Bucket=bucket, Key=cle)["Body"].read().decode("utf-8-sig")
    maintenant = datetime.now(timezone.utc).isoformat(timespec="seconds")
    importees, rejets = 0, []

    with TABLE.batch_writer() as lot:
        for numero, ligne in enumerate(csv.DictReader(io.StringIO(contenu)), start=2):
            try:
                quantite = int(ligne["quantite"])
                prix = Decimal(ligne["prix"].strip())
                client, produit = ligne["client"].strip(), ligne["produit"].strip()
                if not client or not produit or quantite <= 0 or prix < 0:
                    raise ValueError
            except (KeyError, ValueError, TypeError, InvalidOperation, AttributeError):
                rejets.append({"ligne": numero, "contenu": ligne})
                continue
            lot.put_item(Item={
                "id": uuid.uuid4().hex[:8], "client": client, "produit": produit,
                "quantite": quantite, "prix": prix, "total": prix * quantite,
                "source": f"import:{cle.rsplit('/', 1)[-1]}", "cree_le": maintenant,
            })
            importees += 1

    resultat = {"fichier": f"s3://{bucket}/{cle}", "importees": importees, "rejetees": len(rejets)}
    print(json.dumps(resultat, ensure_ascii=False))
    for rejet in rejets:
        print(json.dumps({"ligne_rejetee": rejet}, ensure_ascii=False))
    return resultat
