#!/bin/bash
# Sample file .secrets.sh in https://github.com/wilsonmar/git-utilities
# referenced by mac-git-install.sh also in https://github.com/wilsonmar/git-utilities
# This file name .secrets.sh should be specified in .gitignore so 
#    it doesn't upload to a public GitHub/BitBucket, etc.
# Command source .secrets.sh pull these variables in.
# CAUTION: No spaces around = sign.
GIT_NAME="Wilson Mar"
GIT_ID="WilsonMar@gmail.com"
GIT_EMAIL="WilsonMar+GitHub@gmail.com"
GIT_USERNAME="hotwilson"
GPG_PASSPHRASE="only you know this 2 well"
GITHUB_ACCOUNT="hotwilson"
GITHUB_PASSWORD="change this to your GitHub account password"
# The last one in a list is the Git default:
GIT_CLIENT="git"
          # git, cola, github, gitkraken, smartgit, sourcetree, tower, magit, gitup. 
GIT_EDITOR="sublime"
          # nano, pico, vim, sublime, code, atom, macvim, textmate, emacs, intellij, sts, eclipse.
          # NOTE: nano and vim are built into MacOS, so no install.
CLOUD="gcp"
     # none, aws, gcp"

# To upgrade, add upgrade parameter in the command line:
#    ./mac-git-install.sh upgrade
