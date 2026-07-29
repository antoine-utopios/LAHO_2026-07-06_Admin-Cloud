import argparse
import sys

import requests

URL_GEOCODAGE = "https://geocoding-api.open-meteo.com/v1/search"
URL_PREVISIONS = "https://api.open-meteo.com/v1/forecast"


def geocoder_ville(nom_ville: str, verbeux: bool = False) -> dict | None:
    """Renvoie {'nom', 'latitude', 'longitude'} pour la ville, ou None."""
    parametres = {"name": nom_ville, "count": 1, "language": "fr"}

    if verbeux:
        print(f"Appel API vers {URL_GEOCODAGE} avec {parametres}")

    reponse = requests.get(URL_GEOCODAGE, params=parametres, timeout=5)
    if reponse.status_code != 200:
        return None

    resultats = reponse.json().get("results")
    if not resultats:
        return None

    premier = resultats[0]
    return {
        "nom": premier["name"],
        "latitude": premier["latitude"],
        "longitude": premier["longitude"],
    }


def recuperer_previsions(latitude: float, longitude: float, jours: int,
                          verbeux: bool = False) -> dict | None:
    """Renvoie les listes de dates et températures min/max sur `jours` jours."""
    parametres = {
        "latitude": latitude,
        "longitude": longitude,
        "daily": "temperature_2m_max,temperature_2m_min",
        "forecast_days": jours,
        "timezone": "auto",
    }

    if verbeux:
        print(f"Appel API vers {URL_PREVISIONS} avec {parametres}")

    reponse = requests.get(URL_PREVISIONS, params=parametres, timeout=5)
    if reponse.status_code != 200:
        return None

    return reponse.json().get("daily")


def afficher_previsions(nom_ville: str, previsions: dict) -> None:
    print(f"\nPrévisions météo pour {nom_ville}")
    print(f"{'Date':<12}{'Min (°C)':>10}{'Max (°C)':>10}")
    print("-" * 32)
    for date, temp_min, temp_max in zip(
        previsions["time"],
        previsions["temperature_2m_min"],
        previsions["temperature_2m_max"],
    ):
        print(f"{date:<12}{temp_min:>10}{temp_max:>10}")


def main() -> None:
    parseur = argparse.ArgumentParser(
        description="Récupère les prévisions météo d'une ville via open-meteo.com."
    )
    parseur.add_argument("ville", help="nom de la ville (ex : Lille)")
    parseur.add_argument(
        "--jours", type=int, default=7,
        help="nombre de jours de prévisions à récupérer (défaut : 7)",
    )
    parseur.add_argument(
        "--verbose", action="store_true",
        help="affiche le détail des appels API effectués",
    )
    arguments = parseur.parse_args()

    if not 1 <= arguments.jours <= 16:
        print("Erreur : --jours doit être compris entre 1 et 16.", file=sys.stderr)
        sys.exit(1)

    try:
        ville = geocoder_ville(arguments.ville, verbeux=arguments.verbose)
        if ville is None:
            print(f"Erreur : ville '{arguments.ville}' introuvable.", file=sys.stderr)
            sys.exit(1)

        previsions = recuperer_previsions(
            ville["latitude"], ville["longitude"], arguments.jours,
            verbeux=arguments.verbose,
        )
        if previsions is None:
            print("Erreur : impossible de récupérer les prévisions.", file=sys.stderr)
            sys.exit(1)

    except requests.exceptions.RequestException:
        print("Erreur réseau : impossible de joindre l'API.", file=sys.stderr)
        sys.exit(1)

    afficher_previsions(ville["nom"], previsions)


if __name__ == "__main__":
    main()
