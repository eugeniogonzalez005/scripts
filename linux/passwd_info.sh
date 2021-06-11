#!/bin/bash
# Obtain information from a system user
# Author: Eugenio Gonzalez
: '
    ______                       _          ______                        __
   / ____/_  ______ ____  ____  (_)___     / ____/___  ____  ____  ____ _/ /__  ____
  / __/ / / / / __ `/ _ \/ __ \/ / __ \   / / __/ __ \/ __ \/_  / / __ `/ / _ \/_  /
 / /___/ /_/ / /_/ /  __/ / / / / /_/ /  / /_/ / /_/ / / / / / /_/ /_/ / /  __/ / /_
/_____/\__,_/\__, /\___/_/ /_/_/\____/   \____/\____/_/ /_/ /___/\__,_/_/\___/ /___/
            /____/

'
user_passwd_info () {
    local PASSFILE=/etc/passwd
    local pass_info="$(grep "^$1:" $PASSFILE)"
    if [ -n "$pass_info" ]; then # if the user is found then...
        IFS=":" read -r user pass uid gid name home shell <<< "$pass_info"
        echo "User =      '$user'"
        echo "UID =       '$uid'"
        echo "GID =       '$gid'"
        echo "Full Name = '$name'"
        echo "Home Directory = '$home'"
        echo "User Shell =     '$shell'"
    else
        echo "'$user_name' not found" >&2
        exit 3
    fi
}

read -rp 'Enter a username > ' user_name
# check that the given username is a valid username
if [[ -z "$user_name" ]]; then
    echo 'username cannot be empty'
    exit 1
else
    if [[ "$user_name" =~ ^[-\.[:alnum:]_]+$ ]]; then
        user_passwd_info "$user_name"
    else
        echo "Error: invalid username '$user_name'"
        exit 2
    fi
fi
