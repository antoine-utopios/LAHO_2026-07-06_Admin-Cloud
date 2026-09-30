---
marp: true
title: Admin Cloud — CL-AWS1 — Jour 2
theme: utopios
paginate: true
author: Ihab ABADI
header: "![h:70px](https://utopios-marp-assets.s3.eu-west-3.amazonaws.com/logo_blanc.svg)"
footer: "Utopios® Tous droits réservés"
client: Utopios
---

<!-- _class: lead -->

# EC2 : votre première machine dans le cloud

## La VM du bloc Linux… mais à la demande, par API

CL-AWS1 — Jour 2 — Automatiser, superviser, sécuriser

---

<style scoped>
div{ font-size:15px }
</style>

## Objectifs de la journée

<div>

À la fin de la journée, vous saurez :

- **Lancer une instance EC2** depuis la console puis entièrement à la CLI, à partir de la bonne AMI Ubuntu 24.04 (résolue proprement, jamais codée en dur).
- **Choisir un type d'instance** (familles t/m/c/r/g, nomenclature `t3.micro`) et repérer ce qui reste dans le free-tier.
- **Vous connecter en SSH** avec une key pair, à travers un security group restreint à votre IP.
- **Automatiser l'installation** de la machine au boot avec le user data / cloud-init.
- **Interroger les métadonnées** d'instance en IMDSv2 et comprendre pourquoi le jeton est obligatoire.
- **Gérer le stockage** : volumes EBS, snapshots, restauration — et les **IP élastiques**.
- **Maîtriser le cycle de vie et la facturation** : ce qui coûte, quand, et comment tout détruire le soir.

Fil conducteur : hier vous avez préparé le compte ; aujourd'hui vous créez de la vraie infrastructure — et vous la détruisez proprement.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Plan de la journée

<div>

1. **EC2 et les AMI** — la VM à la demande, l'image de départ.
2. **Familles et types d'instances** — nomenclature, free-tier, burstables.
3. **Key pairs, SSH et security group** — vos réflexes du bloc Linux, version cloud.
4. **Lancement et user data** — console puis CLI, la machine qui s'installe seule. 💻 Démo
5. **Métadonnées et IMDSv2** — la carte d'identité de l'instance, sécurisée.
6. **EBS et IP élastiques** — disques, snapshots, adresses fixes. 💰
7. **Cycle de vie et facturation** — stop, terminate, et le teardown du soir.

✏️ 2 exercices — 💻 1 grande démo — 🧠 quiz de fin de journée.

Rappel d'hier (J1) : compte sandbox, alerte de budget 10 USD, utilisateur IAM `$PREFIX-admin`, CLI v2 avec le profil `formation`, région **eu-west-3** (Paris).

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Mise en route (à faire maintenant)

<div>

Ouvrez un terminal et posez le contexte de la journée — **toutes** les commandes du jour supposent ces deux variables :

```bash
export AWS_PROFILE=formation   # le profil CLI configuré hier (région eu-west-3 incluse)
export PREFIX=abc              # remplacez abc par VOTRE trigramme
```

Vérification (réflexe du J1) :

```bash
aws sts get-caller-identity --query 'Arn' --output text
# arn:aws:iam::123456789012:user/abc-admin
```

Règles de la journée :

- Toute ressource nommée porte votre préfixe : `$PREFIX-key`, `$PREFIX-sg-web`…
- **Rien ne survit à la journée** : le teardown fait partie du programme, pas de l'option.

</div>

---

<!-- _class: lead -->

# 1. EC2 et les AMI

## La machine virtuelle, à la demande

---

<style scoped>
div{ font-size:15px }
</style>

## EC2 = votre VM du bloc Linux… à la demande

<div>

**EC2** (Elastic Compute Cloud) fournit des **instances** : des machines virtuelles Linux ou Windows, facturées à l'usage.

Rien de magique : c'est la même chose que la VM Ubuntu du bloc CL-LINUX et du TP1 StockLine, avec trois différences fondamentales :

- **À la demande** : elle existe en ~40 secondes, elle disparaît en une commande. Plus d'hyperviseur à installer, plus d'ISO à télécharger.
- **Par API** : tout ce que fait la console est un appel d'API — donc scriptable. « Tout est API » (leitmotiv du J1).
- **Facturée à la seconde** : on paie ce qu'on consomme, pas ce qu'on possède.

Ce qui ne change PAS : une fois connecté, c'est un Ubuntu 24.04 ordinaire — `systemd`, `nginx`, `apt`, SSH avec clés. **Tous vos acquis Linux s'appliquent tels quels.**

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Aujourd'hui : le VPC par défaut (et c'est voulu)

<div>

Une instance EC2 vit **toujours dans un réseau** : un **VPC** (Virtual Private Cloud) avec ses sous-réseaux — le plan d'adressage CIDR du bloc réseau, version AWS.

Point pédagogique important :

- AWS crée dans chaque région un **VPC par défaut** (CIDR `172.31.0.0/16`, un sous-réseau public par AZ, une passerelle Internet) précisément pour qu'on puisse **démarrer sans rien construire**.
- **Aujourd'hui, nous l'utilisons tel quel.** Toutes nos instances y atterrissent automatiquement.
- **Demain (J3), nous construirons notre propre VPC à la main** : sous-réseaux publics/privés, tables de routage, passerelles. Vous comprendrez alors tout ce que le VPC par défaut faisait pour vous.

C'est une démarche classique d'apprentissage AWS : utiliser le défaut, puis le remplacer en connaissance de cause.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## L'AMI : l'image de départ de l'instance

<div>

Une **AMI** (Amazon Machine Image) = le modèle à partir duquel l'instance est créée :

- **un système d'exploitation** (Ubuntu 24.04, Amazon Linux, Windows Server…),
- **des logiciels préinstallés** éventuels (une AMI peut embarquer nginx, Docker, une appli complète),
- le **contenu initial du disque racine** (un snapshot EBS, on y revient en section 6).

Analogie bloc Linux : l'AMI est à l'instance ce que l'ISO d'installation était à votre VM — sauf qu'ici le système est **déjà installé**, prêt à démarrer.

Nous utiliserons l'**AMI Ubuntu 24.04 LTS officielle de Canonical** (l'éditeur d'Ubuntu — la même distribution qu'en CL-LINUX).

⚠️ Un ID d'AMI (`ami-0abc…`) est **différent dans chaque région** et **change à chaque mise à jour de l'image**. Le copier en dur dans un script = script cassé tôt ou tard.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Trouver l'AMI proprement : le paramètre SSM public

<div>

Canonical publie l'ID de sa dernière AMI dans un **paramètre SSM public** (SSM Parameter Store : un service d'annuaire clé/valeur d'AWS). On l'interroge, on ne le devine pas :

```bash
AMI_ID=$(aws ssm get-parameters \
  --names /aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id \
  --query 'Parameters[0].Value' --output text)

echo "$AMI_ID"
# ami-04a92520784b93e73   (exemple : la valeur évolue avec les mises à jour)
```

Lecture du chemin : `canonical` (éditeur) / `ubuntu server 24.04 stable` / `current` (toujours la dernière) / `amd64` (architecture) / `hvm/ebs-gp3` (virtualisation + type de disque racine).

**Règle du cursus : jamais d'ID d'AMI en dur.** Toujours résolu à l'exécution — c'est votre premier réflexe d'automatisation de la journée.

</div>

---

<!-- _class: lead -->

# 2. Familles et types d'instances

## Choisir la bonne taille de machine

---

<style scoped>
div{ font-size:21px }
</style>

## Anatomie d'un type d'instance

<div>

```text
                t 3 . micro
                │ │    │
     famille ───┘ │    └─── taille : nano < micro < small
   (usage visé)   │         < medium < large < xlarge < 2xlarge…
   t = burstable  │         (à chaque cran : ~x2 vCPU et RAM)
                  │
        génération (3e) : plus récent = plus performant
                          et souvent MOINS cher

   t3.micro  = 2 vCPU (en rafale), 1 Gio de RAM
   m5.large  = 2 vCPU (constants), 8 Gio de RAM
```

Un **type d'instance** fige le matériel : vCPU, RAM, réseau. On ne « redimensionne » pas à chaud : on stoppe, on change le type, on redémarre.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Les familles, en survol

<div>

| Famille | Profil | Cas d'usage type | Ordre de prix (eu-west-3) |
|---|---|---|---|
| **t** | Burstable, généraliste éco | Dev, test, petits sites, notre formation | t3.micro ≈ 0,012 $/h |
| **m** | Généraliste équilibré (1 vCPU : 4 Gio) | Applis web de prod, StockLine en charge | m5.large ≈ 0,11 $/h |
| **c** | Optimisé calcul (1 vCPU : 2 Gio) | Encodage, batch CPU, calcul scientifique | c5.large ≈ 0,10 $/h |
| **r** | Optimisé mémoire (1 vCPU : 8 Gio) | Bases de données, caches en RAM | r5.large ≈ 0,15 $/h |
| **g** | GPU | ML/inférence, rendu graphique | g4dn.xlarge ≈ 0,65 $/h |

À retenir en tant qu'admin :

- On part du **besoin** (RAM ? CPU ? GPU ?), pas du catalogue.
- Il existe des centaines de types — connaître les **5 familles** suffit pour 95 % des choix.
- En formation : **t3.micro, toujours** (sauf mention contraire).

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Le free-tier EC2 : 750 heures par mois

<div>

Le free-tier (12 premiers mois du compte) inclut :

- **750 h/mois** d'instance **t2.micro** ou **t3.micro** (selon la région ; à Paris les deux existent, on prend t3.micro, plus récente),
- 30 Go de stockage EBS, 1 Go de snapshots.

750 h ≈ 31 jours × 24 h : **une** instance peut tourner **en continu** tout le mois gratuitement.

> 💰 **Coût — le piège des 750 h** : le quota est **global, pas par instance**. Deux t3.micro allumées en permanence = ~1 460 h → ~710 h facturées ≈ **8,40 $/mois**. Trois instances oubliées un week-end, ça se voit sur l'alerte de budget de 10 USD créée hier. D'où la règle : **teardown chaque soir**, on ne « garde pas pour demain ».

Vérifier ce qui tourne, à tout moment :

```bash
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].[InstanceId,InstanceType,Tags[?Key==`Name`]|[0].Value]' \
  --output table
```

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Instances burstables : les crédits CPU

<div>

La famille **t** est dite **burstable** (« en rafale ») : elle est peu chère parce qu'elle ne garantit pas 100 % du CPU en continu.

- Chaque instance a un **niveau de base** (baseline) : ~10 % d'un vCPU pour une t3.micro.
- Sous la baseline, elle **accumule des crédits CPU** ; au-dessus, elle les **dépense**.
- Crédits épuisés, deux comportements :
  - **mode `standard`** : le CPU est **bridé** à la baseline (l'appli rame, symptôme classique) ;
  - **mode `unlimited`** (défaut des t3) : le CPU continue… mais le dépassement est **facturé** (~0,05 $ par vCPU-heure).

Conséquences pratiques :

- Parfait pour dev/test/formation : charge irrégulière, longues périodes calmes.
- **À proscrire** pour une charge CPU soutenue (encodage 24/7) : soit ça rame, soit ça coûte plus cher qu'une famille c.
- Métrique à surveiller : `CPUCreditBalance` (on la reverra au chapitre supervision).

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ✏️ Exercice 2-1 — Choisir le bon type d'instance

<div>

**Sur papier, en binôme — 30 minutes.**

Six scénarios réalistes (API StockLine de test, base PostgreSQL de prod, encodage vidéo, serveur de dev, inférence ML, site vitrine) : pour chacun, **choisir famille + taille, justifier, dire si le free-tier suffit**.

Plus une question transverse sur les burstables, et un bonus de lecture de tarification.

📄 Énoncé : `exercices/06-cl-aws1/exercice-2-1-choix-instances.md`

Débriefing collectif juste après — il n'y a pas toujours UNE bonne réponse, il y a des **justifications** solides ou pas.

</div>

---

<!-- _class: lead -->

# 3. Key pairs, SSH et security group

## Vos réflexes du bloc Linux, version cloud

---

<style scoped>
div{ font-size:21px }
</style>

## La key pair : vos clés SSH, gérées par AWS

<div>

```text
   VOTRE POSTE                        AWS                INSTANCE EC2
 ┌──────────────────┐    ┌─────────────────────┐   ┌─────────────────────────┐
 │ ~/.ssh/           │    │ Key pair "abc-key"  │   │ user "ubuntu"           │
 │  abc-key.pem      │    │ (clé PUBLIQUE       │──▶│ ~/.ssh/authorized_keys  │
 │  (clé PRIVÉE,     │    │  seulement)         │   │  ← clé publique injectée│
 │   chmod 400)      │    └─────────────────────┘   │    par cloud-init       │
 └──────────────────┘                               └─────────────────────────┘
        └────────────── ssh -i ~/.ssh/abc-key.pem ubuntu@IP ─────────┘
```

Exactement le mécanisme du bloc CL-LINUX (`ssh-keygen`, `authorized_keys`) — AWS se charge juste de **livrer la clé publique** dans l'instance au premier boot. AWS **ne conserve jamais la clé privée** : perdue = pas de récupération.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Créer sa key pair à la CLI

<div>

```bash
aws ec2 create-key-pair \
  --key-name "$PREFIX-key" \
  --key-type ed25519 \
  --query 'KeyMaterial' --output text > ~/.ssh/$PREFIX-key.pem

chmod 400 ~/.ssh/$PREFIX-key.pem     # réflexe CL-LINUX : clé privée illisible par les autres
```

Points d'attention :

- `--key-type ed25519` : l'algorithme moderne vu au bloc Linux (par défaut AWS génère du RSA).
- `--query 'KeyMaterial' --output text` : extrait **la clé privée**, affichée **une seule fois** — d'où la redirection immédiate dans un fichier.
- Sans le `chmod 400`, SSH refusera la clé : `WARNING: UNPROTECTED PRIVATE KEY FILE!` — même erreur, même cause qu'au bloc Linux.

Vérifier :

```bash
aws ec2 describe-key-pairs --key-names "$PREFIX-key" \
  --query 'KeyPairs[0].[KeyName,KeyType]' --output text
# abc-key   ed25519
```

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Le security group d'accès : 22 pour vous, 80 pour tous

<div>

Rappel bloc réseau : un **security group** est un pare-feu **stateful** attaché à l'instance (la réponse à un flux autorisé passe toujours — contrairement aux NACL stateless).

Notre SG du jour, dans le VPC par défaut :

```bash
SG_ID=$(aws ec2 create-security-group \
  --group-name "$PREFIX-sg-web" \
  --description "Web + SSH restreint - formation J2" \
  --query 'GroupId' --output text)

MON_IP=$(curl -s https://checkip.amazonaws.com)   # votre IP publique actuelle

aws ec2 authorize-security-group-ingress --group-id "$SG_ID" \
  --protocol tcp --port 22 --cidr "${MON_IP}/32"      # SSH : VOUS, et personne d'autre
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" \
  --protocol tcp --port 80 --cidr "0.0.0.0/0"         # HTTP : public, c'est un site web
```

🔒 **Jamais `0.0.0.0/0` sur le port 22.** Une instance SSH ouverte au monde est scannée en quelques **minutes** (regardez `/var/log/auth.log`, on le fera en démo). `/32` = exactement une adresse — votre notation CIDR du bloc réseau.

</div>

---

<!-- _class: lead -->

# 4. Lancement et user data

## Console d'abord, CLI ensuite — puis la machine s'installe seule

---

<style scoped>
div{ font-size:15px }
</style>

## Lancer depuis la console : l'assistant, écran par écran

<div>

Console → EC2 → **Launch instance**. L'assistant tient en 7 blocs, tous à comprendre :

1. **Name and tags** : `$PREFIX-web-console` → devient le tag `Name`.
2. **Application and OS Images (AMI)** : Ubuntu Server 24.04 LTS — vérifiez l'éditeur **Canonical** et la mention *Free tier eligible*.
3. **Instance type** : `t3.micro` (*Free tier eligible*).
4. **Key pair** : `$PREFIX-key` — celle créée à la CLI (la preuve que console et CLI voient les mêmes objets : **tout est API**).
5. **Network settings** : VPC par défaut, *Auto-assign public IP: Enable*, **Select existing security group** → `$PREFIX-sg-web`.
6. **Configure storage** : 8 Gio **gp3** — le volume racine EBS (section 6).
7. **Advanced details** : tout en bas, **User data** (section suivante) et **Metadata version : V2 only (token required)**.

L'assistant n'est qu'un **formulaire qui construit un appel d'API**. La preuve dans deux slides.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## La même chose à la CLI : `run-instances`

<div>

```bash
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type t3.micro \
  --key-name "$PREFIX-key" \
  --security-group-ids "$SG_ID" \
  --user-data file://code/06-cl-aws1/user-data-nginx.sh \
  --metadata-options "HttpTokens=required,HttpEndpoint=enabled" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$PREFIX-web-cli}]" \
  --count 1 \
  --query 'Instances[0].InstanceId' --output text)

aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"   # bloque jusqu'à l'état running

aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text
# 51.44.112.87   (exemple)
```

Chaque option = un écran de l'assistant console. **Tout est API** : ce que la souris faisait en 3 minutes, la CLI le fait en 1 commande — donc un script peut le faire, donc c'est automatisable. C'est ça, le métier.

Connexion, avec vos réflexes CL-LINUX (utilisateur `ubuntu` sur les AMI Canonical) :

```bash
ssh -i ~/.ssh/$PREFIX-key.pem ubuntu@51.44.112.87
```

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## User data : la machine s'installe toute seule

<div>

Le **user data** est un script fourni **au lancement**, exécuté par **cloud-init** (outil standard des images cloud Ubuntu) :

- **une seule fois**, au **premier démarrage** (pas aux reboots),
- en **root** (pas de `sudo` dans le script),
- **après** le réseau — l'instance peut donc télécharger des paquets.

Le lien avec votre parcours :

> Au TP1 StockLine, vous avez installé nginx **à la main** : `ssh`, `sudo apt update`, `sudo apt install nginx`, configuration… Aujourd'hui, **la machine le fait seule au boot**. Vous venez de passer d'« administrer une machine » à « décrire ce qu'une machine doit être ». C'est le premier pas vers l'Infrastructure as Code (bloc 11).

**Automatiser** (le geste d'aujourd'hui) → **superviser** → **sécuriser** : le fil conducteur du cursus commence ici.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Notre script du jour — et comment vérifier qu'il a tourné

<div>

Fichier : `code/06-cl-aws1/user-data-nginx.sh` (fourni dans le dépôt de formation). Il fait trois choses :

1. `apt-get update && apt-get install -y nginx` — votre installation du TP1, automatisée.
2. Interroge les **métadonnées d'instance** en IMDSv2 (section suivante) : instance-id, type, AZ, IP privée.
3. Écrit une page `/var/www/html/index.html` qui affiche ces informations, servie par nginx.

Résultat : `curl http://IP_PUBLIQUE` → une page qui prouve que **personne ne s'est connecté** pour installer quoi que ce soit.

Vérifier / déboguer (à connaître par cœur) :

```bash
# une fois connecté en SSH sur l'instance :
sudo cat /var/log/cloud-init-output.log   # la sortie complète de VOTRE script
cloud-init status                          # status: done (ou running si pas fini)
```

Page 404 ou connexion refusée juste après le boot ? cloud-init **n'a pas fini** (apt prend ~1-2 min). On attend, on ne panique pas.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## 💻 Démo 2-1 — EC2 de bout en bout, avec user data

<div>

**~60 minutes, en direct.** Vous reproduisez chaque commande avec **votre** préfixe.

Au programme :

1. Key pair + security group + résolution d'AMI, à la CLI.
2. Lancement **console** (chaque écran commenté), user data collé, IMDSv2 imposé.
3. `curl` sur la page nginx auto-installée, SSH, lecture de `cloud-init-output.log`.
4. La même instance **en une seule commande** `run-instances`.
5. Métadonnées IMDSv2 : avec jeton ça marche, sans jeton → **401**.
6. Snapshot EBS du volume racine.
7. IP élastique : allocation, association, stop/start — qui garde son IP, qui la perd ?
8. **Teardown complet scripté**, avec vérifications.

📄 Script complet : `demos/06-cl-aws1/demo-2-1-ec2-userdata.md`

</div>

---

<!-- _class: lead -->

# 5. Métadonnées et IMDSv2

## La carte d'identité de l'instance — et pourquoi on la protège

---

<style scoped>
div{ font-size:15px }
</style>

## 169.254.169.254 : l'instance se renseigne sur elle-même

<div>

Depuis **l'intérieur** d'une instance (et seulement de là), l'adresse `169.254.169.254` sert les **métadonnées d'instance** (IMDS — Instance Metadata Service) :

- `instance-id`, `instance-type`, `ami-id`,
- `placement/availability-zone`, `local-ipv4`, `public-ipv4`,
- `security-groups`, tags, et surtout… les **identifiants temporaires IAM** si un rôle est attaché (J4).

Rappel bloc réseau : `169.254.0.0/16` est la plage **link-local** — non routable, jamais transmise par un routeur. C'est pour ça que l'adresse est la même sur toutes les instances du monde.

À quoi ça sert ? C'est ce qui permet à un script (comme notre user data) de **s'adapter à la machine où il tourne** sans rien coder en dur : « quel est mon ID ? ma zone ? mon IP ? ». La brique de base de toute automatisation EC2.

</div>

---

<style scoped>
div{ font-size:20px }
</style>

## IMDSv2 : pourquoi un jeton obligatoire (l'attaque SSRF)

<div>

```text
  IMDSv1 (dangereux)                     IMDSv2 (imposé aujourd'hui)
  ─────────────────────                  ──────────────────────────────
  Attaquant → votre appli web            1) PUT /latest/api/token
  "va chercher cette URL :"                 → jeton de session (TTL ≤ 6 h)
   http://169.254.169.254/...            2) GET /meta-data/...
        │                                    + header X-aws-ec2-metadata-token
        ▼                                
  L'appli (DANS l'instance) obéit,       Un simple GET forgé par SSRF
  un simple GET suffit →                 ne peut PAS faire le PUT préalable
  identifiants IAM exfiltrés 💥          → requête sans jeton = 401 ✋
```

**SSRF** (Server-Side Request Forgery) : faire faire une requête HTTP par le serveur à votre place. Avec IMDSv1, un simple GET volait les identifiants du rôle (cause de la fuite Capital One, 2019 — 100 M de clients).

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## IMDSv2 en pratique : imposer, puis interroger

<div>

**Imposer à la création** — nos lancements du jour le font déjà :

```bash
--metadata-options "HttpTokens=required,HttpEndpoint=enabled"
```

**Interroger, depuis l'instance** (le motif utilisé par notre user data) :

```bash
# 1. Obtenir un jeton de session (méthode PUT, TTL en secondes, max 21600 = 6 h)
TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# 2. Interroger en présentant le jeton
curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id
# i-0a1b2c3d4e5f67890
```

Sans jeton, quand `HttpTokens=required` :

```bash
curl -s -o /dev/null -w '%{http_code}\n' http://169.254.169.254/latest/meta-data/
# 401
```

Réflexe d'admin cloud : **IMDSv2 required sur toute instance, toujours.** C'est le « sécuriser » du fil conducteur — dès le jour 2.

</div>

---

<!-- _class: lead -->

# 6. EBS et IP élastiques

## Des disques qui survivent, des adresses qui ne bougent pas

---

<style scoped>
div{ font-size:15px }
</style>

## EBS : les disques de vos instances

<div>

**EBS** (Elastic Block Store) fournit des **volumes** : des disques réseau attachés aux instances (vus comme `/dev/nvme0n1` — vos réflexes `lsblk`/`df -h` du bloc Linux s'appliquent).

| Type | Usage | À retenir |
|---|---|---|
| **gp3** | SSD généraliste — **le défaut** | 3 000 IOPS de base, taille et IOPS réglables séparément |
| gp2 | SSD ancienne génération | IOPS liés à la taille — encore croisé, à migrer vers gp3 |
| io1 / io2 | SSD hautes performances | Bases de données exigeantes, IOPS provisionnés, cher |
| st1 / sc1 | Magnétique débit / froid | Gros volumes séquentiels, archives — pas pour un OS |

Le **volume racine** : créé depuis l'AMI au lancement (8 Gio gp3 pour notre Ubuntu), il contient l'OS. Par défaut, il est **supprimé avec l'instance** (`DeleteOnTermination=true` pour le racine) — les volumes ajoutés en plus, eux, survivent par défaut.

Ordre de prix : gp3 ≈ **0,09 $/Gio/mois** à Paris → nos 8 Gio ≈ 0,75 $/mois. Petit, mais **facturé même instance éteinte** (slide 💰 en section 7).

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Snapshots : la sauvegarde incrémentale des volumes

<div>

Un **snapshot** = photo d'un volume EBS à l'instant T, stockée **dans S3 en coulisse** (vous ne voyez pas le bucket, AWS le gère) :

- **Incrémental** : le premier copie tout, les suivants ne copient que les **blocs modifiés** — rapides et peu coûteux (~0,05 $/Gio/mois, sur les blocs réellement stockés).
- Un snapshot est **régional** (il survit à la perte de l'AZ du volume) et **copiable** vers une autre région.
- C'est aussi la matière première des **AMI personnalisées** : AMI = snapshot(s) + métadonnées de démarrage.

```bash
# Créer un snapshot du volume, puis attendre qu'il soit terminé
SNAP_ID=$(aws ec2 create-snapshot --volume-id "$VOL_ID" \
  --description "$PREFIX - racine web - J2" \
  --query 'SnapshotId' --output text)
aws ec2 wait snapshot-completed --snapshot-ids "$SNAP_ID"

# Restaurer = créer un NOUVEAU volume à partir du snapshot (dans l'AZ voulue)
aws ec2 create-volume --snapshot-id "$SNAP_ID" \
  --availability-zone eu-west-3a --volume-type gp3
```

Restaurer ne modifie jamais l'original : on crée un volume neuf, qu'on attache où on veut.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## IP élastiques : une adresse publique qui ne bouge plus

<div>

Constat (démontré tout à l'heure) : l'**IP publique classique** d'une instance est **rendue au stop** et **différente au start**. Gênant pour un DNS, un pare-feu distant, un client…

L'**Elastic IP (EIP)** est une IP publique **allouée à votre compte**, que vous associez/dissociez à volonté : elle **survit aux stop/start** de l'instance.

```bash
ALLOC_ID=$(aws ec2 allocate-address --query 'AllocationId' --output text)
aws ec2 associate-address --instance-id "$INSTANCE_ID" --allocation-id "$ALLOC_ID"
# ...et pour rendre l'adresse :
aws ec2 release-address --allocation-id "$ALLOC_ID"
```

> 💰 **Coût — l'EIP se paie dès qu'elle est allouée** : **0,005 $/h ≈ 3,60 $/mois**, qu'elle soit associée ou non, instance allumée ou pas. Les IPv4 publiques sont une ressource rare, AWS facture leur détention. Quota : **5 EIP par région** par défaut. Règle du cursus : **on libère (`release-address`) dès qu'on n'en a plus besoin** — une EIP « orpheline » est le grand classique de la facture surprise.

En prod on préfère souvent un nom DNS stable (load balancer — bloc 08) à une EIP. L'EIP reste utile pour un serveur unique à adresse fixe.

</div>

---

<!-- _class: lead -->

# 7. Cycle de vie et facturation

## Savoir ce qui coûte, quand — et tout éteindre proprement

---

<style scoped>
div{ font-size:20px }
</style>

## Le cycle de vie d'une instance

<div>

```text
                 run-instances
                      │
                      ▼
                 ┌─────────┐        ┌─────────┐
                 │ pending │───────▶│ running │◀────────────┐
                 └─────────┘        └────┬────┘             │
                                    stop │   ▲ start   ┌────┴─────┐
                                         ▼   │         │ pending  │
                                   ┌──────────┐        └──────────┘
                                   │ stopping │
                                   └────┬─────┘      terminate (running
                                        ▼             ou stopped)
                                   ┌─────────┐      ┌─────────────┐     ┌────────────┐
                                   │ stopped │─────▶│ shutting-   │────▶│ terminated │
                                   └─────────┘      │ down        │     │ (définitif)│
                                                    └─────────────┘     └────────────┘
```

`stopped` : redémarrable, disque conservé. `terminated` : **irréversible**, volume racine supprimé (par défaut).

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Ce que vous payez, état par état

<div>

Facturation du **calcul** EC2 : **à la seconde** (minimum 60 s), uniquement à l'état **running**. Une instance stoppée ne coûte **rien en calcul**. Mais l'instance n'est pas seule :

| Ressource | running | stopped | terminated |
|---|---|---|---|
| Calcul (vCPU/RAM) | ✅ facturé (à la seconde) | ❌ | ❌ |
| **Volume EBS** | ✅ facturé | **✅ facturé quand même** | ❌ (racine supprimé) |
| **EIP allouée** | ✅ 0,005 $/h | **✅ 0,005 $/h** | ✅ **tant que non libérée !** |
| Snapshots | ✅ | ✅ | ✅ tant que non supprimés |

> 💰 **Coût — « stoppée » ne veut pas dire « gratuite »** : le volume EBS (≈ 0,09 $/Gio/mois) et l'EIP continuent de compter. Et un snapshot ou une EIP **survivent au terminate** de l'instance. La facture ne s'arrête que quand **chaque** ressource est détruite ou libérée.

D'où la discipline : le teardown se vérifie ressource par ressource, pas « à l'œil ».

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Stop vs terminate — et le teardown du soir

<div>

- **`stop-instances`** : pause. On garde le disque, les tags, l'ID. On paie l'EBS. L'IP publique classique sera **perdue**.
- **`terminate-instances`** : destruction **définitive**. Volume racine supprimé (défaut), ID irrécupérable. C'est le geste de fin de journée.

Le rituel du soir (dans l'ordre — celui de la démo) :

```bash
aws ec2 terminate-instances --instance-ids "$INSTANCE_ID"
aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID"
aws ec2 release-address --allocation-id "$ALLOC_ID"        # EIP
aws ec2 delete-snapshot --snapshot-id "$SNAP_ID"           # snapshots
aws ec2 delete-security-group --group-id "$SG_ID"          # SG (après terminate !)
aws ec2 delete-key-pair --key-name "$PREFIX-key" && rm ~/.ssh/$PREFIX-key.pem
```

Puis on **vérifie** (instances, adresses, volumes, snapshots) — les commandes de contrôle sont dans la démo et l'exercice 2-2. Un SG ne se supprime pas tant qu'une instance l'utilise : d'où le `wait`.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## ✏️ Exercice 2-2 — Lancer, prouver, détruire (100 % CLI)

<div>

**45-60 minutes, en autonomie.** Le condensé de la journée :

- Lancer une instance `$PREFIX-exo22` (t3.micro, Ubuntu 24.04 via SSM, IMDSv2 required, tag Name) **entièrement à la CLI**.
- Avec un **user data modifié** : page nginx personnalisée affichant **votre trigramme** et **l'heure de boot**.
- Prouver le type d'instance **depuis les métadonnées**, constater l'IP perdue après un stop.
- **Teardown complet avec checklist de vérification** — la checklist est notée autant que le lancement.

📄 Énoncé : `exercices/06-cl-aws1/exercice-2-2-lancement-cli.md`

Indices fournis dans l'énoncé (balises dépliables) — essayez d'abord sans.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Récap — les points clés du jour

<div>

- **EC2 = votre VM Linux, à la demande, par API.** Tout ce que fait la console, la CLI le fait — et donc un script.
- **AMI jamais en dur** : résolue via le paramètre SSM public de Canonical.
- **t3.micro** : famille burstable (crédits CPU), free-tier **750 h/mois tous types confondus**.
- **Key pair** = clé SSH classique ; AWS injecte la publique dans `authorized_keys` de `ubuntu` ; privée en `chmod 400`, jamais récupérable.
- **SSH : port 22 depuis VOTRE /32 uniquement** — jamais 0.0.0.0/0.
- **User data / cloud-init** : la machine s'installe seule au premier boot, en root ; débogage dans `/var/log/cloud-init-output.log`.
- **IMDSv2 required, toujours** : jeton PUT obligatoire → coupe les SSRF.
- **EBS** : gp3 par défaut, snapshots incrémentaux (S3 en coulisse), **facturé même instance stoppée**.
- **EIP** : fixe, mais **payante dès l'allocation** (~3,60 $/mois) — à libérer.
- **Facturation à la seconde en running ; terminate + vérifications chaque soir.**

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## 🧠 Quiz — questions 1 et 2

<div>

**Question 1**

Vous copiez l'ID d'AMI `ami-04a92520784b93e73` (qui fonctionne en eu-west-3) dans un script que vous exécutez en eu-west-1. Que se passe-t-il, et quelle est la bonne pratique pour obtenir l'AMI Ubuntu 24.04 dans n'importe quelle région ?

**Question 2**

Dans le type d'instance `t3.micro`, que désignent respectivement le `t`, le `3` et le `micro` ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## 🧠 Quiz — questions 3 et 4

<div>

**Question 3**

Le free-tier EC2 offre 750 h/mois de t2.micro/t3.micro. Vous laissez tourner **deux** t3.micro en continu pendant un mois de 30 jours. Combien d'heures sont facturées ?

**Question 4**

Une instance t3 a épuisé ses crédits CPU alors que la charge reste forte. Décrivez ce qui se passe selon que le mode crédit est `standard` ou `unlimited` — et lequel est le défaut sur t3.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## 🧠 Quiz — questions 5 et 6

<div>

**Question 5**

Quand vous lancez une instance Ubuntu avec la key pair `$PREFIX-key` : où la clé **publique** est-elle déposée dans l'instance, avec quel utilisateur vous connectez-vous, et pourquoi AWS ne peut-il pas vous redonner la clé privée si vous la perdez ?

**Question 6**

Pourquoi la règle d'entrée SSH d'un security group ne doit-elle jamais être `0.0.0.0/0` ? Quelle valeur CIDR utilise-t-on à la place, et comment l'obtenir en une commande ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## 🧠 Quiz — questions 7 et 8

<div>

**Question 7**

À quel(s) moment(s) le script user data s'exécute-t-il, avec quels droits, et dans quel fichier de l'instance vérifiez-vous sa sortie s'il semble ne pas avoir fonctionné ?

**Question 8**

Qu'est-ce qui différencie IMDSv2 d'IMDSv1 dans la façon d'interroger `169.254.169.254`, et quel type d'attaque cette différence rend-elle beaucoup plus difficile ?

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## 🧠 Quiz — questions 9 et 10

<div>

**Question 9**

Une instance est à l'état `stopped` toute la nuit. Citez **deux** ressources qui continuent d'être facturées malgré l'arrêt, et dites ce que devient son IP publique classique au redémarrage.

**Question 10**

Quelle est la différence entre `stop-instances` et `terminate-instances` pour l'instance **et** pour son volume racine EBS ? Quelle propriété du volume racine explique ce comportement, et quelle est sa valeur par défaut ?

</div>

---

<!-- _class: lead -->

# À demain

## Jour 3 — Construire VOTRE réseau

Aujourd'hui, vos instances ont vécu dans le **VPC par défaut** — un réseau prêt-à-l'emploi dont vous n'avez rien choisi.

Demain, vous le construisez **à la main** : votre VPC, vos **sous-réseaux publics et privés**, votre **Internet Gateway**, votre **NAT Gateway**.

Le plan d'adressage CIDR du bloc réseau devient réel — et vous ne verrez plus jamais « Auto-assign public IP » comme de la magie.
