#!/bin/bash

source config
cd $blog_root

listing=`grep ^\#\+FILETAGS\: *.org | sort -r` # get a files and their tags

# get a list of all the posts
posts=`echo "$listing" | awk '{ print $1 }'`
posts=`echo "$posts" | rev | cut -c 13- | rev`

# get the tags for each post
posts_tags=`echo "$listing" | awk '{ print $2 }'`

# create a list of all tags
all_tags=`echo "$posts_tags" | tr ":" "\n" | grep -v '^$'`
all_tags=`echo "$all_tags" | sort | uniq | sort`

cat > tags/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Tag Index - ${author}</title>
    <meta name="author" content="${author}" />
    <link rel="stylesheet" type="text/css" href="../../style.css" />
    <meta name="viewport" content="width=device-width">
  </head>
  <body>
    <div id="preamble" class="status">
      <p><a href="../index.html">Blog Index</a>
        &bull; <a href="../../index.html">Home</a>
      </p>
    </div>
    <div id="content" class="post">
      <h1>Tag Index</h1>
      <ul>
EOF

# create a tag file for each tag
while read -r tag; do
    count=`grep ^\#\+FILETAGS\:.*\:$tag\: *.org | wc -l`
    echo "$tag appeared $count times"

    cat >> tags/index.html <<EOF
<li><a href="$tag.html">$tag</a> ($count)</li>
EOF

    cat > tags/$tag.html <<EOF
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>Tag $tag</title>
    <meta name="author" content="Aaron S. Jackson" />
    <link rel="stylesheet" type="text/css" href="../../style.css" />
  </head>
  <body>
    <div id="preamble" class="status">
      <p><a href="./index.html">All Tags</a>
        &bull; <a href="../index.html">Blog Index</a>
        &bull; <a href="../../index.html">Home</a>
      </p>
    </div>
    <div id="content" class="post">
      <h1>Tag: $tag</h1>
      <ul>
EOF
done <<< "$all_tags"


# populate the tag files
while read -r file; do
    hname=`basename "$file" .org `.html # html file name

    # get the file tags and pop it off from the "stack"
    tags=`echo "$posts_tags" | head -n1 | tr ':' '\n' | grep -v '^$'`
    posts_tags=`echo "$posts_tags" | tail -n +2`

    # get the post title and date
    title=`cat $file | grep ^\#\+TITLE\: | cut -c 10-`
    date=`cat $file | grep ^\#\+DATE\: | cut -c 9-`

    # for each tag, add this file to that tag file...
    while read -r tag; do
	cat >> tags/$tag.html <<EOF
<li><a href="../$hname">$date - $title</a></li>
EOF
    done <<< "$tags"
done <<< "$posts"

while read -r tag; do
    cat >> tags/$tag.html <<EOF
      </ul>
    </div>
    <div id="postamble" class="status">
      <p><a href="./index.html">All Tags</a>
        &bull; <a href="../index.html">Blog Index</a>
        &bull; <a href="../../index.html">Home</a>
      </p>
      <p class="small">Copyright $copyright $author (compiled: $(date))</p>
    </div>
  </body>
</html>
EOF
    if [ ! -z "$gpg_key" ] ; then
	gpg2 --yes --default-key $gpg_key --detach-sig -o tags/$tag.asc tags/$tag.html
    fi
done <<< "$all_tags"

cat >> tags/index.html <<EOF
      </ul>
    </div>
    <div id="postamble" class="status">
      <p><a href="../index.html">Blog Index</a>
        &bull; <a href="../../index.html">Home</a>
      </p>
      <p class="small">Copyright $copyright $author (compiled: $(date))</p>
    </div>
  </body>
</html>
EOF

if [ ! -z "$gpg_key" ] ; then
    gpg2 --yes --default-key $gpg_key --detach-sig -o tags/index.asc tags/index.html
fi
