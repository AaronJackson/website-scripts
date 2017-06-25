#!/bin/bash

cd ~/public_html/$1

author="Aaron S. Jackson"

while read -r file; do
    if [ -a .$file.md5 ]; then
	if [ "`cat .$file.md5`" == "`md5sum $file`" ]; then
	    continue
	else
	    md5sum $file > .$file.md5
	fi
    else
	md5sum $file > .$file.md5
    fi

    hname=`basename "$file" .org `.html # html file name
    page=`cat $file` # get the post title

    title=`echo "$page" | head | grep "#+TITLE:" | cut -b10-`
    options=`echo "$page" | head | grep "#+OPTIONS:" | cut -b12-`

    echo "Generating $title"

    cat > $hname <<EOF
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>$title - Aaron S. Jackson</title>
    <meta name="author" content="$author" />
    <link rel="stylesheet" type="text/css" href="$2style.css" />
    <meta name="viewport" content="width=device-width">
  </head>
  <body>
    <div id="content" class="post">
      <h1 class="title">$title</h1>
EOF

    html=`pandoc $file`
    html="${html//file\:/}" # fix url compatibility with emacs

    echo "$html" >> $hname

    cat >> $hname <<EOF
    </div>
    <div id="postamble">
      <p><a href="index.html">&larr; Return Home</a></p>
      <p class="small">Copyright 2007-$(date +%Y) $author (modified: $(date))</p>
    </div>
  </body>
</html>
EOF

done <<< "`ls -1 *.org`"
