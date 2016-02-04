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
localdir='/Users/wmar/gits/wilsonmar'
repoA='SampleA'
repoB='SampleB'
folderA1='SampleA-folder1'
folderA2='SampleA-folder2'
folderB1='SampleB-folder1'
folderB2='SampleB-folder2'
echo "*** User=$user, localdir=$localdir, repoA=$repoA, repoB=$repoB, at $now."

#### Phase A:
cd $localdir
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
mkdir $folderA1 # for first time. Subsequent runs ignored.
cd    $folderA1 # folder may exist or not.
echo fileA1a $now >>fileA1a.txt # >> concatenates line to bottom of file.
echo fileA1b $now >>fileA1b.txt
cd $dir
pwd
mkdir $folderA2
cd    $folderA2
echo fileA2a $now >>fileA2a.txt
echo fileA2b $now >>fileA2b.txt
cd $dir
pwd
git add . -A # including deletes
git status
git commit -m"Add $repoA and $repoB $now"

git remote -v
git push -u origin master
echo "*** $now should appear in commit comment at https://github.com/$user/$repoA"



#### Phase B: ####
cd $localdir
#git remote add origin https://github.com/wilsonmar/$repoB
rm -rf $repoB
git clone https://github.com/$user/$repoB $repoB # Create folder from Github
cd $repoB
dir=`pwd`
echo "*** pwd=$dir"
rm -rf . # remove all folders and files
#mkdir $repoB && cd $repoB
#git init
mkdir $folderB1
cd    $folderB1
echo fileB1a $now >>fileB1a.txt
echo fileB1b $now >>fileB1b.txt
cd $dir
pwd
mkdir $folderB2 
cd    $folderB2
echo fileB2a $now >>fileB2a.txt
echo fileB2b $now >>fileB2b.txt
cd $dir
pwd
git add . -A # including deletes
git status
git commit -m"Add $repoA and $repoB $now"

git remote -v
git push -u origin master
echo "*** $now should appear in commit comment at https://github.com/$user/$repoB"


