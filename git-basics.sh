#!/bin/bash
# This is git-basics.sh from https://github.com/wilsonmar/git-utilities
# Described in https://wilsonmar.github.io/git-basics
# This script performs the most common actions resulting in the various statuses,
# so you can make changes and see the effect.
# Remember to chmod +x git-basics.sh first, then paste this command in your terminal
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/git-utilities/master/git-basics.sh)"

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
   # Initialized empty Git repository in /Users/wilsonmar/git_repo/.git/

echo -e "\n>>> 2. First commit of README.md and .gitignore:"
echo "#git-basics.sh">README.md
echo "amy">.gitignore
git add .
git commit -m"First commit of README.md and .gitignore"
   # [master (root-commit) 98e3829] First commit of README.md and .gitignore
   #  2 files changed, 2 insertions(+)
   #  create mode 100644 .gitignore
   #  create mode 100644 README.md

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
   # [master 7f075cc] initial don. Second commit.
   #  2 files changed, 2 insertions(+)
   #  create mode 100644 chris
   #  create mode 100644 don
echo ">>> NOTE: chris and don got committed together."

MSG="7. I'm Ed. I escape from commitment by being edited. In the way now."
echo -e "\n>>> $MSG"
echo $MSG>ed
git add ed
git commit -m "initial ed. Third commit."
   # [master 23f25e7] initial ed. Third commit.
   #  1 file changed, 1 insertion(+)
   #  create mode 100644 ed
echo "Now I'm outside." >>ed  # concatenated.
echo ">>> cat ed to show two lines:"
cat ed
echo ">>> End of file."

MSG="8. I'm Finn. I escaped but got added back, but not committed."
echo -e "\n>>> $MSG"
echo $MSG>finn
git add finn
git commit -m"initial finn. Fourth commit."
    # [master 8e67547] initial finn. Fourth commit.
    #  1 file changed, 1 insertion(+)
    #  create mode 100644 finn
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
   # .          ..         .git       .gitignore README.md  amy        bob        chris      don        ed         finn       george     harry
echo -e "\n>>> Git status -s -b:"
git status -s -b
   # ## master
   #  M ed
   # ?? bob
   # ?? harry
echo ">>> NOTE: Ignored (amy) and Committed files (chris, don, ed, finn, george) don't appear on git status."

echo -e "\n>>> git log after initial commits:"
git log --pretty=format:"%h %s %ad" --graph --since=1.days --date=relative
   # * e725d6a so george rises again. Sixth commit. 0 seconds ago

echo -e "\n>>> git reflog (of git actions) after initial commits:"
git reflog
   # e725d6a (HEAD -> master) HEAD@{0}: commit: so george rises again. Sixth commit.
   # a3ee452 HEAD@{1}: commit: initial george. Fifth commit.
   # 8e67547 HEAD@{2}: commit: initial finn. Fourth commit.
   # 23f25e7 HEAD@{3}: commit: initial ed. Third commit.
   # 7f075cc HEAD@{4}: commit: initial don. Second commit.
   # 98e3829 HEAD@{5}: commit (initial): First commit of README.md and .gitignore

echo -e "\n>>> 11. git checkout HEAD@{4} attempt:"
git checkout HEAD@{4}
   # error: Your local changes to the following files would be overwritten by checkout:
   # 	ed
   # Please commit your changes or stash them before you switch branches.
   # Aborting

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
   # Note: checking out 'HEAD@{4}'.
   # You are in 'detached HEAD' state. You can look around, make experimental
   # changes and commit them, and you can discard any commits you make in this
   # state without impacting any branches by performing another checkout.
   # HEAD is now at 2bebeec initial ed. Third commit.

echo -e "\n>>> Git reflog -n 6 after checkout HEAD@{4}:"
git reflog -n 6
   # 2bebeec (HEAD) HEAD@{0}: checkout: moving from master to HEAD@{4}
   # 32fa405 (master) HEAD@{1}: reset: moving to HEAD
   # 32fa405 (master) HEAD@{2}: commit: so george rises again. Sixth commit.
   # 03e5189 HEAD@{3}: commit: initial george. Fifth commit.
   # d87c877 HEAD@{4}: commit: initial finn. Fourth commit.
   # 2bebeec (HEAD) HEAD@{5}: commit: initial ed. Third commit.

echo -e "\n>>> Listing files in folder $WORKING_FOLDER after checkout:"
ls -a
   # .          ..         .git       .gitignore README.md  amy        bob        chris      don        ed         harry

echo ">>> NOTE: finn, george wasn't committed yet."
echo -e "\n>>> cat ed contents: It doesn't contain 2nd line:"
cat ed

echo -e "\n>>> Git status -s -b after checkout:"
git status -s -b
   # ## HEAD (no branch)
   # ?? bob
   # ?? harry
echo ">>> NOTE: Untracked files still there on the sidelines."

echo -e "\n>>> 14. git checkout back to master:"
git checkout master
   # Previous HEAD position was 2bebeec initial ed. Third commit.
   # Switched to branch 'master'

echo -e "\n>>> Git reflog after checkout master:"
git reflog -n 3
   # 32fa405 (HEAD -> master) HEAD@{0}: checkout: moving from 2bebeecd4ca251429b958275805675d206501353 to master
   # 2bebeec HEAD@{1}: checkout: moving from master to HEAD@{4}
   # 32fa405 (HEAD -> master) HEAD@{2}: reset: moving to HEAD

echo -e "\n>>> Listing files in folder $WORKING_FOLDER :"
ls -a
echo ">>> NOTE: The whole gang is back together."

echo -e "\n>>> 15a. git stash pop:"
git stash pop

echo -e "\n>>> Git status -s -b after stack pop:"
git status -s -b
   # ## master
   #  M ed
   # ?? bob
   # ?? harry

echo -e "\n>>> cat ed"
cat ed
   # 7. I'm Ed. I escape from commitment by being edited. In the way now.
   # Now I'm outside.
echo ">>> NOTE: 2nd line should appear now."

echo -e "\n>>> git stash list after pop:"
git stash list
echo ">>> nothing returns if the list is empty."

exit

echo -e "\n>>> 15. New branch AddIngrid:"
git checkout -b Add-Ingrid
echo -e "\n>>> Git reflog:"
git reflog -n 5
