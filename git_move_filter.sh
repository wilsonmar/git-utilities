#!/usr/bin/env bash

# git_move_filter.sh in http://github.com/wilsonmar/git-utilities
# Example: after chmod 777 git_move_filter.sh
# ./git_move_history.sh /Users/wmar/gits/wilsonmar/SampleB/folderB1 /Users/wmar/gits/wilsonmar/SampleA/folderB1 /Users/wmar/gits/wilsonmar/SampleA/folderB1.patch

# From Michael:
function gg ()
{
   local _gg="$1";
   shift;
   git --git-dir="${_gg}/.git" --work-tree="${_gg}" "$@"
}

### Get "directory 1" within repository A ready to move

now=$(date)
repoA='https://github.com/wilsonmar/SampleA' # from
repoB='https://github.com/wilsonmar/SampleB' # destination
repoB_folder="SampleB"
folderA1='SampleA-folder1' # from
dest_folder='SampleA-folder3' #destination
clone_folder='__git_clone_repo__'
git status # don't continue unless there is a clean slate.
echo "*** User=$user, repoA=$repoA, repoB=$repoB, at $now."

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
echo "*** Running from script_dir=$SCRIPT_DIR"

echo "*** STEP 01: Get to the local working folder ready to receive the clone:"
cd ~
rm -rf temp
mkdir temp
cd temp

echo "*** STEP 02: Clone the originating repo you want to split to your local machine, specifying the branch:"
git clone $repoA $clone_folder # Create folder from Github
cd $clone_folder
dir=`pwd` # put results of pwd command into variable dir.
echo "*** dir=$dir"


echo "*** STEP 03: List files caz the next action promotes files in the directory up to the project root level:"
ls -al

echo "*** STEP 04: Avoid accidentally pushing changes by deleting the upstream repository definition in github:"
git remote -v
git remote rm origin

echo "After this step, the local repo must be reset again using ./git_move_setup.sh."
echo "*** STEP 05: Filter out all files except the one you want and at the same time "
git filter-branch --prune-empty --subdirectory-filter $folderA1 -- --all
#   The `--prune-empty` with `git filter-branch` brings over commits from **ONLY** the other repo which involves the directory being moved.
#   The official doc at https://git-scm.com/docs/git-filter-branch
#   describes git filter-branch as rewrite revision history what is specifically mentioned after `--subdirectory-filter`.
#   The `–-` (two dashes) separates paths from revisions.
#   An example of the response (where "directory 1" is replaced with your folder name):
ls -al

echo "*** STEP 06: Move contents of file raised to root back into a destination directory:"
mkdir -p $dest_folder
# TODO: Move more than just .txt files we know:
find . -type f -exec git mv {} $dest_folder \;
# git mv *.txt $dest_folder # As in git mv *  SampleA-folder1 but cannot move a directory into itself.
pwd
ls -al
# git remote -v returns nothing here.

echo "*** STEP 07: Commit to Github:"
git add .
git commit -m"Move $folderA1 to $dest_folder in repo"

echo "*** STEP 08: Clone the destination repo into ~/temp:"
cd ~
cd temp
rm -rf $repoB_folder
git clone $repoB $repoB_folder # Create folder from Github
cd $repoB_folder
pwd

echo "*** STEP 09: Add _git_clone_repo_ as a location to pull from:"
echo "${repoA}"
git remote add repoA-branch ~/temp/${clone_folder}
mkdir ~/temp/${repoB_folder}/${dest_folder}
cd ${dest_folder}

echo "*** STEP 10: Reset --hard to remove and avoid vim coming up:"
cd ~/temp/${repoB_folder}
pwd
git reset --hard

git pull       repoA-branch master

git remote rm  repoA-branch

echo "*** STEP 11: Commit to Github:"
git add .
git commit -m"Move ${folderA1} in ${repoA} to ${repoB}."
git remote -v
