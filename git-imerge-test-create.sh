#!/bin/bash
# Written by Wilson Mar (wilsonmar@gmail.com)
# This creates commits
# This file is in https://github.com/wilsonmar/git-utilities/git-imerge-test-create.sh

function conflict {  # $1=letter $2=cnt number
  x="$1$2"
  if [ $x = B2 ]||[ $x = G7 ]||[ $x = I9 ]; then 
  	commit "$x tlub" $1 tlub
  	commit "$x master" $2 master
  else
  	commit "$x" $1 tlub
  	commit "$x" $2 master
  fi
}

function commit {  # $1=content, $2=msg
  echo "## Committing $1 :"
	git checkout $3  # $3=branch
    echo $1>>somefile.md
	git add somefile.md
	git commit -m"$2"
    #git log --name-status HEAD^..HEAD  # TODO: show log of most recent commit
}

##########

echo "## Change directory up to avoid using git-utilities own repo:"
cd ..
mkdir $1
cd $1

echo "## Deleting .git and somefile.md from previous run:"
rm -rf .git
rm somefile.md

echo "## Initializing repo with commit and branches:"
    git init
    touch somefile.md
	git add somefile.md
	git commit -m"Initial commit somefile.md"
    git branch tlub
    git branch master
    git branch -avv

echo "## Generating commits in branches:"
letters=(A B C D E F G H I)  # array
cnt=1
for i in ${letters[@]}; do
  conflict $i $cnt  
  cnt=$((cnt+1))  # increment
done

echo "## Verifying contents of branch tlub and file somefile.md:"
git log --pretty=format:"%h %s %ad" --graph --since=1.days --date=relative;
git checkout tlub
cat somefile.md
echo "## Verifying contents of branch master and file somefile.md:"
git log --pretty=format:"%h %s %ad" --graph --since=1.days --date=relative;
git checkout master
cat somefile.md
#ls -al