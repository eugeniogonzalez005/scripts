#!/bin/bash

# file-info

# Colors
RED="\e[31m"
GREEN="\e[32m"
NOCOLOR="\e[0m"


SCRIPTNAME="$(basename "$0")"

if [[ -e "$1" ]]; then
    if [[ "$1" =~ ^[-\.[:alnum:]_]+$ ]]; then
        echo -e "\n${GREEN}File type:${NOCOLOR}"
        file "$1"
        echo -e "\n${GREEN}File status:${NOCOLOR}"
        stat "$1"
    else
        echo "[${RED}!${NOCOLOR}] Error: '$1' is not a valid filename"
    fi
else
	echo "$SCRIPTNAME: usage: $SCRIPTNAME path_to_file" >&2
	exit 1
fi
