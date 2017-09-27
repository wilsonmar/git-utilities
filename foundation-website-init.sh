#!/usr/bin/env bash

# foundation-website-init.sh from within http://github.com/wilsonmar/git-utilities
# by Wilson Mar (wilsonmar@gmail.com, @wilsonmar)

TZ=":UTC" date +%z
  NOW=$(date +%Y-%m-%d:%H:%M:%S%z)
           # 2016-09-16T05:26-06:00 vs UTC

    # Make the beginning of run easy to find:
        echo "**********************************************************"
        echo "******** $NOW Versions :"
# After "brew install git" on Mac:
git --version

  GITHUB_USER="hotwilson"
  REPONAME='website1'
  echo ${REPONAME} >website_name

npm install -g foundation-cli

npm i -g npm

# Verify if foundation has been installed or abort:
foundation -version

mkdir ~/gits/${GITHUB_USER}/${REPONAME}
cd ~/gits/${GITHUB_USER}/${REPONAME}

git clone https://github.com/${GITHUB_USER}/${REPONAME}

npm install

git init && git add . && git commit -m”Initial”

# Run in batch:
npm start &

npm run build

open http://localhost:8000

git add . && git commit -m”update” && git push

