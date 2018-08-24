#!/bin/bash
# This is git-basics.sh from https://github.com/wilsonmar/git-utilities
# Described in https://wilsonmar.github.io/git-basics
# This script performs the most common actions resulting in the various statuses,
# so you can make changes and see the effect.
# Remember to chmod +x git-basics.sh first, then paste this command in your terminal
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/git-utilities/master/git-basics.sh)" whatever

clear
echo -e "\n>>>"
echo -e "\n>>>"
echo -e "\n>>>"

            WORKING_FOLDER="$1"  # from 1st argument
if [[ -z "${WORKING_FOLDER// }"  ]]; then  #it's blank so assign default:
            WORKING_FOLDER="git_repo"
fi
cd ~/
rm -rf $WORKING_FOLDER
mkdir  $WORKING_FOLDER
   cd  $WORKING_FOLDER
echo -e "\n>>> 1. git init in $PWD:"
git init  # to initialized empty repository

echo -e "\n>>> 2. First commit of README.md and .gitignore:"
echo "#git-basics.sh">README.md
echo "amy">.gitignore
git add .
git commit -m"First commit of README.md and .gitignore"

MSG="3. I'm Amy. I get ignored."
echo -e "\n>>> $MSG"
echo $MSG>amy

MSG="4. I'm Bob. I never go anywhere and stay untracked."
echo -e "\n>>> $MSG"
echo $MSG>bob

MSG="5. I'm Chris. I visit the Index."
echo -e "\n>>> $MSG"
echo $MSG>chris
git add chris

MSG="6. I'm Don. I got commited once."
echo -e "\n>>> $MSG"
echo $MSG>don
git add don
git commit -m"initial don. Second commit."
echo ">>> NOTE: chris and don got committed together."

MSG="7. I'm Ed. I escape from commitment by being edited."
echo -e "\n>>> $MSG"
echo $MSG>ed
git add ed
git commit -m "initial ed. Third commit."
echo "Now I'm outside." >>ed  # concatenated.

MSG="8. I'm Finn. I escaped but got added back, but not committed."
echo -e "\n>>> $MSG"
echo $MSG>finn
git add finn
git commit -m"initial finn. Fourth commit."
echo "Now I'm outside." >>finn
git add finn

echo -e "\n>>> cat finn"
cat finn

MSG="9. I'm George. I got committed twice."
echo -e "\n>>> $MSG"
echo $MSG>george
git add george
git commit -m"initial george. Fifth commit."
echo "Now I'm outside." >>george
git add george
git commit -m"so george rises again. Sixth commit."

MSG="10. I'm Harry. I just joined late."
echo -e "\n>>> $MSG"
echo $MSG>harry

echo -e "\n>>> Listing files in folder $WORKING_FOLDER :"
ls -a
echo -e "\n>>> Git status -s -b:"
git status -s -b
echo ">>> NOTE: Ignored (amy) and Committed files (chris, don, ed, finn, george) don't appear on status."

echo -e "\n>>> git log after initial commits:"
git log --pretty=format:"%h %s %ad" --graph --since=1.days --date=relative
echo -e "\n>>> git reflog (of git actions) after initial commits:"
git reflog

echo -e "\n>>> 11. git checkout HEAD@{4} attempt:"
git checkout HEAD@{4}

echo -e "\n>>> 12a. git stash:"
git stash save "working on new Harry."
echo -e "\n>>> 12b. git stash list:"
git stash list
echo -e "\n>>> 12c. git stash show:"
git stash show
echo ">>> NOTE: Untracked files get stashed only when --untracked is specified on git stash."

echo -e "\n>>> Listing files again in folder $WORKING_FOLDER before going back in time:"
ls -a
echo -e "\n>>> 13. git checkout HEAD@{4} when Don was committed:"
git checkout HEAD@{4}
echo -e "\n>>> Git reflog after checkout HEAD@{4}:"
git reflog -n 3
echo -e "\n>>> Listing files in folder $WORKING_FOLDER after checkout:"
ls -a
echo ">>> NOTE: finn, george wasn't committed yet."

echo -e "\n>>> Git status -s -b after checkout:"
git status -s -b
echo ">>> NOTE: Untracked files still there on the sidelines."

echo -e "\n>>> 14. git checkout back to master:"
git checkout master
echo -e "\n>>> Git reflog after checkout master:"
git reflog -n 3
echo -e "\n>>> Listing files in folder $WORKING_FOLDER :"
ls -al
echo ">>> NOTE: The whole gang is back together."

exit

echo -e "\n>>> 15. New branch AddIngrid:"
git checkout -b Add-Ingrid
echo -e "\n>>> Git reflog:"
git reflog -n 5
