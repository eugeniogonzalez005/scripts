#!/bin/bash


# Script que realiza backup de los ficheros/sitios especificados
# Diseñado para Pedro
# Autor: Eugenio Gonzalez

: '
    ______                       _          ______                        __
   / ____/_  ______ ____  ____  (_)___     / ____/___  ____  ____  ____ _/ /__  ____
  / __/ / / / / __ `/ _ \/ __ \/ / __ \   / / __/ __ \/ __ \/_  / / __ `/ / _ \/_  /
 / /___/ /_/ / /_/ /  __/ / / / / /_/ /  / /_/ / /_/ / / / / / /_/ /_/ / /  __/ / /_
/_____/\__,_/\__, /\___/_/ /_/_/\____/   \____/\____/_/ /_/ /___/\__,_/_/\___/ /___/
            /____/
'
# Colores utilizados en el script
RED="\e[31m"
GREEN="\e[32m"
NOCOLOR="\e[0m"


# ============== Backup ==============

function backup_ficheros () {
    read -p "Indica el entorno actual: " entornoActual
    entornoActual="$(echo "$entornoActual" | tr '[:upper:]' '[:lower:]')"
    echo 'Indica el número de ticket: '
    read numTicket
    if [[ ! -z "$numTicket" && "$numTicket" =~ ^[0-9]{5}$ && ! -z "$entornoActual" ]]; then # para continuar se deben indicar el ticket y el entorno, y el ticket debe ser estar formado por 5 valores enteros
        ruta_ticket="/var/tmp/T${numTicket}/${entornoActual}/"
        echo -e "${GREEN}[*]${NOCOLOR} El número de ticket es: T${numTicket} (/var/tmp/T${numTicket})"
        mkdir -p "$ruta_ticket"
        while :
        do
            echo 'Indica la ruta completa del fichero: (q para salir)'
            read -e ruta_fichero
            if [[ -d "$ruta_fichero" ]];then # detectar si el fichero es un directorio
                read -p "Indica el nombre del directorio: " directorio_ruta
                cd "$ruta_fichero" ; cd ..
                zip -r "${ruta_ticket}${directorio_ruta}.zip" "$directorio_ruta"
                echo -e "${GREEN}[*]${NOCOLOR} Se ha realizado un zip de $ruta_fichero a $ruta_ticket"
                cd
            elif [[ -f "$ruta_fichero" ]]; then # si es un fichero
                cp "$ruta_fichero" "$ruta_ticket"
                echo -e "${GREEN}[*]${NOCOLOR} Se ha copiado $ruta_fichero a $ruta_ticket"
            elif [[ "$ruta_fichero" == 'q' || "$ruta_fichero" == 'Q' ]]; then # salida
                break
            else
                echo 'Se debe indicar un fichero o un directorio'
                continue
            fi
        done
    else
        echo -e "${RED}[!]${NOCOLOR} Error, valor incorrecto"
        backup_ficheros
    fi
    return 0
}
# ============== Permisos ==============

function permisos_entorno () {
    read -p "Indica el usuario propietario: " userPerm
    read -p "Indica la ruta destino: " rutaDestino
    read -p "Indica el entorno actual: " entornoActual
    entornoActual="$(echo "$entornoActual" | tr '[:upper:]' '[:lower:]')"
    case $entornoActual in
        "des")
            sudo chown -R "${userPerm}:${userPerm}" "$rutaDestino" ;\
            sudo find "$rutaDestino" -type d -exec setfacl -m group:manager:rwX {} \; 
            sudo find "$rutaDestino" -type f -exec setfacl -m group:manager:rwX {} \; 
            sudo find "$rutaDestino" -type f -exec chmod 770 {} \; 
            sudo find "$rutaDestino" -type d -exec chmod 770 {} \;
            ;;
        "pre")
            sudo chown -R "${userPerm}:${userPerm}" "$rutaDestino" ;\
            sudo find "$rutaDestino" -type d -exec setfacl -m user:manager:rX {} \; 
            sudo find "$rutaDestino" -type f -exec setfacl -m user:manager:r {} \; 
            sudo find "$rutaDestino" -type f -exec chmod 640 {} \; 
            sudo find "$rutaDestino" -type d -exec chmod 750 {} \;
            ;;
        "pro")
            sudo chown -R "${userPerm}:${userPerm}" "$rutaDestino" ;\
            sudo find "$rutaDestino" -type d -exec setfacl -m user:manager:rX {} \; 
            sudo find "$rutaDestino" -type f -exec setfacl -m user:manager:r {} \; 
            sudo find "$rutaDestino" -type f -exec chmod 440 {} \; 
            sudo find "$rutaDestino" -type d -exec chmod 550 {} \;
            ;;
        "q")
            return 0 # para salir de funciones utilizar return
            ;;
        *)
            echo 'valor incorrecto'
            permisos_entorno
            ;;
    esac
    return
}

# ============== BBDD ==============

function identificacion_bd () {
    echo "Indica la ruta completa del site"
    read -e rutaSite
    cd "$rutaSite"
    settingsSite=$(find -type f -name settings.php) # buscar el settings.php dentro del site
    echo "El ficheros settings.php está en: $rutaSite$(echo $settingsSite | cut -d '/' -f 2-)"
    read -p "Continuar (y|n)" contBBDD
    if [[ "$contBBDD" == 'y' || "$contBBDD" == 'Y' ]]; then
        nombreDB=$(grep -Ev '^/\*|^\ \*|^\*/|^.*/\*|^#|^$|^\$[cs].*' "$settingsSite" |  grep -E ".*'database'.*" | cut -d "'" -f 4) # obtener nombre base de datos
        nombreHost=grep -Ev '^/\*|^\ \*|^\*/|^.*/\*|^#|^$|^\$[cs].*' "$settingsSite" |  grep -E ".*'host'.*" | cut -d "'" -f 4 # identificar la direccion del host
        echo -e "DATOS DEL SETTINGS:\n\tDB:$nombreDB\n\tHost:$nombreHost"
    elif [[ "$contBBDD" == 'n' || "$contBBDD" == 'N' ]]; then
        return
    else
        echo 'valor incorrecto'
        identificacion_bd
    fi
    return
}

function back_bd () {
    if [ $nombreHost = 'localhost' ]; then
        mkdir -p /var/tmp/T$varTicket
        cd /var/tmp/T$varTicket
        mysqldump -u root -p $nombreDB > /var/tmp/T$varTicket/$nombreDB.sql
    else
        read -p "Indica el usuario del host destino" usrDest
        ############################## conexion al host remoto para realizar backup
        ssh $usrDest@$nombreHost <<- EOF
        mkdir /var/tmp/T$(echo $varTicket)
        cd /var/tmp/T$(echo $varTicket)
        read -p "Constraseña de la base de datos: " passHost
        mysqldump -u root -p'$passHost' $nombreDB > /var/tmp/T$varTicket/$nombreDB.sql
        EOF
        ############################# conexion al host remoto para traer el backup al host local
        cd /var/tmp/
        sftp $usrDest@$nombreHost <<- EOF
        cd /var/tmp/T$(echo $varTicket)
        get $nombreDB.sql
        EOF
    fi
    return
}

# ============== Init ==============

while :
do
#    if [[ -z "$entornoActual" ]]; then
#        read -p "Indica el entorno actual: " entornoActual
#        entornoActual="$(echo "$entornoActual" | tr '[:upper:]' '[:lower:]')"
#    fi
    echo 'Deseas...
1) Backup de ficheros/sitio
2) aplicar permisos
3) Salir
'
    read opt
    case $opt in
    1)
        backup_ficheros
        ;;
    2)
        permisos_entorno
        ;;
    3)
        break
        ;;
    *)
        echo "opción incorrecta"
        continue
        ;;
     esac
done

