#!/bin/bash
set -e
PATH=$HOME/bin:$PATH
cd $HOME

# rotate files
rm -rf popcon-entries.old
mkdir popcon-entries 2>/dev/null || true
cp -a popcon-entries popcon-entries.old
mv new-popcon-entries new-popcon-entries.old
touch new-popcon-entries
chmod og-rwx new-popcon-entries

# process entries
prepop.py <new-popcon-entries.old >$HOME/prepop.out

# delete outdated entries
find $HOME/popcon-entries -type f -mtime +10 | xargs rm -f

# analyze results
cd public_html/popcon/results
rm -f results.*
find $HOME/popcon-entries -type f | wc -l >../num-submissions
find $HOME/popcon-entries -type f | xargs cat \
	| nice -15 popanal.py >$HOME/popanal.out 2>&1
cd ..
make clean >/dev/null
make >/dev/null

# upload web page to www.debian.org
cd $HOME
rsync -aze ssh public_html people.debian.org: </dev/null
