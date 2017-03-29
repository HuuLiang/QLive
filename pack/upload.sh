#!/bin/sh

UPLOAD_FILE=$1

if [ ! -f "$UPLOAD_FILE" ]; then
    echo "You shoud specify the file to be uploaded!"
    exit 0
fi

scp -P 3712 $UPLOAD_FILE root@222.186.130.242:/home
