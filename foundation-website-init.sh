#!/usr/bin/env bash
# foundation-website-init.sh from http://github.com/wilsonmar/git-utilities
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

        echo "******** GITHUB_USER=$GITHUB_USER "

mkdir ~/gits/${GITHUB_USER}
cd    ~/gits/${GITHUB_USER}

        echo "******** STEP Delete \"$REPONAME\" remnant from previous run:"
#   set -x  # xtrace command         echo on (with ++ prefix). http://www.faqs.org/docs/abs/HTML/options.html
    # Remove folder if exists (no symbolic links are used here):
if [ -d ${REPONAME} ]; then
   rm -rf ${REPONAME}
fi

  CURRENTDIR=${PWD##*/}
        echo "CURRENTDIR=$CURRENTDIR"

# exit #3


# These can be run from any directory:
# install node
npm install -g foundation-cli
npm i -g npm
# Verify if foundation has been installed or abort:
foundation -version

# exit #4

echo ${REPONAME} >website_name
foundation new --framework sites --template zurb <website_name
		# WARNING: A large amount of output comes out.

cd ${REPONAME}
pwd

# exit #5

		# Download dependencies per package.json:
npm install

# exit #6

 		# Add custom template:
# exit #7

		# Start web server:
npm start &


# exit #8

 		# Build for production:
#npm run build
# exit #9

open http://localhost:8000

# exit #10

