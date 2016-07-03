#!/usr/bin/env bash

source user_functions.sh
source post_functions.sh

rm .index_cache.html;
touch .index_cache.html;
chmod 777 .index_cache.html;

# gotta get dem sick references in there somewhere :)
USERS=("admin" \
       # Hackers
       "Acid Burn" "Phantom Phreak" "The Plague" \
       "Cereal Killer" "Zero Cool" \
       # Ghost in the Shell
       "The Laughing Man" "The Puppet Master" \
       # The matrix
       "Trinity" "Neo" "Morpheus" \
       );

function random_password {
    cat /dev/urandom | tr -cd "[[:alnum:]]" | head -c 32;
}


echo "------------------------------------"
echo "---------- CREATING USERS ----------"
echo "------------------------------------"
for i in ${!USERS[@]}; do
    user=${USERS[$i]};
    pass=$(random_password);
    if [[ $(find_user_file ${user}) = 'NONE' ]]
    then
        echo ${user}:${pass}:$(create_user "${user}" "${pass}");
    else
        echo "${user} already exists D:";
    fi
done


# create a bunch of posts in a randomish order
echo "------------------------------------"
echo "---------- CREATING POSTS ----------"
echo "------------------------------------"
for k in {0..20}; do
    for i in ${!USERS[@]}; do
        user=${USERS[$i]};
        echo "${k}" "${user}";
    done
done \
    | shuf \
    | while read -r n user; do
        create_post "${user}" "My ${n}th post" "This is a post about some stuff yo";
    done
