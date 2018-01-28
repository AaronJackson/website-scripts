#!/bin/bash

cd ~/public_html/blog/

cat > feed.rss <<EOF
<?xml version="1.0"  encoding="UTF-8" ?>
<rss version="2.0">
  <channel>
    <title>Aaron S. Jackson - Blog</title>
    <author>Aaron S. Jackson</author>
    <link>http://aaronsplace.co.uk/blog</link>
    <description>boring posts by aaron</description>
EOF

cat > index.html <<EOF
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Blog - Aaron S. Jackson</title>
    <meta name="author" content="Aaron S. Jackson" />
    <link rel="stylesheet" type="text/css" href="../style.css" />
    <meta name="viewport" content="width=500px">
    <link rel="alternate" type="application/rss+xml"
     	  title="RSS Feed"
	  href="http://aaronsplace.co.uk/blog/feed.rss" />
  </head>
  <body>
    <div id="preamble" class="status">
      <p><a href="./index.html">Blog Index</a>
        &bull; <a href="./tags/index.html">Posts by Tag</a>
	&bull; <a href="feed.rss">RSS Feed</a>
        &bull; <a href="../index.html">Home</a>
      </p>
    </div>
    <div id="content" class="post">
      <h1>Aaron S. Jackson - Blog</h1>
      <p>

	This blog is mainly for me to post things which I can refer
	back to, or share with friends/family if appropriate, but you
	are welcome to browse. Quite often I post short snippets of
	code or scripts - these can be used and modified freely
	(assume MIT License), but a reference back is always
	appreciated. There is no comment section, although feedback is
	welcome via email.

      </p>
      <ul>
EOF


while read -r file; do
    hname=`basename "$file" .org `.html # html file name
    post=`cat $file` # get the post title

    title=`echo "$post" | head | grep "^#+TITLE:" | cut -b10-`
    # p1=`echo "$post" | awk NR==2 RS="\n\n" | pandoc -f org -t html`

    datepat="20[0-9][0-9]-[0-9][0-9]-[0-9][0-9] [A-z][a-z][a-z] [0-2][0-4]:[0-5][0-9]"
    modified=`echo "$post" | grep -v \#\+ | grep -oP "$datepat" | tail -n1`
    htmltitle=$title
    if [[ $modified ]]; then
	htmltitle="$htmltitle <span class=\"small\">[update added $modified]</span>"
    fi

    date=`echo "$post" | head | grep "^#+DATE:" | cut -b9-`


    draft=`echo "$post" | head | grep "^#+DRAFT" | wc -l`
    [ $draft -gt 0 ] && continue

    rfcdate=$(echo $date | cut -b2-21)
    rfcdate=$(date -R -d "$rfcdate")
    date=$(echo $date | recode ascii..html)

    cat >> index.html <<EOF
<li><a href="$hname">$date - $htmltitle</a><br /></li>
EOF

    cat >> feed.rss <<EOF
    <item>
      <title>$title</title>
      <link>http://aaronsplace.co.uk/blog/$hname</link>
      <pubDate>$rfcdate</pubDate>
      <guid>http://aaronsplace.co.uk/blog/$hname</guid>
    </item>
EOF
done <<< "`ls -1r *.org`"


cat >> index.html <<EOF
      </ul>
    </div>
    <div id="postamble" class="status">
      <p>
        <a href="./index.html">Blog Index</a>
        &bull; <a href="./tags/index.html">Posts by Tag</a>
        &bull; <a href="feed.rss">RSS Feed</a>
        &bull; <a href="../index.html">Home</a>
      </p>
      <p class="small">Copyright 2007-$(date +%Y) $author (modified: $(date))</p>
    </div>
  </body>
</html>
EOF

cat >> feed.rss <<EOF
  </channel>
</rss>
EOF
