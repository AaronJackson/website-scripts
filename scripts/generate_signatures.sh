find . -name "*.html" | while read h ; do
    hh=`echo $h | sed 's/.html$/.asc/'`
    gpg2 --default-key 32716A1F --detach-sig -o "$hh" "$h"
done
