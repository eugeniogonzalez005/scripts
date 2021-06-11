#!/bin/bash
# work in progress
# Eugenio Gonzalez
:'
    ______                       _          ______                        __
   / ____/_  ______ ____  ____  (_)___     / ____/___  ____  ____  ____ _/ /__  ____
  / __/ / / / / __ `/ _ \/ __ \/ / __ \   / / __/ __ \/ __ \/_  / / __ `/ / _ \/_  /
 / /___/ /_/ / /_/ /  __/ / / / / /_/ /  / /_/ / /_/ / / / / / /_/ /_/ / /  __/ / /_
/_____/\__,_/\__, /\___/_/ /_/_/\____/   \____/\____/_/ /_/ /___/\__,_/_/\___/ /___/
            /____/

'
SITE=''
apt update &&\
apt install --assume-yes php \
   php-curl php-xml php-gd php-mbstring php-zip php-mysql php-bz2 php-intl php-imap php-memcached php-imagick php-bcmath php-gmp \
   apache2 libapache2-mod-php \
   mariadb-server && \
mysql_secure_installation && \
systemctl restart mariadb &&  systemctl status mariadb && \
systemctl restart apache2 &&  systemctl status apache2 && \
a2dissite 000-default.conf  && \
mkdir -p '/var/www/html/nextcloud' && \
mv '/etc/apache2/sites-available/000-default.conf' '/etc/apache2/sites-available/${SITE}.conf' && \
a2ensite "${SITE}.conf" && \
systemctl restart apache2 && \
a2enmod rewrite && \
a2enmod headers && \
a2enmod env && \
a2enmod dir && \
a2enmod mime && \
chown -R www-data:www-data '/var/www/html/nextcloud' &&  chmod -R 770 '/var/www/html/nextcloud' && \
cd /var/www/html/nextcloud/ && wget https://download.nextcloud.com/server/installer/setup-nextcloud.php && \
