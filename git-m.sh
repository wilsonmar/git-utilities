#!/bin/bash -x
# shell script named git-m
# From http://stackoverflow.com/questions/3321492/git-alias-with-positional-parameters
set -e

#by naming this git-m and putting it in your PATH, git will be able to run it when you type "git m ..."

if [ "$#" -ne 2 ]
then
  echo "Wrong number of arguments. Should be 2, was $#";
  exit 1;
fi

git checkout $1;
git merge --ff-only $2;
git branch -d $2;