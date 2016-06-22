#!/bin/bash

# Some useful standard functions to have around :)

# check if an array contains a given value
# contains "asdf" "asdf an array of values" => has exit code 0
function contains {
    local e;
    for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done;
    return 1;
}

function file_exists {
    local file=$1;
    stat ${file} > /dev/null;
}

function nth_line {
    local n=$1;
    local filename;
    if [[ $# != 1 ]]
    then
        filename=$2;
        (head -n $n | tail -n 1) < $filename;
    else
        head -n $n | tail -n 1;
    fi
}

function redirect {
    local target="$1";
    echo "<script>window.location.href='${target}';</script>";
}

function set_cookie {
    local key="$1";
    local value="$2";
    local expiry=$(date -v "+1d"); # expire 1 day from now
    echo "<script>document.cookie = '${key}=${value}; expires=${expiry}; path=/';</script>";
    COOKIES[$key]="${value}";
}

function get_cookie {
    echo "${COOKIES[$1]}";
}

function remove_cookie {
    local key="$1";
    local expiry=$(date -v "-1d"); # expiration dates in the past delete cookies
    echo "<script>document.cookie = '${key}=riperino; expires=${expiry}; path=/';</script>";
    unset COOKIES[$key];
}

# take text on input, transform any html special chars to the corresponding entities
function htmlentities {
    sed "s/\&/\&amp;/g" | sed "s/</\&lt;/g" | sed "s/>/\&gt;/g";
}
