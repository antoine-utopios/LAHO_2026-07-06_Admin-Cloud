# Exercice 1.1 — Lecture de politiques IAM


## Contexte

Vous venez d'arriver comme administrateur cloud chez un client. Personne ne sait plus « qui a le droit de faire quoi » : votre première mission est d'auditer trois politiques trouvées sur le compte et de répondre précisément aux questions de l'équipe. C'est un exercice de lecture : ne devinez pas, **appliquez l'arbre d'évaluation** (deny explicite ? → refusé ; sinon allow ? → autorisé ; sinon → refusé).

## Énoncé

### Partie 1 — Politique A : S3 avec un préfixe interdit

La politique suivante est attachée au groupe `analystes` :

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "LectureDocuments",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::formation-documents",
        "arn:aws:s3:::formation-documents/*"
      ]
    },
    {
      "Sid": "InterdireConfidentiel",
      "Effect": "Deny",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::formation-documents/confidentiel/*"
    }
  ]
}
```

Répondez, en justifiant à chaque fois par le ou les statements applicables :

1. Un membre du groupe télécharge (`s3:GetObject`) le fichier `rapports/ventes-2026.csv` du bucket `formation-documents`. Autorisé ou refusé ?
2. Le même membre télécharge `confidentiel/salaires.xlsx`. Autorisé ou refusé ? Quel statement s'applique en dernier ressort ?
3. Il tente de **supprimer** (`s3:DeleteObject`) le fichier `rapports/ventes-2026.csv`. Autorisé ou refusé ? S'agit-il d'un deny explicite ou d'un deny implicite ?
4. Il liste le contenu du bucket (`s3:ListBucket`). Peut-il **voir dans la liste** que le dossier `confidentiel/` existe et les noms des fichiers qu'il contient ?
5. Un administrateur ajoute plus tard au groupe une politique `AmazonS3FullAccess` (gérée AWS, qui autorise `s3:*` sur `*`). Le téléchargement de `confidentiel/salaires.xlsx` devient-il possible ? Pourquoi ?

Résultat attendu : cinq réponses « autorisé / refusé » chacune justifiée par le nom (`Sid`) du statement décisif, et la distinction deny explicite / deny implicite correctement employée aux questions 2 et 3.

### Partie 2 — Politique B : EC2 sous conditions

La politique suivante est attachée à l'utilisateur `stagiaire-ops` (c'est sa **seule** politique) :

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "LectureEC2Partout",
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    },
    {
      "Sid": "LancerPetitesInstancesParisSeulement",
      "Effect": "Allow",
      "Action": "ec2:RunInstances",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "eu-west-3",
          "ec2:InstanceType": "t3.micro"
        }
      }
    }
  ]
}
```

Répondez, en citant la condition ou le statement décisif :

1. `stagiaire-ops` lance une instance `t3.micro` dans eu-west-3. Autorisé ou refusé ?
2. Il lance une instance `t3.micro` dans eu-central-1 (Francfort). Autorisé ou refusé ? Est-ce un deny explicite ?
3. Il lance une instance `m5.large` dans eu-west-3. Autorisé ou refusé ?
4. Il exécute `aws ec2 describe-instances --region us-east-1`. Autorisé ou refusé ?
5. Il tente d'**arrêter** (`ec2:StopInstances`) une instance existante à Paris. Autorisé ou refusé ?
6. Les deux clés de la `Condition` (`aws:RequestedRegion` et `ec2:InstanceType`) sont dans le **même** bloc `StringEquals`. L'instance doit-elle satisfaire les deux conditions, ou une seule suffit-elle ?

Résultat attendu : six réponses justifiées ; la question 6 doit expliciter que les conditions d'un même bloc se combinent en **ET** logique.

### Partie 3 — Politique gérée `ReadOnlyAccess` vs politique inline

Un auditeur externe dispose de la politique **gérée AWS** `ReadOnlyAccess`, dont voici un extrait représentatif (la vraie fait des milliers de lignes, maintenues par AWS) :

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadOnlyExtrait",
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "s3:Get*",
        "s3:List*",
        "iam:Get*",
        "iam:List*",
        "cloudwatch:Describe*",
        "cloudwatch:Get*",
        "cloudwatch:List*"
      ],
      "Resource": "*"
    }
  ]
}
```

Par ailleurs, vous découvrez sur l'utilisateur `dupont` une politique **inline** (collée directement sur l'utilisateur, sans nom réutilisable) :

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DepannageUrgentNePasGarder",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::formation-documents/*"
    }
  ]
}
```

Répondez :

1. L'auditeur (avec `ReadOnlyAccess`) peut-il lister les utilisateurs IAM du compte ? Peut-il en **créer** un ?
2. L'auditeur peut-il télécharger un objet S3 ? Peut-il en téléverser (`s3:PutObject`) un ?
3. Citez deux avantages concrets d'une politique **gérée** (AWS ou client) par rapport à une politique **inline**.
4. La politique inline de `dupont` autorise `s3:*` sur les objets du bucket. Peut-il pour autant **supprimer le bucket** lui-même (`s3:DeleteBucket`) ? Regardez bien le `Resource`.
5. En audit, pourquoi les politiques inline sont-elles plus difficiles à repérer que les politiques gérées ? Quel risque le `Sid` de celle-ci révèle-t-il sur les pratiques de l'équipe ?

Résultat attendu : réponses argumentées ; la question 4 doit s'appuyer sur la différence entre l'ARN du bucket (`arn:aws:s3:::bucket`) et celui de ses objets (`arn:aws:s3:::bucket/*`).

## Indices (à consulter si bloqué)

<details>
<summary>Indice 1 — L'ordre d'évaluation, toujours le même</summary>

Pour chaque scénario, posez trois questions dans cet ordre :
1. Un statement `Deny` matche-t-il (action ET ressource ET condition) ? → refusé, fin.
2. Un statement `Allow` matche-t-il ? → autorisé.
3. Sinon → refusé (deny implicite).

L'ordre des statements dans le fichier JSON n'a **aucune** importance.

</details>

<details>
<summary>Indice 2 — Deny explicite vs deny implicite</summary>

- **Deny explicite** : un statement `"Effect": "Deny"` correspond à la requête. Aucun allow, présent ou futur, ne pourra jamais passer outre.
- **Deny implicite** : aucun statement ne correspond. C'est refusé « par défaut »… mais il suffirait d'ajouter un `Allow` pour que ça passe. C'est toute la différence pour la question A.5.

</details>

<details>
<summary>Indice 3 — Les jokers dans les actions et les ressources</summary>

- `ec2:Describe*` couvre `ec2:DescribeInstances`, `ec2:DescribeRegions`… mais pas `ec2:StopInstances`.
- `arn:aws:s3:::bucket/*` désigne les **objets** du bucket ; `arn:aws:s3:::bucket` (sans `/*`) désigne le **bucket** lui-même. `s3:ListBucket` porte sur le bucket, `s3:GetObject` sur les objets — c'est pour cela que la politique A liste les deux ARN.

</details>

<details>
<summary>Indice 4 — Les conditions multiples</summary>

À l'intérieur d'un même opérateur (`StringEquals`), toutes les clés listées doivent être satisfaites simultanément : c'est un **ET**. (Plusieurs *valeurs* pour une même clé formeraient un OU, mais ce n'est pas le cas ici.)

</details>

<details>
<summary>Indice 5 — Pour le bonus</summary>

Il existe des **variables de politique** : `${aws:username}` est remplacé au moment de la requête par le nom de l'utilisateur qui appelle. Un ARN d'utilisateur IAM s'écrit `arn:aws:iam::NUMERO_DE_COMPTE:user/NOM`. Dans une politique, on peut remplacer le numéro de compte par `*` ou le laisser explicite.

</details>

## Pour aller plus loin (bonus)

Écrivez de zéro une politique JSON complète qui autorise un utilisateur à consulter **uniquement sa propre fiche IAM** — c'est-à-dire l'action `iam:GetUser`, mais seulement sur lui-même — et rien d'autre. Utilisez la variable de politique `${aws:username}` dans le champ `Resource`.

Test mental de validation : attachée au groupe `formation-admins` (seule, sans autre politique), votre politique doit permettre à `abc-admin` de réussir `aws iam get-user --user-name abc-admin`, et le faire échouer sur `aws iam get-user --user-name def-admin`.
