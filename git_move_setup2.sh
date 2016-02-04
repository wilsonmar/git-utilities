# git_move_setup.sh from within http://github.com/wilsonmar/git-utilities.
# This populates repos to verify script git_move.sh in the same repo.
# This assumes that repos have already been setup:
#    http://github.com/wilsonmar/$repoA
#    http://github.com/wilsonmar/$repoB
# TODO: Remove folders - reset the repo.
# TODO: Generalize folder names so others can use this.
# Sample call:
# ./git_move_setup.sh wilsonmar
# Repeated runs add a line with date stamp to each file, which adds to git's update history.
#
this_module='git_move_setup.sh'
now=$(date)
user='wilsonmar'
repoA='SampleA'
repoB='SampleB'
echo "*** User=$user, repoA=$repoA, repoB=$repoB, at $now."

#### Phase A:
cd /Users/wmar/gits/$user
pwd # NOTE: repo must be created before running this script.
#git remote add origin https://github.com/wilsonmar/$repoA
# 
rm -rf $repoA
git clone https://github.com/$user/$repoA $repoA # Create folder from Github
cd $repoA
dir=`pwd` # put results of pwd command into variable dir.
echo "*** pwd=$dir"
rm -rf . # remove all folders and files
#mkdir $repoA && cd $repoA
#git init
mkdir $repoA-folder1 # for first time.
