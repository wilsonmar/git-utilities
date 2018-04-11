#!/usr/bin/python
# jenkins_secret_chrome.py in https://github.com/wilsonmar/git-utilities/tree/master/tests/
# Call pattern:
#    python tests/jenkins_secret_chrome.py   $JENKINS_PORT  $JENKINS_SECRET  jenkins.png

#import argparse  # https://docs.python.org/2/howto/argparse.html
import sys
import pytz, time
from datetime import datetime, tzinfo, timedelta
from random import randint

from selenium import webdriver
from selenium.webdriver.common.keys import Keys

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

jenkins_port=sys.argv[1]
jenkins_secret=sys.argv[2]
#picture_path=sys.argv[3]
print('Params=', jenkins_port, jenkins_secret)

# TODO: #parser = argparse.ArgumentParser("simple_example")
#parser.add_argument("counter", help="An integer will be increased by 1 and printed.", type=int)
#args = parser.parse_args()
#print(args.counter + 1)

driver = webdriver.Chrome()
#driver = webdriver.Firefox()
driver.get("http://localhost:" + jenkins_port) # TODO: pass port in
assert "Jenkins [Jenkins]" in driver.title  # bail out if not found. Already processed.
#time.sleep(5) # to see it.

# <input id="security-token" class="form-control" type="password" name="j_password">         
secret = driver.find_element_by_id('security-token')
secret.send_keys(jenkins_secret)
secret.submit()
time.sleep(10) # to give it time to work.

# Take a picture (screen shot) of "Getting Started, Customize Jenkins"
driver.save_screenshot('jenkins_secret_chrome.py' +iso8601_local()+ '.png')
assert "SetupWizard [Jenkins]" in driver.title 
#time.sleep(5) # to see it

driver.dispose()
