#!/usr/bin/env bash

# git-sample-repo-create.sh from within http://github.com/wilsonmar/git-utilities.
# by Wilson Mar (wilsonmar@gmail.com
# This creates and populates a sample repo for my "Git and GitHub" tutorial,
# Explained at https://wilsonmar.github.io/git-commands-and-statuses/)

# Sample call in MacOS Terminal shell window:
# chmod +x git-sample-repo-create.sh
# ./git-sample-repo-create.sh

# Tested on MacOS 10.11 (El Capitan)
# TODO: Get a version that works on Windows

TMP='git-sample-repo'
# clear
echo ""
echo ""
echo ""
echo ""
echo ""
# Make the beginning of run easy to find:
echo "**********************************************************"
echo "******** STEP Delete \"$TMP\" remnant from previous run:"
rm -rf ${TMP}
mkdir ${TMP}
cd ${TMP}

echo "******** Git version :"
# After "brew install git" on Mac:
git --version

echo "******** STEP Init repo :"
# init without --bare so we get a working directory:
git init
# return the .git path of the current project::
git rev-parse --git-dir
ls .git/

echo "******** STEP Make develop the default branch instead of master :"
# The contents of HEAD is stored in this file:
cat .git/HEAD
# Change from default "ref: refs/heads/master" :
    # See http://www.kernel.org/pub/software/scm/git/docs/git-symbolic-ref.html
git symbolic-ref HEAD refs/heads/develop
cat .git/HEAD
git branch
DEFAULT_BRANCH="develop"
echo $DEFAULT_BRANCH

# When remote is used :
# git remote set-head origin develop
# git config branch.develop.remote origin
# git config branch.develop.merge refs/heads/develop

echo "******** STEP Config (not --global):"
# See https://git-scm.com/docs/pretty-formats :
git config user.name "Wilson Mar"
git config user.email "wilsonmar@gmail.com"
# echo $GIT_AUTHOR_EMAIL
# echo $GIT_COMMITTER_EMAIL

# Install gpg
# gpg --list-keys
# gpg --gen-key
git config --global user.signingkey 2E23C648

# Verify settings:
git config core.filemode false

# On Unix systems, ignore ^M symbols created by Windows:
# git config core.whitespace cr-at-eol

# Change default commit message editor program to Sublime Text (instead of vi):
git config core.editor "~/Sublime\ Text\ 3/sublime_text -w"

# Allow all Git commands to use colored output, if possible:
git config color.ui auto

# See https://git-scm.com/docs/pretty-formats :
# In Windows, double quotes are needed:
git config alias.l  "log --pretty='%Cred%h%Creset %C(yellow)%d%Creset | %Cblue%s%Creset | %G?' --graph"

git config alias.s  "status -s"
#it config alias.w "show -s --quiet --pretty=format:'%Cred%h%Creset | %Cblue%s%Creset | (%cr) %Cgreen<%ae>%Creset'"
git config alias.w  "show -s --quiet --pretty=format:'%Cred%h%Creset | %Cblue%s%Creset'"
git config alias.ca "commit -a --amend -C HEAD" # (with no message)

# Have git diff use mnemonic prefixes (index, work tree, commit, object) instead of standard a and b notation:
git config diff.mnemonicprefix true

# Reuse recorded resolution of conflicted merges - https://git-scm.com/docs/git-rerere
git config rerere.enabled false

# git config --list   # Dump config file

echo "******** STEP commit (initial) README :"
touch README.md
git add .
git commit -m "README.md"
git l -1

echo "******** STEP amend commit README : "
# ammend last commit with all uncommitted and un-staged changes:
echo "some more">>README.md
# Instead of git commit -a --amend -C HEAD
git ca  # use this alias instead.
git l -1

echo "******** STEP amend commit 2 : "
# ammend last commit with all uncommitted and un-staged changes:
echo "still more">>README.md
git ca  # alias for git commit -a --amend -C HEAD
git l -1

echo "******** STEP commit b - .gitignore :"
echo ".DS_Store">>.gitignore
git add .
git commit -m "Add .gitignore"
git l -1
git reflog
ls -al
cat README.md

echo "******** STEP tag :"
# git tag v0.0.1 -m"v1 unsigned"
  git tag v0.0.1 -m"v1 signed" -s
   # For numbering, see http://semver.org/
# echo "******** STEP tag verify :"
# git tag -v v1  # calls verify-tag.
git verify-tag v0.0.1

# echo "******** STEP tag show :"
# git show v1  # Press q to exit scroll.

echo "******** STEP checkout create feature1 branch : --------------------------"
git checkout v0.0.1 -b feature1
# git branch
ls .git/refs/heads/
git l -1

echo "******** STEP commit c - LICENSE.md : "
echo "MIT">>LICENSE.md
git add .
git commit -m "Add c"
git l -1
ls -al

echo "******** STEP commit: d"
echo "free!">>LICENSE.md
echo "d">>file-d.txt
git add .
git commit -m "Add d in feature1"
git l -1
ls -al

echo "******** STEP Merge feature1 :"
# Instead of git checkout $DEFAULT_BRANCH :
git checkout @{-1}  # checkout previous branch (develop, master)

# Alternately, use git-m.sh to merge and delete in one step.
# git merge --no-ff (no fast forward) for "true merge":
#git merge feature1 --no-ff --no-commit  # to see what may happen
git merge feature1 -m "merge feature1" --no-ff  # --verify-signatures 
# resolve conflicts here?
git add .
# git commit -m "commit merge feature1"
git branch
git l -1

echo "******** $NOW Remove merged branch ref :"
git branch -D feature1
git branch
echo "******** $NOW What's dangling? "
git fsck --dangling --no-progress
git l -1

echo "******** STEP commit: e"
echo "e">>file-e.txt
git add .
git commit -m "Add e"
git l -1

echo "******** STEP commit: f"
echo "f">>file-f.txt
ls -al
git add .
git commit -m "Add f"
git l -1


echo "Copy this and paste to a text edit for reference: --------------"
git l
echo "******** show HEAD : ---------------------------------------"
git w HEAD
echo "******** show HEAD~1 :"
git w HEAD~1
echo "******** show HEAD~2 :"
git w HEAD~2
echo "******** show HEAD~3 :"
git w HEAD~3
echo "******** show HEAD~4 :"
git w HEAD~4

echo "******** show HEAD^ :"
git w HEAD^
echo "******** show HEAD^^ :"
git w HEAD^^
echo "******** show HEAD^^^ :"
git w HEAD^^^
echo "******** show HEAD^^^^ :"
git w HEAD^^^^

echo "******** show HEAD^1 :"
git w HEAD^1
echo "******** show HEAD^2 :"
git w HEAD^2

echo "******** show HEAD~1^1 :"
git w HEAD~1^1
echo "******** show HEAD~2^1 :"
git w HEAD~2^1
echo "******** show HEAD~3^1 :"
git w HEAD~3^1

echo "******** show HEAD~1^2 :"
git w HEAD~1^2

echo "******** show HEAD~2^2 :"
git w HEAD~2^2
echo "******** show HEAD~2^3 :"
git w HEAD~2^3

echo "******** show HEAD@{5} :"
git w HEAD@{5}


# exit

echo "******** Reflog: ---------------------------------------"
git reflog
ls -al

echo "******** Create archive file, excluding .git directory :"
NOW=$(date +%Y-%m-%d:%H:%M:%S-MT)
FILENAME=$(echo ${TMP}_${NOW}.zip)
echo $FILENAME
# Commented out to avoid creating a file from each run:
# git archive --format zip --output ../$FILENAME  feature1
# ls -l ../$FILENAME


echo "******** checkout c :"
ls -al
git show HEAD@{5}
git checkout HEAD@{5}
ls -al
git reflog

echo "******** checkout previous HEAD :"
git checkout HEAD
ls -al



# git stash save "text message here"
# git reset --hard ... 

# git stash list /* shows whats in stash */
# git stash show -p stash@{0} /* Show the diff in the stash */

# git stash pop stash@{0} /*  restores the stash deletes the tash */
# git stash apply stash@{0} /*  restores the stash and keeps the stash */
# git stash drop stash@{0}
# git stash clear /*  removes all stash */


# git reset --hard feature1^

# Undo last commit, preserving local changes:
# git reset --soft HEAD~1

# Undo last commit, without preserving local changes:
# git reset --hard HEAD~1

# Undo last commit, preserving local changes in index:
# git reset --mixed HEAD~1

# Undo non-pushed commits:
# git reset origin/$DEFAULT_BRANCH


#     Revert a range of the last two commits:
# git revert HEAD~2..HEAD
# Create several revert commits:
# git revert a867b4af 25eee4ca 0766c053

# Reverting a merge commit
# git revert -m 1 <merge_commit_sha>
# See http://git-scm.com/blog/2010/03/02/undoing-merges.html


# From https://www.youtube.com/watch?v=sevc6668cQ0&t=41m40s
# git rebase master --exec "make test"

# echo "******** Bisect loop : "
# for loop:
#     git bisect start
#     git bisect good master
#     git bisect run make test
# end loop

# echo "******** Remote commands : "
# git fetch origin
# git reset --hard origin/$DEFAULT_BRANCH

# echo "******** Cover your tracks:"
# Remove from repository all locally deleted files:
# git rm $(git ls-files --deleted)

# Move the branch pointer back to the previous HEAD:
# git reset --soft HEAD@{1}

# Commented out for cleanup at start of next run:
# cd ..
# rm -rf ${TMP}

echo "******** $NOW end."
