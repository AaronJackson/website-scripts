#!/bin/bash

cd ~/public_html/blog/

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
    post=`cat $file` # get the post title

    title=`echo "$post" | head | grep "#+TITLE:" | cut -b10-`
    date=`echo "$post" | head | grep "#+DATE:" | cut -b9-`
    echo "Generating $title"

    date="${date//\</\&lt\;}"
    date="${date//\>/\&gt\;}"

    cat > $hname <<EOF
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>$title - Aaron S. Jackson</title>
    <meta name="author" content="$author" />
    <link rel="stylesheet" type="text/css" href="../style.css" />
    <meta name="viewport" content="width=device-width">
  </head>
  <body>
    <div id="preamble" class="status">
      <p><a href="./index.html">Blog Index</a>
        &bull; <a href="./tags/index.html">Posts by Tag</a>
        &bull; <a href="../index.html">Home</a>
      </p>
    </div>
    <div id="content" class="post">
      <h1 class="title">$title</h1>
      <div class="post-info">
        Posted $date by $author.
      </div>
EOF

    html=`pandoc $file`
    html="${html//file\:/}" # fix url compatibility with emacs

    echo "$html" >> $hname

    tags=`echo "$post" | head | grep "#+FILETAGS:" | cut -b13-`
    tags=`echo "$tags" | tr ':' '\n'` # separate tags
    tags=`echo "$tags" | grep -ve '^$'` # remove empty lines

    echo "<p class=\"post-tags\">Tags: " >> $hname
    while read -r tag; do
        echo "<a href=\"tags/$tag.html\">$tag</a>" >> $hname
    done <<< "$tags"
    echo "</p>" >> $hname

    cat >> $hname <<EOF
    </div>
    <div id="postamble" class="status">
      <p>
        <a href="./index.html">Blog Index</a>
        &bull; <a href="./tags/index.html">Posts by Tag</a>
        &bull; <a href="../index.html">Home</a>
      </p>
      <p class="small">Copyright 2007-$(date +%Y) $author (modified: $(date))</p>
    </div>
  </body>
</html>
EOF

done <<< "`ls -1r *.org`"
