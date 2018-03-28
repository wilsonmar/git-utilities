#!/usr/bin/env bash

# git-sisters-update.sh from within http://github.com/wilsonmar/git-utilities.
# by Wilson Mar (wilsonmar@gmail.com, @wilsonmar)

# This script was created for experiementing and learning Git.
# Git commands in this script are meant as examples for manual entry
# explained during my live "Git and GitHub" tutorials and
# explained at https://wilsonmar.github.io/git-commands-and-statuses/).
# Most of the regularly used Git commands are covered here.

# This script clones and edits a sample repo with known history.

# This script is designed to be "idempotent" in that repeat runs
# begin by deleting what was created: the local repo and repo in GitHub.

# Sample call in MacOS Terminal shell window:
# chmod +x git-sisters-update.sh
# ./git-sisters-update.sh

# Last tested on MacOS 10.11 (El Capitan) 2015-09-15
# TODO: Create a PowerShell script that works on Windows:
# git-sisters-update.ps1

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

# Create blank lines in the log to differentiate different runs:
        echo ""
        echo ""
        echo ""
        echo ""
        echo ""
           # Make the beginning of run easy to find:
        echo "**********************************************************"
  TZ=":UTC" date +%z
  NOW=$(date +%Y-%m-%d:%H:%M:%S%z)
           # 2016-09-16T05:26-06:00 vs UTC

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
        echo "******** Script from $DIR"

        echo "******** $NOW "
# After "brew install git" on Mac:
git --version


# exit #1

        echo "******** Load secrets file :"
   # Change the name of your secrets file and edit the file:
          SECRETS_FILEPATH="~/.secrets"
if [ -f ${SECRETS_FILEPATH} ]; then
   source ${SECRETS_FILEPATH} # load into   env vars 
   echo "******** GITHUB_USER=$GITHUB_USER - $USER";
else
   echo "File at ${SECRETS_FILEPATH} not found."
   GITHUB_USER="wilson-jetbloom"
   GITHUB_USER_EMAIL="wilsonmar@jetbloom.com"
   GITHUB_USER_NAME="Wilson Mar"
fi

    # Check if variable is available:
if [ -z ${GITHUB_USER+x} ]; then 
   echo "******** GITHUB_USER=$GITHUB_USER : success.";
else 
   GITHUB_USER="wilson-jetbloom"
   echo "******** GITHUB_USER=$GITHUB_USER : default."
fi

# TODO: Check for existance of environment variable:

    # See https://git-scm.com/docs/pretty-formats :
#git config user.email $GITHUB_USER_EMAIL # "hotmar@gmail.com"
#git config user.name  $GITHUB_USER_NAME  # "Wilson Mar" # Username (not email) in GitHub.com cloud.
#git config user.user  $GITHUB_USER       # Username (not email) in GitHub.com cloud.
    #GITHUB_USER=$(git config github.email)  # Username (not email) in GitHub.com cloud.
# echo "GITHUB_USER_EMAIL= $GITHUB_USER_EMAIL" # FIXME: Returns blank.
# echo $GIT_AUTHOR_EMAIL
# echo $GIT_COMMITTER_EMAIL

     # After gpg is installed and # gpg --gen-key:
#git config --global user.signingkey $GITHUB_SIGNING_KEY
# gpg --list-keys


   # TODO: Add handling of script call attribute containing REPONAME and GITHUB_USER:
  REPONAME='sisters'
  DESCRIPTION="Automated Git repo from run using $REPONAME."
  UPSTREAM="https://github.com/hotwilson/sisters"

# exit #2

        echo "******** Delete \"$REPONAME\" remaining from previous run (for idempotent script):"
    # Remove folder if exists (no symbolic links are used here):
if [[ -d ${REPONAME} ]]; then
   rm -rf ${REPONAME}
fi

    # (No need to create a folder as that's what git clone does:)
# mkdir ${REPONAME}
    # cd ${REPONAME} happens later on.


        echo "******** git clone sisters from GitHub over the internet: "
         # Hard-coded to use a repo prepared for the class:
git clone ${UPSTREAM}.git  ${REPONAME} # --depth=1
    # size of folder in KiloBytes (Linux command):
    du -hs ${REPONAME}

# exit #3

        echo "******** Ensure \"$REPONAME\" folder is in .gitignore file:"
   # -F for fixed-strings, -x to match whole line, -q for quiet (not show text sought)
if grep -Fxq "${REPONAME}" .gitignore ; then
   echo "\"${REPONAME}\" FOUND within .gitignore file."
else
   echo "${REPONAME}">>.gitignore
    #  sed 's/fields/fields\nNew Inserted Line/' .gitignore
   echo "${REPONAME} added to bottom of .gitignore file."
fi
# exit #4



        echo "******** Configure Git repo :"
# TODO: Create separate shell file to define git aliases for repo.
# Verify settings:
git config core.filemode false
git config core.autocrlf input
git config core.safecrlf true

# On Unix systems, ignore ^M symbols created by Windows:
# git config core.whitespace cr-at-eol

# Change default commit message editor program to Sublime Text (instead of vi):
git config core.editor "~/Sublime\ Text\ 3/sublime_text -w"

# Allow all Git commands to use colored output, if possible:
git config color.ui auto

# See https://git-scm.com/docs/pretty-formats : Add "| %G?" for signing
# In Windows, double quotes are needed:
git config alias.l  "log --pretty='%Cred%h%Creset %C(yellow)%d%Creset | %Cblue%s%Creset' --graph"

git config alias.s  "status -s"
#it config alias.w "show -s --quiet --pretty=format:'%Cred%h%Creset | %Cblue%s%Creset | (%cr) %Cgreen<%ae>%Creset'"
git config alias.w  "show -s --quiet --pretty=format:'%Cred%h%Creset | %Cblue%s%Creset'"
git config alias.ca "commit -a --amend -C HEAD" # (with no message)

# Have git diff use mnemonic prefixes (index, work tree, commit, object) instead of standard a and b notation:
git config diff.mnemonicprefix true

# Save & Reuse Recorded Resolution of conflicted merges - https://git-scm.com/docs/git-rerere
git config rerere.enabled false

# git config --list   # Dump config file

 # exit #5

         echo "******** git remote add upstream :"
git remote add upstream ${UPSTREAM} 
         echo "******** git remote -v : locations :"
git remote -v
         echo "******** git remote show origin :"
git remote show origin

# exit #6


         echo "******** git branch -avv :"
git branch -avv

#         echo "******** cat .git/HEAD to show internal branch:"
# The contents of HEAD is stored in this file:
#cat .git/HEAD

# exit #7

         echo "******** git show --oneline --abbrev-commit"
# git show --oneline --abbrev-commit -l 1
         echo "******** cd into ${REPONAME} "
cd ${REPONAME}
   pwd

cat ${REPONAME}/bebe.md

  exit #8

         echo "******** tree of folders:"
tree
         echo "******** git log --oneline:"
git log --oneline
         echo "******** git reflog : baseline of git actions"
git reflog

#  exit #9

         echo "******** git blame ${REPONAME}/bebe.md"
git blame ${REPONAME}/bebe.md

  exit #10

#        echo "******** Begin trace :"
#    # Do not set trace on:
#    set -x  # xtrace command         echo on (with ++ prefix). http://www.faqs.org/docs/abs/HTML/options.html

#        echo "******** Define default branch :"
    # Change from default "ref: refs/heads/master" :
    # See http://www.kernel.org/pub/software/scm/git/docs/git-symbolic-ref.html
# DEFAULT_BRANCH="master"
# git symbolic-ref HEAD refs/heads/$DEFAULT_BRANCH
#cat .git/HEAD
#git branch -avv

        echo "******** checkout new branch feature1 from master branch :"
git checkout master
git checkout -b feature1 
git branch -avv

# exit #11


        echo "******** git checkout ea2db2c :"
git checkout ea2db2c

  exit #5
        echo "******** git reset --soft ea2db2c (to remove it):"
git reset --soft ea2db2c
        echo "******** git fsck:"
git fsck
        echo "******** Make changes to files and stage it :"

   exit #5

echo "change 1">>bebe.md
git add bebe.md
        echo "******** git reset --mixed HEAD :"
git reset HEAD
        echo "******** git reset --mixed HEAD :"
git reset HEAD
        echo "******** git reset --hard a874ef2 :"
git reset --hard a874ef2

   exit #6
        echo "******** $NOW end."
