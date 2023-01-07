#!/bin/sh

cd /opt/alist
/bin/busybox-extras httpd -p 81 -h /www
/usr/sbin/nginx
/updateall

if [[ -f /mytoken.txt ]] && [[ -s /mytoken.txt ]]; then
        user_token=$(head -n1 /mytoken.txt)
        /token $user_token
        echo `date` "User's own token $user_token has been updated into database succefully"
fi

exec "$@"

