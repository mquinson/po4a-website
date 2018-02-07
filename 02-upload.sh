#! /bin/sh
# vim: set noexpandtab tw=0:
# Upload the documentation to the web server.


echo "Uploading now. I hope you rebuilt it first..."
rsync -rltogvz --delete-after --omit-dir-times src/ html/ po4a-uploader@www.po4a.org:/var/www/www.po4a.org/
echo done

