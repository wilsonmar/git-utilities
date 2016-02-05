#!/usr/bin/env bash
# git_move_setup.sh from within http://github.com/wilsonmar/git-utilities.
# This populates repos to verify script git_move.sh in the same repo.
# Repeated runs add a line with date stamp to each file, which adds to git's update history.

# Before running this script:
# This assumes that repos have already been setup:
#    http://github.com/wilsonmar/SampleA
#    http://github.com/wilsonmar/SampleB

# Sample call:
# ./git_move_setup.sh wilsonmar

# TODO: Remove folders - reset the repo.
# TODO: Generalize folder names so others can use this.


## My standard starter. 
# Set exit logic. Read: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail 
IFS=$'\n\t'
# Log to syslog:
exec 1> >(logger -s -t $(basename $0)) 2>&1
# Standard System Variables:
NOW=$(date)
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SYSTEM=${OSTYPE//[0-9.]/}
HNAME=$(hostname)
SCRIPT="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
echo "*** SYSTEM=${SYSTEM}, HNAME=${HNAME}."
echo "*** SCRIPT=${SCRIPT}, NOW=${NOW}."
echo "*** Run from DIR=${DIR}."
# To use gg command in place of git (From Michael Hill):
function gg ()
{
   local _gg="$1";
   shift;
   git --git-dir="${_gg}/.git" --work-tree="${_gg}" "$@"
}

# Setup temporary work folder:
TMP='/tmp/git_move_setup'
rm -Rf ${TMP}
mkdir ${TMP}
echo "*** Working folder TMP=${TMP}."

## Initialize variables just for this script:
user='wilsonmar'
echo "*** USER=${user}."

exit 1

#### Phase A:
rm -rf SampleA
git clone https://github.com/$user/SampleA SampleA # Create folder from Github
cd SampleA
dir=`pwd` # put results of pwd command into variable dir.
echo "*** pwd=$dir"
rm -rf . # remove all folders and files
#mkdir SampleA && cd SampleA
#git init
mkdir folderA1 # for first time.
cd folderA1 # folder may exist or not.
echo fileA1a $NOW >>fileA1a.txt # >> concatenates line to bottom of file.
echo fileA1b $NOW >>fileA1b.txt
cd $dir
pwd
mkdir folderA2 
cd folderA2
echo fileA2a $NOW >>fileA2a.txt
echo fileA2b $NOW >>fileA2b.txt
cd $dir
pwd
git add . -A # including deletes
git status
git commit -m"Add SampleA and SampleB $NOW"

git remote -v
git push -u origin master
echo "*** $NOW should appear in commit comment at https://github.com/$user/SampleA"




#### Phase B: ####
cd /Users/wmar/gits/$user
#git remote add origin https://github.com/wilsonmar/SampleB
rm -rf SampleB
git clone https://github.com/$user/SampleB SampleB # Create folder from Github
cd SampleB
dir=`pwd`
echo "*** pwd=$dir"
rm -rf . # remove all folders and files
#mkdir SampleB && cd SampleB
#git init
mkdir folderB1 
cd folderB1
echo fileB1a $NOW >>fileB1a.txt
echo fileB1b $NOW >>fileB1b.txt
cd $dir
pwd
mkdir folderB2 
cd folderB2
echo fileB2a $NOW >>fileB2a.txt
echo fileB2b $NOW >>fileB2b.txt
cd $dir
pwd
git add . -A # including deletes
git status
git commit -m"Add SampleA and SampleB $NOW"

git remote -v
git push -u origin master
echo "*** $NOW should appear in commit comment at https://github.com/$user/SampleB"


