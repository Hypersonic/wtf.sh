#!/bin/bash

# Some useful standard functions to have around :)

# check if an array contains a given value
# contains "asdf" "asdf an array of values" => has exit code 0
function contains {
    local e;
    for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done;
    return 1;
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
}

function get_cookie {
    echo "${COOKIES[$1]}";
}
