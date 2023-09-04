#!/bin/sh

filesdir=$1
searchstr=$2

if [ $# -ne 2 ] ; then
    echo "Wrong args specified, expected 2, got $#"
    echo "Exiting with 1 ..."
    exit 1
elif [ ! -d $filesdir  ] ; then
    echo "The specified filesdir is not a directory"
    echo "Exiting with 1 ..."
    exit 1
fi


X=$(find $filesdir -type f | wc -l)

Y=$(grep -r $filesdir -e $searchstr | wc -l)

echo "The number of files are $X and the number of matching lines are $Y"

