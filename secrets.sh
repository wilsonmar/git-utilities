#!/usr/local/bin/bash
# secrets.sh in https://github.com/wilsonmar/mac-install-all
# referenced by macos-install-all.sh in the same repo.
# This file name secrets.sh should be specified in .gitignore so 
#    it doesn't upload to a public GitHub/GitLab/BitBucket/etc.
# Run command source secrets.sh pulls these variables in:
# CAUTION: No spaces around = sign.
GIT_NAME="Wilson Mar"
GIT_ID="WilsonMar@gmail.com"
GIT_EMAIL="WilsonMar+GitHub@gmail.com"
GIT_USERNAME="hotwilson"
GPG_PASSPHRASE="only you know this 2 well"
GITS_PATH="~/gits"
GITHUB_ACCOUNT="hotwilson"
GITHUB_PASSWORD="change this to your GitHub account password"
GITHUB_REPO="sample"

# Lists can be specified below. The last one in a list is the Git default:
MAC_TOOLS=""
         # mas, ansible, 1password, powershell, kindle, vmware-fusion?
GIT_CLIENT=""
          # git, cola, github, gitkraken, smartgit, sourcetree, tower, magit, gitup
GIT_EDITOR=""
          # atom, code, eclipse, emacs, intellij, macvim, nano, pico, sts, sublime, textmate, textedit, vim
          # NOTE: pico, nano, and vim are built into MacOS, so no install.
          # NOTE: textwrangler is a Mac app manually installed from the Apple Store.
GIT_BROWSER=""
           # chrome, firefox, brave, phantomjs,    NOT: Safari
           # others (flash-player, adobe-acrobat-reader, adobe-air, silverlight)
GIT_TOOLS=""
         # none, hooks, tig, lfs, diff-so-fancy, grip, p4merge, git-flow, signing, hub
GIT_LANG="python"
        # python, python3, java, node, go
JAVA_TOOLS=""
          # maven, gradle, TestNG, cucumber, gcviewer, jmeter, jprofiler  # REST-Assured, Spock
          # (Via maven, ant, or gradle: junit4, junit5, yarn, dbunit, mockito)
PYTHON_TOOLS=""
            # virtualenv, anaconda, jupyter, ipython, numpy, scipy, matplotlib, pytest, robot
            # robotframework, others
            # See http://www.southampton.ac.uk/~fangohr/blog/installation-of-python-spyder-numpy-sympy-scipy-pytest-matplotlib-via-anaconda.html
NODE_TOOLS=""
          # bower, gulp, gulp-cli, npm-check, jscs, less, jshint, eslint, webpack, 
          # mocha, chai, protractor, 
          # browserify, express, hapi, angular, react, redux
          # graphicmagick, aws-sdk, mongodb, redis, others
DATA_TOOLS=""
         # mariadb, postgresql, mongodb
         # others (dbunit?, mysql?, evernote?)
         # others (google-drive-file-stream, dropbox, box, amazon-drive )
   MONGODB_DATA_PATH="/usr/local/var/mongodb" # default.
TEST_TOOLS=""
        # selenium, sikulix, golum, dbunit?
        # Drivers for scripting language depend on what is defined in $GIT_LANG.
CLOUD=""
     # icloud, aws, gcp, azure, cf, heroku, docker, vagrant,   
     # terraform, serverless, 
     # NOT: openstack
   AWS_ACCOUNT=""
   AWS_ACCESS_KEY_ID=""
   AWS_SECRET_ACCESS_KEY=""
   AWS_REGION="us-west-1"

   AZ_PRINCIPAL=""
   AZ_USER=""
   AZ_PASSWORD=""
   AZ_TENANT=""
   AZ_REGION=""

   GCP_PROJECT=""
   GCP_USER=""
   GCP_KEY=""
   GCP_REGION=""

   SAUCE_USERNAME=""
   SAUCE_ACCESS_KEY=""
COLAB_TOOLS=""
          # google-hangouts, hipchat, joinme, keybase, microsoft-lync, skype, slack, teamviewer, whatsapp, sococo, zoom
          # NO gotomeeting (32-bit)
MEDIA_TOOLS=""
           # others (audacity?, snagit?, camtasia?)
VIZ_TOOLS=""
         # grafana, 
LOCALHOSTS=""
          # minikube, nginx, tomcat, jenkins, grafana, 
     MINIKUBE_PORT="8083" # from default 8080
     NGINX_PORT="8086"    # from default 8080
     TOMCAT_PORT="8087"   # from default 8080
     JENKINS_PORT="8088"  # from default 8080
     GRAFANA_PORT="8089"  # from default 8080
TRYOUT="all"  # smoke tests.
      # all, HelloJUnit5, TODO: `virtuaenv, phantomjs, docker, hooks, jmeter, minikube, cleanup, editor
TRYOUT_KEEP="jenkins"

# To upgrade, add parameter in the command line:
#    ./mac-git-install.sh upgrade
