#!/usr/bin/python
# Accept popularity-contest entries on stdin and drop them into a
# subdirectory with a name based on their MD5 ID.
#
# Only the most recent entry with a given MD5 ID is kept.
#

import sys, string, os, time, re
from sys import stderr

dirname = 'popcon-entries'
output = None

now = time.time()

msgstartre = re.compile("^From")
md5sumre   = re.compile("^[a-f0-9]{32}$")
timere     = re.compile("^[0-9]+$")

def closereport(output, md5, mtime):
    if output != None:
	print "%s: %s" % (md5, time.ctime(mtime))
	output.write(line)
	output.close()
	output = None
	os.utime(fname, (mtime, mtime))
    return output

while 1:
    line = sys.stdin.readline()
    if not line:
	output = closereport(output, md5, mtime)
	break

    split = string.split(line)
    if not split: continue

    if split[0] == 'POPULARITY-CONTEST-0':
	if output != None:
	    output.close()
	    output = None

	mtime = 0
	for s in split[1:]:
	    list = string.split(s, ':')
	    try:
		key, value = list
	    except:
		continue
	    if key == 'ID':
		if not md5sumre.match(value):
		    print >>stderr,"Bad hostid: %s" % value
		else:
		    md5 = value
		    subdir = dirname + '/' + value[0:2]
		    try:
			os.mkdir(subdir)
		    except os.error:  # already exists
			pass
		    fname = subdir + '/' + md5
		    output = open(fname, "w")
		    output.write(line)
	    elif key == 'TIME':
		if not timere.match(value):
		    print >>stderr,"Bad mtime: %s" % value
		else:
		    mtime = float(value)
		    if (mtime > now):
			mtime = now

    elif split[0] == 'END-POPULARITY-CONTEST-0' or msgstartre.match(split[0]):
	output = closereport(output, md5, mtime)

    elif output != None:
	output.write(line)
