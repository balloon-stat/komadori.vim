#! /usr/bin/python
# -*- encoding: utf-8 -*-

import time
import threading
import subprocess

class Periodic:
    def __init__(self, arg):
        self.interval = int(arg['interval']) / 1000
        self.temp_dir = arg['temp_dir']
        self.arg = arg
        self.is_running = True
        self.is_finish = False

    def runWith(self, arg):
        if arg == 'posh':
            th = threading.Thread(target=self.runPosh)
        elif arg == 'magick':
            th = threading.Thread(target=self.runMagick)
        else:
            print 'no target'
            return
        th.daemon = True
        th.start()

    def runPosh(self):
        cmdfile = self.arg['path'] + 'oneshot.ps1'
        arg_part = cmdfile + self.arg['margin']
        info = subprocess.STARTUPINFO()
        info.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        i = 1
        while i < 300:
            time.sleep(self.interval)
            if self.is_finish: return
            if not self.is_running: continue
            name = self.temp_dir + 'komadori_{0:0>3}.gif'.format(i)
            arg = '{0} | % {{ $_.save("{1}")}}'.format(arg_part, name)
            subprocess.call(['powershell', '-WindowStyle', 'Hidden',
                '-ExecutionPolicy', 'RemoteSigned', '-NoProfile', '-Command', arg], startupinfo=info)
            i += 1

    def runMagick(self):
        i = 1
        while i < 300:
            time.sleep(self.interval)
            if self.is_finish: return
            if not self.is_running: continue
            name = self.temp_dir + 'komadori_{0:0>3}.gif'.format(i)
            subprocess.call(['import', '-silent',
                '-window', self.arg['win_id'], '-crop', self.arg['geometry'],  name])
            i += 1

    def pause(self):
        self.is_running = False

    def restart(self):
        self.is_running = True

    def finish(self):
        self.is_finish = True


