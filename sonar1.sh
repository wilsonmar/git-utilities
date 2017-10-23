#! /bin/bash
# sonar.sh From https://github.com/wilsonmar/git-utilities

chmod 555 sonar-scanner
./sonar-scanner \
  -Dsonar.projectKey=Angular-35.202.3.232 \
  -Dsonar.sources=/Users/wilsonmar/gits/ng \
  -Dsonar.host.url=http://35.202.3.232 \
  -Dsonar.login=b0b030cd2d2cbcc664f7c708d3f136340fc4c064