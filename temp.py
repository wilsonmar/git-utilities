#!/usr/bin/python
# temp.py

import pytz, time
from datetime import datetime, tzinfo, timedelta
from random import randint

def iso8601_utc():
    class simple_utc(tzinfo):
        def tzname(self,**kwargs):
            return "UTC"
        def utcoffset(self, dt):
            return timedelta(0)
    return datetime.utcnow().replace(tzinfo=simple_utc()).isoformat()
    #print(iso8601_utc()+"   = ISO8601 time at +00:00 UTC (Zulu time), with microseconds")

def iso8601_local():
    class local_tz(tzinfo):
        def utcoffset(self, dt):
            ts = time.time()
            offset_in_seconds = (datetime.fromtimestamp(ts) - datetime.utcfromtimestamp(ts)).total_seconds()
            return timedelta(seconds=offset_in_seconds)
    return datetime.now().replace(microsecond=randint(0, 999999)).replace(tzinfo=local_tz()).isoformat()
    # print(iso8601_local()+" = ISO8601 time at local time zone offset, with random microseconds")

print(iso8601_utc()+"   = ISO8601 time at +00:00 UTC (Zulu time), with microseconds")
print(iso8601_local()+" = ISO8601 time at local time zone offset, with random microseconds")



#tz = pytz.timezone('America/Los_Angeles')
#print(datetime.fromtimestamp(1463288494, tz).isoformat())

#2016-05-14T22:01:34-07:00

#import sys
#import argparse  # https://docs.python.org/2/howto/argparse.html
#import time  # tzinfo,  timedelta

#utc_offset_sec = time.altzone if time.localtime().tm_isdst else time.timezone
#datetime.datetime.now().replace(tzinfo=datetime.timezone(offset=utc_offset_sec)).isoformat()

#class TZ(tzinfo):
#   def utcoffset(self, dt): return timedelta(minutes=-399)
#datetime(2002, 12, 25, tzinfo=TZ()).isoformat(' ')

#print('jenkins_secret_chrome.py' +utc_offset_sec+ '.png')
