#!/bin/bash

SQITCH_IMAGE=${SQITCH_IMAGE:=sqitch:latest}

user=${USER-$(whoami)}
if [ "Darwin" = $(uname) ]; then
    fullname=$(id -P $user | awk -F '[:]' '{print $8}')
else
    fullname=$(getent passwd $user | cut -d: -f5 | cut -d, -f1)
fi

docker run -it --rm --network host \
    --mount "type=bind,src=$(pwd),dst=/repo" \
    --mount "type=bind,src=$HOME,dst=/home" \
    -e "SQITCH_ORIG_SYSUSER=$user" \
    -e "SQITCH_ORIG_FULLNAME=$fullname" \
    -e "SQITCH_ORIG_EMAIL=$user@$(hostname)" \
    -e "TZ=$(date +%Z)" \
    -e "LESS=${LESS:--R}" \
    "$SQITCH_IMAGE" $@
