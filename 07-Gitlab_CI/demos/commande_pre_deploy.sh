# Générer la clé SSH en BASE64 à partir du fichier .pem récupéré sur AWS 
cat ./fichier_cle_aws.pem | base64 -w0 > ./fichier_cle_aws.pem.b64
# Si l'on veut l'utiliser en local, il lui faut les bons droits
chmod 600 ./fichier_cle_aws.pem

# Générer le contenu du fichier known_hosts en BASE64 à partir de l'URL de la machine EC2 sur AWS
ssh-keyscan -H -t ed25519 $URL_EC2 | base64 -w0 > ./fichier_cle_aws.pem.b64
# Si l'on veut l'utiliser en local, il lui faut les bons droits
ssh-keyscan -H -t ed25519 $URL_EC2 > known_hosts
chmod 644 known_hosts