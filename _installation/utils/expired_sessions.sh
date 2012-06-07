#/bin/sh
echo "Cleaning up"
cd /var/www/taracot/data/sandbox/bin/ 
./expired_sessions.pl
exit 0
