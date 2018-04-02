#!/bin/bash
# Sample file .secrets.sh in https://github.com/wilsonmar/git-utilities
# referenced by mac-git-install.sh also in https://github.com/wilsonmar/git-utilities
# This file name .secrets.sh should be specified in .gitignore so 
#    it doesn't upload to a public GitHub/BitBucket, etc.
# Command source .secrets.sh pull these variables in:
# CAUTION: No spaces around = sign.
GIT_NAME="Wilson Mar"
GIT_ID="WilsonMar@gmail.com"
GIT_EMAIL="WilsonMar+GitHub@gmail.com"
GIT_USERNAME="hotwilson"
GPG_PASSPHRASE="only you know this 2 well"
GITHUB_ACCOUNT="hotwilson"
GITHUB_PASSWORD="change this to your GitHub account password"
GITHUB_REPO="sample"

# Lists can be specified below. The last one in a list is the Git default:
GIT_BROWSER="firefox"
           # chrome, firefox, brave
GIT_CLIENT="git"
          # git, cola, github, gitkraken, smartgit, sourcetree, tower, magit, gitup. 
GIT_EDITOR="vim"
          # atom, code, eclipse, emacs, intellij, macvim, nano, pico, sts, sublime, textmate, textedit, vim
          # NOTE: pico, nano, and vim are built into MacOS, so no install.
CLOUD="azure"
     # none, aws, gcp, azure"
GIT_LANG="python"
        # python, java, go
GUI_TEST="selenium"
        # selenium, sikulix
        # Drivers for scripting language depend on what is defined in $GIT_LANG.

# To upgrade, add parameter in the command line:
#    ./mac-git-install.sh upgrade
