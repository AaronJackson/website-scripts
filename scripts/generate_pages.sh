#!/bin/bash

source config
cd $1

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
    sname=`echo $hname | sed 's/.html$/.asc/'`
    page=`cat $file` # get the post title

    title=`echo "$page" | head | grep "#+TITLE:" | cut -b10-`
    options=`echo "$page" | head | grep "#+OPTIONS:" | cut -b12-`

    echo "Generating $title"

    cat > $hname <<EOF
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>$title - ${author}</title>
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
      <p><a href="$2index.html">&larr; Return Home</a></p>
      <p class="small">Copyright $copyright $author (compiled: $(date))</p>
    </div>
  </body>
</html>
EOF

        if [ ! -z "$gpg_key" ] ; then
	    gpg2 --yes -q --default-key $gpg_key --detach-sig -o "$sname" "$hname"
	fi
done <<< "`ls -1 *.org`"
