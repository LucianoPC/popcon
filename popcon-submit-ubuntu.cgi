#!/usr/bin/python

import os, sys, cgi, errno
import cgitb; cgitb.enable()
uploadDir = '/srv/popcon.ubuntu.com/popcon-data/'
logDir = '/srv/popcon.ubuntu.com/logs/'

def mkdirs(newdir,mode=0777):
        try: os.makedirs(newdir,mode)
        except OSError, err:
                if err.errno != errno.EEXIST or not os.path.isdir(newdir):
                        raise


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

print """Content-Type: text/plain

Thanks!
"""
