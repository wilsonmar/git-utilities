#!/usr/bin/env bash

# git_move_filter.sh in http://github.com/wilsonmar/git-utilities
# Example: after chmod 777 git_move_filter.sh
# ./git_move_history.sh /Users/wmar/gits/wilsonmar/SampleB/folderB1 /Users/wmar/gits/wilsonmar/SampleA/folderB1 /Users/wmar/gits/wilsonmar/SampleA/folderB1.patch

### Get "directory 1" within repository A ready to move

now=$(date)
user='wilsonmar'
repoA='SampleA'
repoB='SampleB'
folderA1='SampleA-folder1'
folderA2='SampleA-folder2'
folderB1='SampleB-folder1'
folderB2='SampleB-folder2'
dest_folder='SampleA-folder3'
echo "*** User=$user, repoA=$repoA, repoB=$repoB, at $now."
git status # don't continue unless there is a clean slate.

echo "STEP 01: Get to the local parent folder to receive the clone:"
cd /Users/wmar/gits/$user # this will be different for others.
pwd # NOTE: repo must be created before running this script.
# 
rm -rf $repoA

echo "STEP 02: Clone the originating repo you want to split to your local machine, specifying the branch:"
git clone https://github.com/$user/$repoA $repoA # Create folder from Github
cd $repoA
dir=`pwd` # put results of pwd command into variable dir.

echo "STEP 03: List files caz the next action promotes files in the directory up to the project root level:"
ls -al

echo "STEP 04: Avoid accidentally pushing changes by deleting the upstream repository definition in github:"
git remote -v
git remote rm origin

echo "After this step, the local repo must be reset again using ./git_move_setup.sh."
echo "STEP 05: Filter out all files except the one you want and at the same time "
git filter-branch --prune-empty --subdirectory-filter $folderA1 -- --all
#   The `--prune-empty` with `git filter-branch` brings over commits from **ONLY** the other repo which involves the directory being moved.
#   The official doc at https://git-scm.com/docs/git-filter-branch
#   describes git filter-branch as rewrite revision history what is specifically mentioned after `--subdirectory-filter`.
#   The `–-` (two dashes) separates paths from revisions.
#   An example of the response (where "directory 1" is replaced with your folder name):

echo "STEP 06: List files caz the previous action promotes files in the directory up to the project root level:"
ls -al

echo "STEP 07: Reset --hard:"
git reset --hard

echo "STEP 08: gc --aggressive:"
git gc --aggressive

echo "STEP 09: Prune:"
git prune

echo "STEP 10: Move contents of file raised to root back into a destination directory:"
mkdir -p $dest_folder
# TODO: Move more than just .txt files we know:
# find . -type f -exec mv {} $dest_folder \;
git mv *.txt $dest_folder # As in git mv *  SampleA-folder1 but cannot move a directory into itself.
ls -al

echo "STEP 11: Commit to Github:"
# git add .
# git commit -m"Move $folderA1 to $dest_folder in repo"

echo "STEP 12: Fetch the remote source, create a branch and merge it with the destination repo:"
#git fetch _repo_1
#git branch _repo_1 remotes/_repo_1/master
#git merge _repo_1

echo "STEP 13: Remove remote and dummy branch..."
#git remote rm _repo_1
#git branch -d _repo_1

echo "STEP 14: Clean up temp repo..."
# chmod 0777 $old_branch_path
#rm -r -f $old_branch_path
