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
echo "*** User=$user, repoA=$repoA, repoB=$repoB, at $now."

#. Clone the originating repo you want to split to your local machine, specifying the branch:

cd /Users/wmar/gits/$user # this will be different for others.
pwd # NOTE: repo must be created before running this script.
# 
rm -rf $repoA
git clone https://github.com/$user/$repoA $repoA # Create folder from Github
cd $repoA
dir=`pwd` # put results of pwd command into variable dir.
echo "*** pwd=$dir"
#git clone --branch <branch> --origin origin --progress -v <git repository A url>
 git clone --origin origin --progress -v https://github.com/$user/$repoA


