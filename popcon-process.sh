#!/bin/sh
set -e
cd /org/popcon.debian.org/popcon-mail
umask 0002
# rotate files
mv ../Mail/survey new-popcon-entries
touch ../Mail/survey
chmod go-rwx ../Mail/survey

# process entries
./prepop.pl <new-popcon-entries >prepop.out 2>&1

# delete outdated entries
rm -f results
find popcon-entries -type f -mtime +20 -print0 | xargs -0 rm -f --
find popcon-entries -type f | xargs cat \
        | nice -15 ./popanal.py >popanal.out 2>&1
cp results ../www/all-popcon-results.txt
gzip -f ../www/all-popcon-results.txt
cp ../www/all-popcon-results.txt.gz all-popcon-results/popcon-`date +"%Y-%m-%d"`.gz
cd ../popcon-stat

find ../popcon-mail/all-popcon-results -type f -print | sort |./popcon-stat.pl

cd ../popcon-web
./popcon.pl
