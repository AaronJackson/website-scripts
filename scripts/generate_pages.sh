#!/bin/bash

cd ~/public_html/

author="Aaron S. Jackson"

while read -r file; do
    hname=`basename "$file" .org `.html # html file name
    page=`cat $file` # get the post title

    title=`echo "$page" | head | grep "#+TITLE:" | cut -b10-`
    echo "Generating $title"

    cat > $hname <<EOF
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>$title</title>
    <meta name="author" content="$author" />
    <link rel="stylesheet" type="text/css" href="../style.css" />
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
    <div id="postamble" class="status">
      <p><a href="index.html">&larr; Return Home</a></p>
    </div>
  </body>
</html>
EOF

done <<< "`ls -1r *.org`"
