#!/usr/bin/python
#
# Script to receive popcon reports using HTTP POST, and store them in
# a directory.
#
# Require at least python version 2.2 to use the cgitb module.

import os, sys, cgi, errno
try: # Use cgitb when available
    import cgitb
    cgitb.enable()
except:
    sys.stderr = sys.stdout

basedir   = '/srv/popcon.ubuntu.com'
uploadDir = '%s/popcon-data/' % basedir
logDir    = '%s/logs/' % basedir

def mkdirs(newdir,mode=0777):
        try: os.makedirs(newdir,mode)
        except OSError, err:
                if err.errno != errno.EEXIST or not os.path.isdir(newdir):
                        raise

error = 0
formStorage = cgi.FieldStorage()
fileitem = formStorage["popcondata"]
if fileitem.file:
        header = fileitem.file.readline()
        try:
                id = header.split()[2].split(":")[1]
                hash = id[:2]
                hashDir = uploadDir + hash + '/'
                filename = hashDir + id
                mode = 'w'
        except IndexError:
                filename = logDir + "panic-popcon-submit-log"
                mode = 'a'
        
        mkdirs(hashDir,0755)
        data = file(filename,mode)
        data.writelines(header)
        data.writelines(fileitem.file)
        data.close()
else:
	error = "Unable to find uploaded file in POST request"

print """Content-Type: text/plain
"""
if error:
	print error
else:
	print "Thanks for your submission to Debian Popularity-Contest!"
	print "DEBIAN POPCON HTTP-POST OK\n"
