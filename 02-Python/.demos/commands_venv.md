# Commandes relatives aux environnements virtuels en Python

## Générer un environnement virtuel 

```bash
# Windows
py -m venv .venv

# MacOS / Linux
python3 -m venv .venv
```

## Exploiter un environnement virtuel 

```bash
# Windows (PowerShell)
.\.venv\Scripts\Activate.ps1

# Windows (Cmd)
.\.venv\Scripts\activate.bat

# MacOS / Linux
source .venv/Scripts/activate
```

## Installer des packages PIP 

```bash
pip install nom-package
```

## Sauvegarder l'ensenble de nos paquets PIP

```bash
pip freeze > nom-fichier.txt # Généralement requirements.txt
```

## Installer l'ensenble de nos paquets PIP

```bash
pip install -r nom-fichier.txt # Généralement requirements.txt
```