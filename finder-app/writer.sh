#!/bin/sh

writefile=$1
writestr=$2

if [ $# -ne 2 ] ; then
    echo "Wrong args specified, expected 2, got $#"
    echo "Exiting with 1 ..."
    exit 1
fi

mkdir -p "$(dirname $writefile)"

touch $writefile

printf "%s" "$writestr" > $writefile || exit 1

