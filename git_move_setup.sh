# git_move_setup.sh
# run with parameter Github user from
# m
# /Users/wmar/gits/wilsonmar/git_utilities/git_move_setup.sh
# chdmod 777 git_move_setup.sh
# ./git_move_setup.sh  wilsonmar
now=$(date)
echo "first parameter is $1 at $now"
# To prevent who repos being wiped out by blank options:
if [ $# -lt 1 ] ; then
echo "**** $0 cancelled because no <user> was specified. (ie, where <user>=wilsonmar)"
exit
fi
#### Phase A:
cd /Users/wmar/gits/$1
pwd # NOTE: repo must be created before running this script.
#git remote add origin https://github.com/wilsonmar/SampleA
rm -rf SampleA
git clone https://github.com/wilsonmar/SampleA SampleA # Create folder from Github
cd SampleA
dir=`pwd`
rm -rf . # remove all folders and files
#mkdir SampleA && cd SampleA
#git init
mkdir folderA1 
cd folderA1
echo fileA1a $now >>fileA1a.txt
echo fileA1b $now >>fileA1b.txt
cd $dir
pwd
mkdir folderA2 
cd folderA2
echo fileA2a $now >>fileA2a.txt
echo fileA2b $now >>fileA2b.txt
cd $dir
pwd
#### Phase B:
cd /Users/wmar/gits/$1
#git remote add origin https://github.com/wilsonmar/SampleB
rm -rf SampleB
git clone https://github.com/wilsonmar/SampleB SampleB # Create folder from Github
cd SampleB
dir=`pwd`
rm -rf . # remove all folders and files
#mkdir SampleB && cd SampleB
#git init
mkdir folderB1 
cd folderB1
echo fileB1a $now >>fileB1a.txt
echo fileB1b $now >>fileB1b.txt
cd $dir
pwd
mkdir folderB2 
cd folderB2
echo fileB2a $now >>fileB2a.txt
echo fileB2b $now >>fileB2b.txt
cd $dir
pwd

git add . -A # including deletes
git status
git commit -m"Add SampleA and SampleB $now"
# merge
git remote -v
git push -u origin master
echo "$now FINISHED."