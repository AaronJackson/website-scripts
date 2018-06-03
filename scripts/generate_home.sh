#!/bin/bash

cat > .recent_posts <<EOF
<ul>
EOF
while read -r file; do
    hname=`basename "$file" .org `.html
    post=`cat $file`

    title=`echo "$post" | head | grep "^#+TITLE:" | cut -b10-`
    draft=`echo "$post" | head | grep "^#+DRAFT" | wc -l`
    [ $draft -gt 0 ] && continue

    echo "<li><a href=\"blog/$hname\">$title</a><br /></li>" \
	 >> .recent_posts

done <<< "`ls -1r blog/*.org | sort -rn | head -n5`"

cat >> .recent_posts <<EOF
</ul>
EOF

cat index.html | \
    awk 'BEGIN {p=1}
    	/^\s*<!-- include \S+ -->/ \
		  { print;  system("cat " $3) ; p=0 }
	/^\s*<!-- end -->/ {p=1}
	p' > index.tmp
mv index.tmp index.html
