#!/usr/bin/env bash

# git_move_history.sh in http://github.com/wilsonmar/git-utilities
# Example: after chmod 777 git_move_history.sh
# ./git_move_history.sh /Users/wmar/gits/wilsonmar/SampleB/folderB1 /Users/wmar/gits/wilsonmar/SampleA/folderB1 /Users/wmar/gits/wilsonmar/SampleA/folderB1.patch

now=$(date)

# To prevent repos being wiped out by running with blank options:
if [ $# -lt 3 ] ; then
echo "Usage: $0 $1=new_file_path $2=old_file_path $3=/tmp/new_file_path_history.patch"
exit
fi

# $1=new_file_path, $2=old_file_path, $3=/tmp/new_file_path_history.patch
# /Users/wmar/gits/wilsonmar/SampleB/folderB1 /Users/wmar/gits/wilsonmar/SampleA/folderB1 /Users/wmar/gits/wilsonmar/SampleA/folderB1.patch

git log –patch-with-stat –reverse –full-index –binary \ -- $1 $2 > $3

# Option: –pretty=email not used.

# http://git-scm.com/docs/git-log