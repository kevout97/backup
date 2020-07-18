import os
import sys
import subprocess
import pyinotify as inotify
import re
from datetime import datetime
import logging
import logging.handlers
import socket


def syslog(message="This a message", host='localhost', port=514):
    my_logger = logging.getLogger('Monitoring')
    my_logger.setLevel(logging.WARNING)
    if rsyslog_protocol == "UDP" or rsyslog_protocol == "udp":
        handler = logging.handlers.SysLogHandler(address = (host, port), socktype=socket.SOCK_DGRAM)
    else:
        handler = logging.handlers.SysLogHandler(address = (host, port), socktype=socket.SOCK_STREAM)
    my_logger.addHandler(handler)
    my_logger.warning(message)

class EventHandler(inotify.ProcessEvent):
    def process_IN_CREATE(self, event):
        if os.path.isdir(str(event.pathname)):
            alert="The directory " + str(event.pathname) + " was created."
            syslog(message=alert,host=rsyslog_host,port=rsyslog_port)
            print("[AMX " + str(datetime.now()) +"] The directory " + str(event.pathname) + " was created.")
        else:
            alert="The file " + str(event.pathname) + " was created."
            syslog(message=alert,host=rsyslog_host,port=rsyslog_port)
            print("[AMX " + str(datetime.now()) +"] The file " + str(event.pathname) + " was created.")

    def process_IN_ACCESS(self, event):
        if os.path.isdir(str(event.pathname)):
            alert="The directory " + str(event.pathname) + " was access."
            syslog(message=alert,host=rsyslog_host,port=rsyslog_port)
            print("[AMX " + str(datetime.now()) +"] The directory " + str(event.pathname) + " was access.")
        else:
            alert="The file " + str(event.pathname) + " was access."
            syslog(message=alert,host=rsyslog_host,port=rsyslog_port)
            print("[AMX " + str(datetime.now()) +"] The file " + str(event.pathname) + " was access.")

    def process_IN_ATTRIB(self, event):
        if os.path.isdir(str(event.pathname)):
            alert="The attributes of directory " + str(event.pathname) + " was changed."
            syslog(message=alert,host=rsyslog_host,port=rsyslog_port)
            print("[AMX " + str(datetime.now()) +"] The attributes of directory " + str(event.pathname) + " was changed.")
        else:
            alert="The attributes of file " + str(event.pathname) + " was changed."
            syslog(message=alert,host=rsyslog_host,port=rsyslog_port)
            print("[AMX " + str(datetime.now()) +"] The attributes of file " + str(event.pathname) + " was changed.")

    def process_IN_CLOSE_NOWRITE(self, event):
        if os.path.isdir(str(event.pathname)):
            alert="The directory " + str(event.pathname) + " was closed without write something."
            syslog(message=alert,host=rsyslog_host,port=rsyslog_port)
            print("[AMX " + str(datetime.now()) +"] The directory " + str(event.pathname) + " was closed without write something.")
        else:
            alert="The file " + str(event.pathname) + " was closed without write something."
            syslog(message=alert,host=rsyslog_host,port=rsyslog_port)
            print("[AMX " + str(datetime.now()) +"] The file " + str(event.pathname) + " was closed without write something.")

    def process_IN_CLOSE_WRITE(self, event):
        if os.path.isdir(str(event.pathname)):
            alert="The directory " + str(event.pathname) + " was closed and was wrote something."
            syslog(message=alert,host=rsyslog_host,port=rsyslog_port)
            print("[AMX " + str(datetime.now()) +"] The directory " + str(event.pathname) + " was closed and was wrote something.")
        else:
            alert="The file " + str(event.pathname) + " was closed and was wrote something."
            syslog(message=alert,host=rsyslog_host,port=rsyslog_port)
            print("[AMX " + str(datetime.now()) +"] The file " + str(event.pathname) + " was closed and was wrote something.")

    def process_IN_DELETE(self, event):
        if os.path.isdir(str(event.pathname)):
            alert="The directory " + str(event.pathname) + " was deleted."
            syslog(message=alert,host=rsyslog_host,port=rsyslog_port)
            print("[AMX " + str(datetime.now()) +"] The directory " + str(event.pathname) + " was deleted.")
        else:
            alert="The file " + str(event.pathname) + " was deleted."
            syslog(message=alert,host=rsyslog_host,port=rsyslog_port)
            print("[AMX " + str(datetime.now()) +"] The file " + str(event.pathname) + " was deleted.")

    def process_IN_MODIFY(self, event):
        if os.path.isdir(str(event.pathname)):
            alert="The directory " + str(event.pathname) + " was modify."
            syslog(message=alert,host=rsyslog_host,port=rsyslog_port)
            print("[AMX " + str(datetime.now()) +"] The directory " + str(event.pathname) + " was modify.")
        else:
            alert="The file " + str(event.pathname) + " was modify."
            syslog(message=alert,host=rsyslog_host,port=rsyslog_port)
            print("[AMX " + str(datetime.now()) +"] The file " + str(event.pathname) + " was modify.")

    def process_IN_OPEN(self, event):
        if os.path.isdir(str(event.pathname)):
            alert="The directory " + str(event.pathname) + " was open."
            syslog(message=alert,host=rsyslog_host,port=rsyslog_port)
            print("[AMX " + str(datetime.now()) +"] The directory " + str(event.pathname) + " was open.")
        else:
            alert="The file " + str(event.pathname) + " was open."
            syslog(message=alert,host=rsyslog_host,port=rsyslog_port)
            print("[AMX " + str(datetime.now()) +"] The file " + str(event.pathname) + " was open.")

wm = inotify.WatchManager()
directories = re.split(";",str(os.environ.get('MONITORING_DIRECTORIES')))
rsyslog_host=str(os.environ.get('MONITORING_RSYSLOG_HOST'))
rsyslog_port=int(os.environ.get('MONITORING_RSYSLOG_PORT'))
rsyslog_protocol=str(os.environ.get('MONITORING_RSYSLOG_PROTOCOL'))

for directory in directories:
    wm.add_watch(directory,inotify.ALL_EVENTS, rec=True, auto_add=True)

notifier = inotify.Notifier(wm, EventHandler())
notifier.loop()