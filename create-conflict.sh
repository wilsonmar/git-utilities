#!/bin/bash
# From https://gist.github.com/JonathanMH/397fc427842614dd4803
# Described in https://jonathanmh.com/how-to-create-a-git-merge-conflict/
mkdir git-repo
cd git-repo
git init
touch my_code.sh
git add my_code.sh
echo "echo Hello" > my_code.sh
git commit -am 'initial'
git checkout -b new_branch
echo "echo \"Hello World\"" > my_code.sh
git commit -am 'first commit on new_branch'
git checkout master
echo "echo \"Hello World!\"" > my_code.sh
git commit -am 'second commit on master'
git merge new_branch