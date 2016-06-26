#!/usr/bin/env bash

source lib.sh # import stdlib

VERSION="0.0.0.0.1 \"alphaest of bets\""
declare -A URL_PARAMS # hashtable of url parameters
declare -A POST_PARAMS # hashtable of post parameters
declare -A HTTP_HEADERS # hashtable of http headers
declare -A COOKIES # hashtable of cookies

function log {
    echo "[`date`] $@" 1>&2
}

urldecode() {
    # urldecode <string>

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}

max_page_include_depth=64
page_include_depth=0
function include_page {
    # include_page <pathname>
    local pathname=$1
    local cmd=""
    page_include_depth=$(($page_include_depth+1))
    if [[ $page_include_depth -lt $max_page_include_depth ]]
    then
        local line;
        while read -r line; do
            # check if we're in a script line or not ($ at the beginning implies script line)
            # also, our extension needs to be .wtf
            [[ "$" = ${line:0:1} && ${pathname:(-4)} = '.wtf' ]]
            is_script=$?;

            # execute the line.
            if [[ $is_script = 0 ]]
            then
                cmd=$(printf "${cmd}\n${line#"$"}")
            else
                if [[ -n $cmd ]]
                then
                    eval "$cmd"
                    cmd=""
                fi
                echo $line
            fi
        done < ${pathname}
    else
        echo "<p>Max include depth exceeded!<p>"
    fi
}

function handle_connection {
    # Parse query and any url parameters that may be in the path
    IFS=' ' read method path version
    query=$(echo $path | cut -d\? -f2)
    if [[ $query != $path ]]
    then
        params=($(echo $query | sed "s/\&/ /g"))
        for param in ${params[@]}; do
            key=$(echo $param | cut -d\= -f1)
            value=$(echo $param | cut -d\= -f2)
            URL_PARAMS[$key]=$(urldecode $value)
        done
    fi

    request=($method $path $version)
    path=$(echo $path | cut -d\? -f1) # strip url parameters
    requested_path=$(pwd)/${path}

    # parse headers
    while read -r line; do
        if [[ $line == `echo -n $'\x0d\x0a'` || $line == `echo -n $'\x0a'` ]]
        then
            break
        else
            a=($line)
            key=${a[0]%?}
            value=${a[@]:1}
            HTTP_HEADERS[$key]=${value:0:-1}; # remove \r from end
        fi
    done

    # parse out cookie values, if they exist
    if contains "Cookie" "${!HTTP_HEADERS[@]}"
    then
        while read -d ';' -r cookie; do
            local key=$(echo $cookie | cut -d\= -f1);
            local value=${cookie#*=};
            COOKIES[${key}]=${value};
        done <<< "${HTTP_HEADERS['Cookie']};" # append a ; so we still get the last field -- read drops the last thing >_<
    fi
    
    if [[ $method == "POST" ]]
    then
        # TODO: handle multipart bodies
        local line;
        local n;
        n=${HTTP_HEADERS['Content-Length']};
        read -n$n -r line;
        params=($(echo $line | sed "s/\&/ /g"))
        for param in ${params[@]}; do
            key=$(echo $param | cut -d\= -f1)
            value=$(echo $param | cut -d\= -f2)
            POST_PARAMS[$key]=$(urldecode $value)
        done
    fi

    # if a directory is requested, try each of the following, in order
    # index.wtf, index.html
    local index_fills=("index.wtf" "index.html");
    if [[ -d ${requested_path} ]]
    then
        for i in ${index_fills}; do
            if [[ -e "${requested_path}/${i}" ]]
            then
                requested_path="${requested_path}/${i}";
                break;
            fi
        done
    fi

    # check for possible directory traversals / other undesirable path elements by
    # removing them and 503-ing if the string was changed
    test_path=$(echo ${requested_path} | sed "s/\.\.//g")
    if [[ ${test_path} != ${requested_path} ]]
    then
        echo "HTTP/1.1 503 Forbidden"
        echo "Content-Type: text/html"
        printf "\r\n\r\n"
        echo "<html><title>503</title><body>503 Forbidden</body></html>"
        log "503: ${request[@]}"
        exit 0; # terminate early for 503
    fi

    if [[ -e ${requested_path} ]]
    then
        if [[ -f ${requested_path} ]]
        then
            echo "HTTP/1.1 200 OK"
            echo "Content-Type: text/html"
            printf "\r\n\r\n"
            include_page ${requested_path};
        elif [[ ! -e "${requested_path}/.nolist" ]] # handle directory listing if it isn't a file and no `.nolist` file in the directory
        then
            echo "HTTP/1.1 200 OK"
            echo "Content-Type: text/html"
            printf "\r\n\r\n"
            echo "<h3>Index of ${request[1]}</h3>"
            echo "<ul>"
            for d in `ls ${requested_path}`; do
                size_info=($(du -h ${requested_path} | tail -n 1))
                log ${d}
                echo "<li><a href="/${request[1]#"/"}${d}">${d}</a>: ${size_info[0]}</li>"
            done
            echo "</ul>"
            echo "<font size=2>generated by wtf.sh ${VERSION} on $(date)</font>"
        else
            echo "HTTP/1.1 503 Forbidden"
            echo "Content-Type: text/html"
            printf "\r\n\r\n"
            echo "<h3>I'm sorry, I'm afraid I can't list that directory</h3>"
            echo "<p>It seems that you tried to list a directory with a <code>.nolist</code> file in it.</p>"
            echo "<p>If you think this was a mistake, too bad.</p>"
        fi
        log "200: ${request[@]}"
        exit 0
    else
        echo "HTTP/1.1 404 Not Found"
        echo "Content-Type: text/html"
        printf "\r\n\r\n"
        echo "<html><title>404</title><body>404, not found:<code>${request[1]}</code></body></html>"
        log "404: ${request[@]}"
        exit 0
    fi
}

# start socat on specified port
function start_server {
    socat TCP-LISTEN:$2,fork,readbytes=4096 EXEC:"$1 -r" 2>&1 | tee webserver.log
}

if [[ $# != 1 ]]
then
    echo "Usage: $0 port"
    exit
fi

if [[ $1 == '-r' ]]
then
    handle_connection
else
    start_server $0 $1 # start server on specified port
fi
