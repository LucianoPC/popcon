#!/bin/bash
set -e
cd /org/popcon.debian.org/popcon-mail
umask 0002
# rotate files
mv ../Mail/survey new-popcon-entries
touch ../Mail/survey
chmod go-rwx ../Mail/survey

# process entries
./prepop.py <new-popcon-entries >prepop.out

# delete outdated entries
rm -f results
find popcon-entries -type f -mtime +10 -print0 | xargs -0 rm -f --
find popcon-entries -type f | xargs cat \
        | nice -15 ./popanal.py >popanal.out 2>&1
cp results ../www/all-popcon-results.txt
gzip -f ../www/all-popcon-results.txt
cp ../www/all-popcon-results.txt.gz all-popcon-results/popcon-`date +"%Y-%m-%d"`.gz
cd ../popcon-web
./popcon.pl
