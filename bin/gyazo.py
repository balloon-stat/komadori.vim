#! /usr/bin/python
# -*- encoding: utf-8 -*-

import os
import vim
import urllib2
import cookielib
import datetime
import subprocess
import MultipartPostHandler

def post():
    cookies = cookielib.CookieJar()
    opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cookies),
                              MultipartPostHandler.MultipartPostHandler)
    gid = ''
    idfile = os.path.join(os.environ['HOME'], '.gyazo.id')
    if os.path.exists(idfile):
        gid = open(idfile, 'r').read().strip()
    fd = open(vim.eval('expand(g:komadori_save_file)'), 'rb')

    url = 'http://gyazo.com/upload.cgi'
    params = { 'id' : gid, 'imagedata' : fd }
    res = opener.open(url, params)

    newid = res.info().getheader('X-Gyazo-Id')
    if newid and newid != '':
        if os.path.exists(idfile):
            os.rename(idfile, idfile+datetime.datetime.now().strftime('_%Y%m%d%H%M%S.bak'))
        f = open(idfile, 'w')
        f.write(newid)
        f.close()
    return res.read()

