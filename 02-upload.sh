#! /bin/sh
# vim: set noexpandtab tw=0:
# Upload the documentation to the web server.


echo "Uploading now. I hope you rebuilt it first..."
aliothdir=/srv/home/groups/po4a/htdocs/
scp -r src/*.* po4a.alioth.debian.org:$aliothdir
scp -r html/*.* po4a.alioth.debian.org:$aliothdir
scp -r html/man po4a.alioth.debian.org:$aliothdir
scp -r src/.htaccess po4a.alioth.debian.org:$aliothdir || true
ssh po4a.alioth.debian.org chgrp -R po4a $aliothdir 2> /dev/null || true 
ssh po4a.alioth.debian.org chmod -R g+rw $aliothdir
ssh po4a.alioth.debian.org chmod -R g+rw $aliothdir/.htaccess
echo done

