#!/bin/bash
# ./git-imerge-test-create.sh
# Written by Wilson Mar (wilsonmar@gmail.com)
# This creates the conditions for testing Michael Haggerty's "git imerge",
# as described in https://wilsonmar.github.io/git-imerge 
#
# Before running this, copy this file to the folder where you want the test repo created,
# then chmod 555 git-imerge-test-create.sh
# Running this creates a folder above the script folder
# and creates a file named somefile.md in both the floob branch and "frob" branch.
# This file is in https://github.com/wilsonmar/git-utilities/git-imerge-test-create.sh


function conflict {  # $1=letter $2=cnt number
  x="$1$2"
  if [ $x = B2 ]||[ $x = G7 ]||[ $x = I9 ]; then 
  	commit "$x frob" $1 frob
  	commit "$x floob" $2 floob
  else
  	commit "$x" $1 frob
  	commit "$x" $2 floob
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

#echo "## Change directory up to avoid using git-utilities own repo:"
#cd ..
#mkdir $1
#cd $1

echo "## Deleting .git and somefile.md from previous run:"
rm -rf .git
rm somefile.md

echo "## Initializing repo with commit and branches:"
    git init
    touch somefile.md
	git add somefile.md
	git commit -m"0"
    git branch frob
    git branch floob
    git branch -avv

echo "## Generating commits in branches:"
letters=(A B C D E F G H I)  # array
cnt=1
for i in ${letters[@]}; do
  conflict $i $cnt  
  cnt=$((cnt+1))  # increment
done

echo "## Verifying contents of branch frob and file somefile.md:"
git log --pretty=format:"%h %s %ad" --graph --since=1.days --date=relative;
git checkout frob
cat somefile.md
echo "## Verifying contents of branch floob and file somefile.md:"
git log --pretty=format:"%h %s %ad" --graph --since=1.days --date=relative;
git checkout floob
cat somefile.md
git branch -avv
#ls -al
# You should now have:
#    0 - 1 - 2 - 3 - 4 - 5 - 6 - 7 - 8 - 9 - 10 - 11 '  ← floob
#     \                                               
#      A -- B -- C --- D --- E --- F --- G --- H --- I  ← branch
git checkout frob
git-imerge start --name=NAME --goal=full floob
git imerge diagram --name=NAME