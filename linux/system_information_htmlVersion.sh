#!/bin/bash

# work in progress
# Program to output a system information html page
: '
    ______                       _          ______                        __
   / ____/_  ______ ____  ____  (_)___     / ____/___  ____  ____  ____ _/ /__  ____
  / __/ / / / / __ `/ _ \/ __ \/ / __ \   / / __/ __ \/ __ \/_  / / __ `/ / _ \/_  /
 / /___/ /_/ / /_/ /  __/ / / / / /_/ /  / /_/ / /_/ / / / / / /_/ /_/ / /  __/ / /_
/_____/\__,_/\__, /\___/_/ /_/_/\____/   \____/\____/_/ /_/ /___/\__,_/_/\___/ /___/
            /____/

'



report_uptime () {
    cat <<- _EOF_
        <h2>System Uptime</h2>
        <pre>$(uptime)</pre>
_EOF_
    return
}


report_disk_space () {
    cat <<- _EOF_
        <h2>Disk Space Utilization</h2>
        <pre>$(df -h)</pre>
_EOF_
    return
}

report_home_space () {
    local format i home_dir total_files total_directories total_size username
    format="%8s%10s%10s\n"
    # I check if the user running the script is root or normal user 
    if [[ "$(id -u)" -eq 0 ]]; then
        home_dir="/home/*"
        username='All users in the system'
    else
        home_dir="$HOME"
        username="$USER"
    fi
    
    echo "<h2>Home Space Utilization: ($username)</h2>"

    for i in $home_dir; do
        total_files="$(find "$i" -type f | wc -l)"
        total_directories="$(find "$i" -type d | wc -l)"
        total_size="$(du -sh "$i" | cut -f 1)"

        echo "<h3>$i</h3>"
        echo "<pre>"
        printf "$format" "Dirs" "Files" "Size"
        printf "$format" "----" "----" "----"
        printf "$format" "$total_directories" "$total_files" "$total_size"
        echo "</pre>"
    done
    return
}
# user processes
report_user_process_list () {
    return
}

# HTML PAGE
html_page () {
    local TITLE DATE TIMESTAMP
    TITLE="System information report for $HOSTNAME"
    DATE="$(date +"%x %r %Z")"
    TIMESTAMP="Gerated $DATE, by $USER"
    cat <<- _EOF_
    <html>
        <head>
            <title>$TITLE</title>
        </head>
        <body>
            <h1>$TITLE</h1>
            <p>$TIMESTAMP</p>
            $(report_uptime)
            $(report_disk_space)
            $(report_home_space)
        </body>
    </html>
_EOF_
    return
}

usage () {
    SCRIPTNAME="$(basename "$0")"
    echo "${SCRIPTNAME} - usage: ${SCRIPTNAME} [-f file | -i]"
}


# === Menu ===
# while true; do
#     clear
#     cat <<- _EOF_
#         Select:
#         
#         0. Quit
#         1. Display system information
#         2. Display disk space
#         3. Display home space utilization
#     
# _EOF_
#     
#     read -p "Choose one > " Opt
#     if [[ "$Opt" =~ ^[0-3]$ ]]; then
#         case "$Opt" in
#             0)
#                 echo 'Bye! :D'
#                 exit
#                 ;;
#             1)
#                 report_uptime
#                 read -rp "[*] Press enter to continue"
#                 ;;
#             2)
#                 report_disk_space
#                 read -rp "[*] Press enter to continue"
#                 ;;
#             3)
#                 report_home_space
#                 read -rp "[*] Press enter to continue"
#                 ;;
#         esac
#     else
#         echo '[!] Error: invalid entry'
#         read -rp "[*] Press enter to continue"
#         continue
#     fi 
# done


# === MAIN ===

interactive=
filename=
while [[ -n "$1" ]]; do
    case "$1" in
        -f | --file)
            shift
            filename="$1"
            ;;
        -i | --interactive)
            interactive=1
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

# interactive mode
if [[ -n "$interactive" ]]; then
    while true; do
        read -p "Enter the name of output file: " filename
        if [[ -f "$filename" ]]; then
            read -p "'$filename' exists. Overwrite? [y|n|q] > "
            case "$REPLY" in
                Y|y)
                    break
                    ;;
                q|Q)
                    echo "Program terminated"
                    exit
                    ;;
                *)
                    continue
                    ;;
            esac
        elif [[ -z "$filename" ]]; then
            continue
        else
            break
        fi
    done
fi


if [[ -n "$filename" ]]; then
    if touch "$filename" && [[ -f "$filename" ]]; then
        html_page > "$filename"
    else
        echo "Cannot write file '$filename'" >&2
        exit 1
    fi
else # output by default
    html_page
fi
