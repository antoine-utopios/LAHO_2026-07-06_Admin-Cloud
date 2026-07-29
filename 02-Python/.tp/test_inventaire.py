"""Tests pytest du mini-projet inventaire (vus en J4).

Lancement : pytest test_inventaire.py -v
"""

import json
from pathlib import Path

import pytest
import yaml

from inventaire import charger_hotes, controler_hotes, ecrire_rapport, ping


def test_ping_localhost_repond():
    assert ping("127.0.0.1") is True


def test_ping_adresse_documentation_ne_repond_pas():
    # 192.0.2.1 est réservée à la documentation (RFC 5737) : jamais joignable.
    assert ping("192.0.2.1") is False


def test_charger_hotes(tmp_path: Path):
    fichier = tmp_path / "hotes.yaml"
    fichier.write_text(
        yaml.safe_dump({"hotes": [{"nom": "a", "adresse": "127.0.0.1"}]}),
        encoding="utf-8",
    )
    hotes = charger_hotes(fichier)
    assert len(hotes) == 1
    assert hotes[0]["nom"] == "a"


def test_charger_hotes_fichier_absent(tmp_path: Path):
    with pytest.raises(SystemExit):
        charger_hotes(tmp_path / "inexistant.yaml")


def test_controler_hotes_ignore_hote_sans_adresse():
    resultats = controler_hotes([{"nom": "sans-adresse"}], timeout_s=1)
    assert resultats == []


def test_ecrire_rapport(tmp_path: Path):
    resultats = [
        {"nom": "a", "adresse": "127.0.0.1", "role": "test", "joignable": True},
        {"nom": "b", "adresse": "192.0.2.1", "role": "test", "joignable": False},
    ]
    chemin = tmp_path / "rapport.json"
    resume = ecrire_rapport(resultats, chemin)

    assert resume["total"] == 2
    assert resume["joignables"] == 1
    assert resume["injoignables"] == 1

    contenu = json.loads(chemin.read_text(encoding="utf-8"))
    assert contenu["total"] == 2
    assert len(contenu["hotes"]) == 2
