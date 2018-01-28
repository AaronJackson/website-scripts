#!/bin/bash

SOURCE=$1
DEST=${2:-$SOURCE}
MAX_WIDTH=${MAX_WIDTH:-700}
EXT=${EXT:-jpg}

if [[ -z $SOURCE ]]; then
    echo USAGE: $0 source [dest]
    echo
    echo ENVIRONMENT VARIABLES:
    echo "  MAX_WIDTH  = $MAX_WIDTH"
    echo "  EXT        = $EXT"
    echo
    exit
fi


echo "org-mode source:"
echo
for f in $(find $SOURCE -name "*.$EXT" | grep -v ".web."); do
    bname=$(basename $f .$EXT )
    bname=${bname,,}
    newpath=$DEST${bname}.web.${EXT,,}
    oldpath=${f,,}
    if [[ "$f" != "$oldpath" ]]; then
	mv $f $oldpath
    fi
    convert $oldpath -resize $MAX_WIDTH $newpath
    echo [[file:$oldpath][file:$newpath]]
done
