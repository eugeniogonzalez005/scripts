#!/bin/bash

# work in progress
# Program to output a system information webpage
: '
    ______                       _          ______                        __
   / ____/_  ______ ____  ____  (_)___     / ____/___  ____  ____  ____ _/ /__  ____
  / __/ / / / / __ `/ _ \/ __ \/ / __ \   / / __/ __ \/ __ \/_  / / __ `/ / _ \/_  /
 / /___/ /_/ / /_/ /  __/ / / / / /_/ /  / /_/ / /_/ / / / / / /_/ /_/ / /  __/ / /_
/_____/\__,_/\__, /\___/_/ /_/_/\____/   \____/\____/_/ /_/ /___/\__,_/_/\___/ /___/
            /____/

'


TITLE="System information report for $HOSTNAME"
DATE="$(date +"%x %r %Z")"
TIMESTAMP="Generado $DATE por el usuario $USER"

report_uptime () {
    cat <<- _EOF_
        <h2>System Uptime</h2>
        <pre>$(uptime)</pre>
_EOF_
    return
}


report_disk_space () {
    cat <<- _EOF_
        <h2>System Uptime</h2>
        <pre>$(df -h)</pre>
_EOF_
    return
}

report_home_space () {
    # I check if the user running the script is root or normal user 
    if [[ "$(id -u)" -eq 0 ]]; then # if the user is root, I show the disk usage of the home folder 
            cat <<- _EOF_ > ./report_user_home_space.html
            <h2>Home Space Utilization (all users)</h2>
            <pre>$(du -sh /home/*)</pre>
_EOF_
    else
        cat <<- _EOF_ > ./report_home_space.html
        <h2>Home Space Utilization ($USER)</h2>
        <pre>$(df -h)</pre>
_EOF_
    fi
}


cat << _EOF_
<html>
    <head>
        <title>$TITLE</title>
    </head>
    <body>
        <h1>$TITLE</h1>
        <p>$TIMESTAMP</p>
    </body>
</html>
_EOF_


# === Menu ===
while true; do
    clear
    cat <<- _EOF_
        Select:
        
        0. Quit
        1. Display system information
        2. Display disk space
        3. Display home space utilization
    
_EOF_
    
    read -p "Choose one > " Opt
    if [[ "$Opt" =~ ^[0-3]$ ]]; then
        if [[ "$Opt" == 0 ]]; then
            echo 'Bye! :D'
            exit
        elif [[ "$Opt" == 1 ]]; then
            report_uptime
            read -rp "[*] Press enter to continue"
        elif [[ "$Opt" == 2 ]]; then
            report_disk_space
            read -rp "[*] Press enter to continue"
        elif [[ "$Opt" == 3 ]]; then
            report_home_space
            read -rp "[*] Press enter to continue"
        fi
    else
        echo '[!] Error: invalid entry'
        read -rp "[*] Press enter to continue"
        continue
    fi 
done
