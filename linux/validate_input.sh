#!/bin/bash

# input validation (for my fellow students in England)
# Eugenio Gonzalez
: '
    ______                       _          ______                        __
   / ____/_  ______ ____  ____  (_)___     / ____/___  ____  ____  ____ _/ /__  ____
  / __/ / / / / __ `/ _ \/ __ \/ / __ \   / / __/ __ \/ __ \/_  / / __ `/ / _ \/_  /
 / /___/ /_/ / /_/ /  __/ / / / / /_/ /  / /_/ / /_/ / / / / / /_/ /_/ / /  __/ / /_
/_____/\__,_/\__, /\___/_/ /_/_/\____/   \____/\____/_/ /_/ /___/\__,_/_/\___/ /___/
            /____/

'
invalid_input () {
    echo "Invalid input'" >&2
    exit 1
}

read -rp "Enter a single item > " inputString

# Invalid input (empty input or multiple items)
[ -z "$inputString" ] && invalid_input
(( "$(echo "$inputString" | wc -w)" > 1 )) && invalid_input

# is input a number or a text string (both?)?
if [[ "$inputString" =~ ^-?[[:digit:]]+$ ]];then
    echo "$inputString is an integer"
elif [[ "$inputString" =~ ^-?[[:digit:]]+\.[[:digit:]]+$ ]]; then
    echo "$inputString is a floating number"
elif [[ "$inputString" =~ ^[[:alpha:]]+$  ]]; then
    echo "$inputString is a text string"
fi

# check that $inputString is a valid filename 
filename_validation () {
    if [[ "$inputString" =~ ^[-\.[:alnum:]_]+$ ]]; then
        echo "$inputString is a valid filename"
        if [ -e "$inputString" ]; then
            if [[ -d "$inputString" ]]; then
                echo "$inputString exists and is a directory"
            elif [[ -f "$inputString" ]]; then
                echo "$inputString exists and is a regular file"
            else
                echo "$inputString exists"
            fi
        else
            echo "$inputString does not exists"
        fi
    else
        echo "$inputString is not a valid filename"
        exit 1
    fi
}
filename_validation
