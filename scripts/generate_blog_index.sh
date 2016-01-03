#!/bin/bash

cd ~/public_html/blog/

cat > index.html <<EOF
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>Aaron S. Jackson - Blog</title>
    <meta name="author" content="Aaron S. Jackson" />
    <link rel="stylesheet" type="text/css" href="../style.css" />
  </head>
  <body>
    <div id="preamble" class="status">
      <p><a href="./index.html">Blog Index</a>
        &bull; <a href="./tags/index.html">Posts by Tag</a>
        &bull; <a href="../index.html">Home</a>
      </p>
    </div>
    <div id="content" class="post">
      <h1>Aaron S. Jackson - Blog</h1>
      <ul>
EOF


while read -r file; do
    hname=`basename "$file" .org `.html # html file name
    post=`cat $file` # get the post title

    title=`echo "$post" | head | grep "^#+TITLE:" | cut -b10-`
    date=`echo "$post" | head | grep "^#+DATE:" | cut -b9-`

    cat >> index.html <<EOF
<li><a href="$hname">$date - $title</a></li>
EOF
done <<< "`ls -1r *.org`"


cat >> index.html <<EOF
      </ul>
    </div>
    <div id="postamble" class="status">
    <p>
      <a href="./index.html">Blog Index</a>
      &bull; <a href="./tags/index.html">Posts by Tag</a>
      &bull; <a href="../index.html">Home</a></p>
    </div>
  </body>
</html>
EOF
