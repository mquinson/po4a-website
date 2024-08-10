#!/bin/sh

set -eu

find t -name '*.t' | \
    while read -r path
    do
        echo "start $path"
        perl "$path"
    done
