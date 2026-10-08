#!/usr/bin/env bash
# Supprime TOUTES les ressources du TP (irréversible)
set -euo pipefail
RG=${RG:-rg-tp-3tiers}
az group delete -n "$RG" --yes --no-wait
echo ">> Suppression de $RG lancée"
