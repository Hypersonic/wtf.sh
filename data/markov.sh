#!/usr/bin/env bash

declare -A chain;



# generate a random number in [$1, $2]
function random {
    shuf --input-range=$1-$2 --head-count=1;
}

function add_data_to_chain {
    local text=($1);

    # generate chain
    chain['STARTTOKEN']+="${text[0]} "
    for (( i=0; i < ${#text[@]}; i++ )); do
        word=${text[$i]};
        next=${text[$i+1]};
        if [[ $next = '' ]]
        then
            next="ENDTOKEN";
        fi
        chain[$word]+="$next ";
    done;
}

function print_chain {
    for key in ${!chain[@]}; do
        echo "${key} : ${chain[$key]}";
    done
}

function generate_text_from_chain {
    # generate text
    output="";
    curr_token='STARTTOKEN';
    until [[ ${curr_token} = 'ENDTOKEN' ]]; do
		curr_token="${curr_token#"${curr_token%%[![:space:]]*}"}"   # remove leading whitespace characters
		curr_token="${curr_token%"${curr_token##*[![:space:]]}"}"   # remove trailing whitespace characters
        choices=(${chain[$curr_token]});
        idx=$(random 0 $(( ${#choices[@]}-1 )) );
        curr_token=${choices[$idx]};
        if [[ $curr_token != 'ENDTOKEN' ]];
        then
            output+="${curr_token} ";
        fi
    done
    echo $output
}




while read -r line; do
    add_data_to_chain "$line";
done < "$1"

generate_text_from_chain;

