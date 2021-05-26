#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: ./test.sh <filename>"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "File:'$1' not found!"
    exit 1
fi
echo "test: $1"
./main $1
