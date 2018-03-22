#! /bin/bash
# sonar.sh From https://github.com/wilsonmar/git-utilities

chmod 555 sonar-scanner
./sonar-scanner \
  -Dsonar.projectKey=sonarqube-1-vm \
  -Dsonar.sources=/Users/wilsonmar/gits/ng/angular4-docker-example \
  -Dsonar.host.url=http://23.236.48.147  \
  -Dsonar.login=7a51cb71a48ea3d16f57fe66021867fc2a98771e