"""Mini-projet J4 — Script d'inventaire de machines.

Lit un inventaire YAML, ping chaque hôte, produit un rapport JSON et un journal.

Exemples :
    python3 inventaire.py
    python3 inventaire.py --fichier hotes.yaml --rapport rapport.json
    python3 inventaire.py --timeout 2
"""

import argparse
import json
import logging
import platform
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

import yaml

journal = logging.getLogger("inventaire")


def configurer_journal(fichier_log: str) -> None:
    """Journalise à la fois vers la console et vers un fichier."""
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)-8s %(message)s",
        handlers=[logging.StreamHandler(), logging.FileHandler(fichier_log)],
    )


def charger_hotes(chemin: Path) -> list[dict]:
    """Charge le fichier YAML et renvoie la liste des hôtes.

    Le script s'arrête proprement (code 1) si le fichier est absent ou invalide.
    """
    try:
        with chemin.open(encoding="utf-8") as fichier:
            contenu = yaml.safe_load(fichier)
    except FileNotFoundError:
        journal.error("Fichier d'inventaire introuvable : %s", chemin)
        sys.exit(1)
    except yaml.YAMLError as erreur:
        journal.error("YAML invalide dans %s : %s", chemin, erreur)
        sys.exit(1)

    if not contenu or "hotes" not in contenu:
        journal.error("Le fichier %s ne contient pas de clé 'hotes'.", chemin)
        sys.exit(1)
    return contenu["hotes"]


def ping(adresse: str, timeout_s: int = 1) -> bool:
    """Ping l'adresse une fois. Renvoie True si l'hôte répond.

    L'option de timeout diffère entre Linux (-W, en secondes)
    et macOS (-W en millisecondes via -t sur certaines versions) :
    on reste portable avec -c 1 et un timeout côté subprocess.
    """
    option_nombre = "-n" if platform.system() == "Windows" else "-c"
    try:
        resultat = subprocess.run(
            ["ping", option_nombre, "1", adresse],
            capture_output=True,
            text=True,
            timeout=timeout_s + 1,
        )
    except subprocess.TimeoutExpired:
        return False
    return resultat.returncode == 0


def controler_hotes(hotes: list[dict], timeout_s: int) -> list[dict]:
    """Ping chaque hôte et construit la liste des résultats."""
    resultats = []
    for hote in hotes:
        nom = hote.get("nom", "?")
        adresse = hote.get("adresse")
        if not adresse:
            journal.warning("Hôte '%s' sans adresse : ignoré.", nom)
            continue
        joignable = ping(adresse, timeout_s)
        if joignable:
            journal.info("%s (%s) : joignable", nom, adresse)
        else:
            journal.warning("%s (%s) : INJOIGNABLE", nom, adresse)
        resultats.append(
            {
                "nom": nom,
                "adresse": adresse,
                "role": hote.get("role", "inconnu"),
                "joignable": joignable,
            }
        )
    return resultats


def ecrire_rapport(resultats: list[dict], chemin: Path) -> dict:
    """Écrit le rapport JSON et renvoie le résumé."""
    joignables = [r for r in resultats if r["joignable"]]
    rapport = {
        "genere_le": datetime.now(timezone.utc).isoformat(),
        "total": len(resultats),
        "joignables": len(joignables),
        "injoignables": len(resultats) - len(joignables),
        "hotes": resultats,
    }
    with chemin.open("w", encoding="utf-8") as fichier:
        json.dump(rapport, fichier, indent=2, ensure_ascii=False)
    return rapport


def main() -> None:
    parseur = argparse.ArgumentParser(
        description="Contrôle de disponibilité d'un parc de machines (ping)."
    )
    parseur.add_argument("--fichier", default="hotes.yaml",
                         help="inventaire YAML (défaut : hotes.yaml)")
    parseur.add_argument("--rapport", default="rapport.json",
                         help="rapport JSON de sortie (défaut : rapport.json)")
    parseur.add_argument("--log", default="inventaire.log",
                         help="fichier journal (défaut : inventaire.log)")
    parseur.add_argument("--timeout", type=int, default=1,
                         help="délai d'attente du ping en secondes (défaut : 1)")
    arguments = parseur.parse_args()

    configurer_journal(arguments.log)
    journal.info("Début du contrôle — inventaire : %s", arguments.fichier)

    hotes = charger_hotes(Path(arguments.fichier))
    resultats = controler_hotes(hotes, arguments.timeout)
    rapport = ecrire_rapport(resultats, Path(arguments.rapport))

    journal.info(
        "Terminé : %d hôte(s), %d joignable(s), %d injoignable(s). Rapport : %s",
        rapport["total"], rapport["joignables"], rapport["injoignables"],
        arguments.rapport,
    )
    # Code retour utile pour la supervision : 0 si tout va bien, 2 sinon.
    if rapport["injoignables"] > 0:
        sys.exit(2)


if __name__ == "__main__":
    main()
