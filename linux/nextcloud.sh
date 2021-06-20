#!/bin/bash
# work in progress
# Author: Eugenio Gonzalez
: '
    ______                       _          ______                        __
   / ____/_  ______ ____  ____  (_)___     / ____/___  ____  ____  ____ _/ /__  ____
  / __/ / / / / __ `/ _ \/ __ \/ / __ \   / / __/ __ \/ __ \/_  / / __ `/ / _ \/_  /
 / /___/ /_/ / /_/ /  __/ / / / / /_/ /  / /_/ / /_/ / / / / / /_/ /_/ / /  __/ / /_
/_____/\__,_/\__, /\___/_/ /_/_/\____/   \____/\____/_/ /_/ /___/\__,_/_/\___/ /___/
            /____/

'
# ==== COLORS ====
RED="\e[31m"
GREEN="\e[32m"
NOCOLOR="\e[0m"

# ==== MAIN FUNCTIONS ====

prerequisites () {
    local php apache mariadb
    php=(php php-curl php-xml php-gd php-mbstring php-zip php-mysql php-bz2 php-intl php-imap php-memcached php-imagick php-bcmath php-gmp)
    apache=(apache2 libapache2-mod-php)
    mariadb=(mariadb-server)
    apt update
    apt install --assume-yes php "${php[@]}" "${apache[@]}" "${mariadb[@]}"
    mysql_secure_installation
    systemctl restart mariadb && systemctl status mariadb || printf 'error: cant reload mariadb'
    systemctl restart apache2 && systemctl status apache2 || printf 'error: cant reload apache2'
    return
}

site_configuration () {
    a2dissite 000-default.conf
    mv '/etc/apache2/sites-available/000-default.conf' "/etc/apache2/sites-available/${SITE}.conf" # debian version
    a2ensite "${SITE}.conf"
    systemctl restart apache2
    a2enmod rewrite
    a2enmod headers
    a2enmod env
    a2enmod dir
    a2enmod mime
    return
}

nextcloud_install () {
    cd "${NEXTCLOUD_DIR}" && wget https://download.nextcloud.com/server/installer/setup-nextcloud.php
    return
}

usage () {
    local SCRIPTNAME
    SCRIPTNAME="$(basename "$0")"
    printf "%s- usage: %s [-s site_name | -n nextcloud_directory | -i]\nexample: %s -s nextcloud.test -n nextcloud" "$SCRIPTNAME" "$SCRIPTNAME" "$SCRIPTNAME"
    return
}

checker () {
    return
}

interactive () {
    printf 'Site name > '
    read -re SITE
    printf "Nextcloud directory > "
    read -re NEXTCLOUD_DIR
    return
}

# ==== OPTIONS ====

SITE=''
NEXTCLOUD_DIR=''
if [[ -n "$1" ]]; then
    while [[ -n "$1" ]]; do
        case "$1" in
            -s | --site)
                shift
                SITE="$1"
                ;;
            -n | --nextclou_dir)
                shift
                NEXTCLOUD_DIR="$1"
                ;;
            -i | --interactive)
                interactive
                ;;
            -h | --help)
                usage
                ;;
            *)
                usage >&2
                exit 1
                ;;
        esac
        shift
    done
else
    interactive
fi

if [[ -n "$SITE" && -n "$NEXTCLOUD_DIR" ]]; then
    while true; do
        if [[ "$NEXTCLOUD_DIR" =~ ^[-[:alnum:]_]+$ ]] && [[ "$SITE" =~ ^[-\.[:alnum:]_]+$ ]]; then
                clear
                printf "=> Site: %s\n=> Nextcloud directory: %s\n" "$SITE" "$NEXTCLOUD_DIR"
                printf 'Proceed? [Y/n/q] > '
                read -r
                case $REPLY in
                    Y|y)
                        break
                        ;;
                    q|Q)
                        printf "\nProgram terminated\n"
                        exit
                        ;;
                    n|N)
                        interactive
                        ;;
                    *)
                        printf "\n${RED}[!]${NOCOLOR} Invalid option\n"
                        read -p "PRESS ENTER TO CONTINUE"
                        continue
                        ;;
                esac
        else
            printf "${RED}[!]${NOCOLOR} Wrong formats:\n\tsite: '%s'\n\tnextcloud_directory: '%s'\n" "$SITE" "$NEXTCLOUD_DIR"
            interactive
            continue
        fi
    done

    if mkdir "/var/www/html/${NEXTCLOUD_DIR}" && chown -R www-data:www-data "${NEXTCLOUD_DIR}" &&  chmod -R 770 "${NEXTCLOUD_DIR}"; then
        printf "working"
    else
        printf "\nnot working\n" >&2
    fi
else
    printf "\n${RED}[!]${NOCOLOR} Error: site or nextcloud directory undefined\n" >&2
    exit 1
fi
