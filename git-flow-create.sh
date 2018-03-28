#!/bin/bash
# ./git-flow-create.sh
# Written by Wilson Mar (wilsonmar@gmail.com)
# This creates the conditions for testing Michael Haggerty's "git imerge",
# as described in https://wilsonmar.github.io/git-flow
# cd 

# Before running this, copy this file to the folder where you want the test repo created,
# then chmod 555 git-imerge-test-create.sh
# Running this creates a folder above the script folder
# and creates a file named somefile.txt in both the master branch and "branch1" branch.
# This file is in https://github.com/wilsonmar/git-utilities/git-imerge-test-create.sh
# Also see https://jonathanmh.com/how-to-create-a-git-merge-conflict/
# https://github.com/cirosantilli/test-git-conflict
# uses ruby printf statements to generate file content.

echo "## Navigating to working folder:"
cd ~/gits/hotwilson
pwd
echo "## Deleting .git and files from previous run:"
rm -rf git-utilities
exit
#echo "## This hangs if no internet is available:"
#git clone https://github.com/wilsonmar/git-utilities
#cd git-utilities
#git branch -avv
# git checkout master
git checkout -b feat1
echo "more stuff">>README.md
git status
git add README.md -A
git commit -m"Update for show"
git log --graph --oneline
git reflog
exit

git push
git tag v1.3.4
git push --tags

git remote add upstream https://github.com/wilsonmar/git-utilities
# git pull --rebase
git config --global pull.rebase true
git fetch upstream
git checkout master
# git difftool
git merge upstream/master
cat README.md

git request-pull v1.0 https://github.com/upstream/sisters  master

echo "## Working upstream:"
git fetch --dry-run
exit
git log ^master origin/master
git fetch upstream
git checkout master
#git pull --rebase --autostash
git merge upstream/master
cat README.md
#git push -u origin master
git config --global alias.up '!git fetch && git rebase --autostash FETCH_HEAD'
git up

