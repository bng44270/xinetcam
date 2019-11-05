#!/bin/bash

availres=($(ls /dev/video* | sed 's/^\/dev//g') /list)
availact=(GET)
read request
action=$(printf "$request" | awk '{ print $1 }')
resource=$(printf "$request" | awk '{ print $2 }')

if [ -z "$(which fswebcam)" ]; then
        read -r -d '' RESPBODY <<HERE
{ "error":"command fswebcam unavailable" }
HERE
        echo "HTTP/1.1 500 Internal Server Error"
        echo "Content-Length: ${#RESPBODY}"
        echo "Date: $(date -Ru)"
        echo ""
        echo "$RESPBODY"
elif [ -z "$(awk -v thisact="$action" 'BEGIN { RS=" " } { if (thisact == $1) { print thisact } }' <<< "${availact[@]}")" ]; then
        read -r -d '' RESPBODY <<HERE
{ "error":"invalid HTTP method ($action)" }
HERE
        echo "HTTP/1.1 500 Internal Server Error"
        echo "Content-Length: ${#RESPBODY}"
        echo "Date: $(date -Ru)"
        echo ""
        echo "$RESPBODY"
elif [ -z "$(awk -v thisres="$resource" 'BEGIN { RS=" " } { if (thisres == $1) { print thisres } }' <<< "${availres[@]}")" ]; then
        read -r -d '' RESPBODY <<HERE
{ "error":"invalid path ($resource)" }
HERE
        echo "HTTP/1.1 404 Not Found"
        echo "Content-Length: ${#RESPBODY}"
        echo "Date: $(date -Ru)"
        echo ""
        echo "$RESPBODY"
elif [ "$resource" == "/list" ]; then
	devicelist="$(ls /dev/video* | sed 's/^\/dev//g' | tr '\n' ' ' | sed 's/[ \t]*$//g' | sed 's/ /","/g;s/^/"/g;s/$/"/g')"
	read -r -d '' RESPBODY <<HERE
{ "cameras":[$devicelist] }
HERE
        echo "HTTP/1.1 200 OK"
        echo "Content-Length: ${#RESPBODY}"
        echo "Date: $(date -Ru)"
        echo ""
        echo "$RESPBODY"
else
        IMG="/tmp/xinetcam-img-$RANDOM.jpg"
        fswebcam -d /dev$resource -q $IMG
        IMGSIZE="$(ls -l $IMG | awk '{ print $5 }')"
        echo "HTTP/1.1 200 OK"
        echo "Date: $(date -Ru)"
        echo "Content-Length: $IMGSIZE"
        echo "Content-Type: image/jpeg"
        echo ""
        cat $IMG
        rm $IMG
fi
