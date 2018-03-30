# firefox_github_ssh_add.py in https://github.com/wilsonmar/git-utilities
# Invokes python Firefox driver to open GitHub, SSH Keys, insert what waw pbcopy to clipboard.
from selenium import webdriver
from selenium.webdriver.common.keys import Keys

driver = webdriver.Firefox()

driver.get("https://www.github.com/")
assert "The world's leading" in driver.title

### Sign-in:
elem = driver.find_element_by_name("Sign in")
elem.send_keys(Keys.RETURN)

#assert "Sign-in" in driver.title
#elem = driver.find_element_by_name("login")  # within Form
#elem.clear()
#elem.send_keys("UserID") # from ./secrets.sh

#elem = driver.find_element_by_name("password")
#elem.clear()
#elem.send_keys("password") # from ./secrets.sh via MacOS Clipboard.

#elem = driver.find_element_by_name("Sign In")  # Green button
#elem.send_keys(Keys.RETURN)

### New SSH Key:
#elem = driver.find_element_by_name("SSH Key")
#elem = driver.find_element_by_name("SSH key field")
#elem.clear()
#elem.send_keys("SSH Key") # from file (not Clipboard)
#elem.send_keys(Keys.RETURN)

#assert "No results found." not in driver.page_source
driver.close()
