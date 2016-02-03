#!/usr/bin/env bash

# At https://github.com/wilsonmar/git-utilities/git_move.git
# (forked from https://gist.github.com/gregferrell/942639)

# Usage:
# 	./git_move.sh git@repo_site.com:/my_repo.git origin/folder/path/ /destination/repo/path/ new/folder/path/  

# To prevent who repos being wiped out by blank options:
if [ $# -lt 4 ] ; then
echo "Usage: $0 git@repo_site.com:/my_repo.git origin/folder/path/ /destination/repo/path/ new/folder/path/"
exit
fi

repo=$1
folder=$2
dest_repo=$3
dest_folder=$4
clone_folder='__git_clone_repo__'

echo 'cloning repo...'

#clone repo
git clone $repo $clone_folder

#move to new folder and get path for later
cd $clone_folder

#get old branch with no trailing slash
old_branch_path=`pwd | sed "s,/$,,"`

echo 'filtering branch...'

#removes everything but the folder we need
git filter-branch --subdirectory-filter $folder -- -- all

echo 'making destination folder...'

#make destination folder recursive
base=''
base_dest=''
count=0
IFS='/' read -ra ADDR <<< "$dest_folder"
for i in "${ADDR[@]}"; do 
	if [["$count" = "0"]]
	then
		base_dest=$i
	fi
	count=$(($count+1))
   	base=$base''$i'/'
	mkdir $base
done

echo 'moving files into destination folder in old repo...'

#move all one by one or it complains
for file in `ls`; do
	#move it all
	if [[ "$file" != "$base_dest" ]]
	then
		git mv $file $dest_folder
	fi
done

#commit to make the history work
git commit -m "removed all data but folder to move"

#move to destination _repo_ folder
cd $dest_repo


echo 'adding local remote to new repo...'

git remote add _repo_1 $old_branch_path

#fetch the remote source, create a branch and merge it with the destination repository in usual way
git fetch _repo_1
git branch _repo_1 remotes/_repo_1/master
git merge _repo_1

echo 'removing remote and dummy branch...'

git remote rm _repo_1
git branch -d _repo_1

echo 'cleaning up temp repo...'

chmod 0777 $old_branch_path
rm -r -f $old_branch_path

echo 'Done. Remeber to commit and push the changes to the destination branch.'