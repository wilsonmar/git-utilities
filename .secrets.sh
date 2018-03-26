#!/bin/bash
# Sample file .secrets.sh in https://github.com/wilsonmar/git-utilities
# referenced by mac-git-install.sh also in https://github.com/wilsonmar/git-utilities
# This file name .secrets.sh should be specified in .gitignore so 
# it doesn't upload to a public GitHub/BitBucket, etc.
# Command source .secrets.sh pull these variables in.
# CAUTION: No spaces around = sign.
GIT_NAME="Wilson Mar"
GIT_ID="WilsonMar@hotmail.com"
GIT_EMAIL="WilsonMar+GitHub@hotmail.com"
GIT_USERNAME="hotwilson"
GPG_PASSPHRASE="only you know this 2 well"
GITHUB_ACCOUNT="hotwilson"
GITHUB_PASSWORD="change this to your GitHub account password"
# The last one in a list is the Git default:
GIT_CLIENT="gitkraken"
          # git, cola, github, gitkraken, smartgit, sourcetree, tower 
GIT_EDITOR="sublime"
          # ano, pico, vim, sublime, code, atom, macvim, textmate, intellij, sts, eclipse.
          # NOTE: nano and vim are built into MacOS, so no install.

# Add upgrade parameter in the command line:
#    ./mac-git-install.sh upgrade
