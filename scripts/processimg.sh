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
    name=$(basename $f .$EXT)
    convert $f -resize $MAX_WIDTH $DEST/$name.web.$EXT
    echo [[$f][$DEST/$name.web.$EXT]]
done
