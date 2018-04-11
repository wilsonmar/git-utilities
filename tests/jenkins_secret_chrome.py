#!/usr/bin/python
# jenkins_secret_chrome.py in https://github.com/wilsonmar/git-utilities/tree/master/tests/
# Call pattern:
#    python tests/jenkins_secret_chrome.py   $JENKINS_PORT  $JENKINS_SECRET  jenkins.png

import sys
#import argparse  # https://docs.python.org/2/howto/argparse.html
import time, datetime

from selenium import webdriver
from selenium.webdriver.common.keys import Keys

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
utc_offset_sec = time.altzone if time.localtime().tm_isdst else time.timezone
datetime.datetime.now().replace(tzinfo=datetime.timezone(offset=utc_offset_sec)).isoformat()
driver.save_screenshot('jenkins_secret_chrome.py' +utc_offset_sec+ '.png')
assert "SetupWizard [Jenkins]" in driver.title 
#time.sleep(5) # to see it

driver.dispose()
