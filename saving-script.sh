#!/bin/bash

# Script de sauvegarde global du serveur

# CONSTANTES
var_save_path=/docker-backup-tmp
var_nb_step=4

# -- STEP 1 - Sauvegarde de la configuration SSH
# -- STEP 2 - Sauvegarde iptables
# -- STEP 3 - Sauvegarde des repos stack
# -- STEP 3 - Sauvegarde des fichiers de la pile main (on live)

# -- STEP - Sauvegarde des services docker (hors pile principale)
# ----------- 4. Sauvegarde conteneur mail

echo "-------------
4/$var_nb_step : SAUVEGARDE SERVEUR MAIL
-------------"

echo "4 - SAUVEGARDE SERVEUR MAIL : Création du dossier"
var_save_mail_path=$var_save_path/mail-server # Création dossier de sauvegarde
mkdir -p $var_save_mail_path

echo "4 - SAUVEGARDE SERVEUR MAIL : Desactivation serveur mail"
docker service scale mail_mailserver=0 mail_webmail-rainloop=0 > /dev/null # Desactivation serveur mail

# Copie volumes
echo "4 - SAUVEGARDE SERVEUR MAIL : Copie volume maildata"
docker run --rm -v mail_mailserver-maildata:/volume -v $var_save_mail_path:/backup alpine cp -R /volume/ /backup/volume-maildata
echo "4 - SAUVEGARDE SERVEUR MAIL : Copie volume mailstate"
docker run --rm -v mail_mailserver-mailstate:/volume -v $var_save_mail_path:/backup alpine cp -R /volume/ /backup/volume-mailstate
echo "4 - SAUVEGARDE SERVEUR MAIL : Copie bind config"
cp -R /docker_data/mail/docker-mailserver/config $var_save_mail_path/bind-config
echo "4 - SAUVEGARDE SERVEUR MAIL : Copie volume rainloop data"
docker run --rm -v mail_webmail-rainloop-data:/volume -v $var_save_mail_path:/backup alpine cp -R /volume/ /backup/volume-mailstate

echo "4 - SAUVEGARDE SERVEUR MAIL : Réactivation serveur mail"
docker service scale mail_mailserver=1 mail_webmail-rainloop=1 > /dev/null # Réactivation serveur mail

# ----------- 5. Sauvegarde conteneur gitlab

# ----------- 6. Sauvegarde conteneur owncloud

echo "-------------
6/$var_nb_step : SAUVEGARDE SERVEUR OWNCLOUD
-------------"

# Création du dossier si inexistant.
echo "6 - SAUVEGARDE SERVEUR MAIL : Création du dossier si besoin"
var_save_owncloud_path=$var_save_path/owncloud-server # Création dossier de sauvegarde
mkdir -p $var_save_owncloud_path

echo "6 - SAUVEGARDE SERVEUR MAIL : Desactivation serveur owncloud"
docker service scale owncloud_owncloud=0 owncloud_redis=0 owncloud_db=0 > /dev/null

docker run --rm -v owncloud_backup:/volume -v $var_save_owncloud_path:/backup alpine cp -R /volume/ /backup/volume-mysqlbackup
docker run --rm -v owncloud_mysql:/volume -v $var_save_owncloud_path:/backup alpine cp -R /volume/ /backup/volume-mysql
docker run --rm -v owncloud_redis:/volume -v $var_save_owncloud_path:/backup alpine cp -R /volume/ /backup/volume-redis
rsync -av --delete-after /docker_data/owncloud_data $var_save_owncloud_path/bind-ownclouddata

echo "6 - SAUVEGARDE SERVEUR MAIL : Réactivation serveur owncloud"
docker service scale owncloud_db=1 owncloud_redis=1 owncloud_owncloud=1 > /dev/null

# ----------- 7. Sauvegarde conteneur clandesloups_wp

# Suppression données de sauvegarde locale (SAUF owncloud data pour rsync)

rm -R $var_save_mail_path

