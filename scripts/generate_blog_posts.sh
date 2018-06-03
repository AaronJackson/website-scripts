#!/bin/bash

source config
cd $blog_root

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
    post=`cat $file` # get the post title
    firstsen=`echo "$post" | grep -ve ^# -e "^$" | \
    		   head -n2 | tr '\n' ' ' | recode ascii..html`

    title=`echo "$post" | head | grep "#+TITLE:" | cut -b10- | \
    		    recode ascii..html`
    date=`echo "$post" | head | grep "#+DATE:" | cut -b9-`
    echo "Generating $title"

    img_default="../img/asj6.jpg"
    img=`echo "$post" | head | grep "#+IMG:" | cut -b8-`
    img=${img:=$img_default}

    date="${date//\</&lt;}"
    date="${date//\>/&gt;}"

    cat > $hname <<EOF
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>$title - ${author}</title>
    <meta name="author" content="$author" />
    <link rel="stylesheet" type="text/css" href="../style.css" />
    <meta name="viewport" content="width=device-width">
    <meta name="twitter:card" content="summary" />
    <meta name="twitter:site" content="@_asjackson" />
    <meta name="twitter:title" content="$title" />
    <meta name="twitter:description" content="$firstsen" />
    <meta name="twitter:image" content="https://${root}/${blog_root}/$img" />
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
    maintag=`echo "$tags" | head -n1`

    related=$(grep -l "^\#+FILETAGS: :$maintag:" *.org | grep -v $file)
    if [[ $(echo "$related" | wc -l) -gt 0 ]]; then
	echo "<p>Related posts:</p>" >> $hname
	echo "<ul>" >> $hname
	echo "$related" \
	    | sort -nr | head -n4 \
	    | while read rel; do
	    rtitle=$(head $rel | grep "#+TITLE:" | cut -b10-)
	    rlink=$(echo $rel | sed 's/.org$/.html/')
	    echo "<li><a href=\"$rlink\">$rtitle</a></li>" >> $hname
	done
	echo "</ul>" >> $hname
    fi

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
      <p class="small">Copyright $copyright $author (compiled: $(date))</p>
    </div>
  </body>
</html>
EOF
    if [ ! -z "$gpg_key" ] ; then
       gpg2 --yes -q --default-key ${gpg_key} --detach-sig -o "$sname" "$hname" 
    fi
done <<< "`ls -1r *.org`"
