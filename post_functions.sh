#!/usr/bin/env bash

source lib.sh

# Create a new post. Returns the post id.
function create_post {
    local username=$1;
    local title=$2;
    local text=$3;

    # ensure posts dir exists and isn't listable.
    mkdir posts 2> /dev/null;
    touch posts/.nolist;

    local post_id=$(basename $(mktemp posts/XXXXX));


    echo ${username} > posts/${post_id};
    echo ${title} >> posts/${post_id};
    echo ${text} >> posts/${post_id};


    # add to our cache for the homepage
    echo "<li><a href=\"/post.wtf?post=${post_id}\">${title}</a> by ${username}</li>" >> .index_cache.html
    echo ${post_id};

}
