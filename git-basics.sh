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
            WORKING_FOLDER="git_stash-demo"
fi
cd ~/
rm -rf $WORKING_FOLDER
mkdir  $WORKING_FOLDER
   cd  $WORKING_FOLDER

echo -e "\n>>> 1. git init within $PWD:"
git init  # to initialized empty repository
   # Initialized empty Git repository in /Users/wilsonmar/git_repo/.git/

# Mute warnings on Windows machines:
git config --global core.safecrlf false
   # No response is expected.

echo "#git-basics.sh">README.md
echo "amy">.gitignore
MSG="2. Add README.md and .gitignore to staging"
echo ">>> 2. git add & commit -m\"$MSG\""
git add .
git commit -m"1st commit - $MSG"
   # [master (root-commit) 4ca8a19] 1st commit - 2. Add README.md and .gitignore to staging
   #  2 files changed, 2 insertions(+)
   #  create mode 100644 .gitignore
   #  create mode 100644 README.md
echo ">>> NOTE: hash code 4ca8a19 and others are new with every run."

MSG="3. I'm Amy. I get ignored."
echo -e "\n>>> $MSG"
echo $MSG>amy

MSG="4. I'm Bob. I never go anywhere and stay untracked."
echo -e "\n>>> $MSG"
echo $MSG>bob

MSG="5. I'm Chris. I visit the Index."
echo -e "\n>>> \"$MSG\" with git add (no commit yet)"
echo $MSG>chris
git add chris
echo ">>> git add does not issue a response message unless there is an error."

MSG="6. I'm Don. I got committed once."
echo -e "\n>>> git add & commit "
echo $MSG>don
git add don
git commit -m"2nd commit - $MSG"
   # [master f6e6fb3] 2nd commit - 6. I'm Don. I got committed once.
   #  2 files changed, 2 insertions(+)
   #  create mode 100644 chris
   #  create mode 100644 don
echo ">>> NOTE: chris and don got committed together."

MSG="7. I'm Ed. But I'll soon be modified."
echo -e "\n>>> $MSG"
echo $MSG>ed
git add ed
git commit -m "3rd commit - $MSG"
   # [master 4e4bada] 3rd commit with 7. I'm Ed. But I'll soon escape by being edited.
   #  1 file changed, 1 insertion(+)
   #  create mode 100644 ed
echo "Now I'm outside." >>ed  # concatenated.
echo ">>> Add 2nd line to file ed. cat ed shows two lines:"
cat ed
echo ">>> End of file we're actively working on."

MSG="8. I'm Finn. I  got edited and added back, but not committed."
echo -e "\n>>> $MSG"
echo $MSG>finn
git add finn
git commit -m"4th commit - $MSG"
    # [master c21af48] 4th commit - 8. I'm Finn. I  got edited and added back, but not committed.
    #  1 file changed, 1 insertion(+)
    #  create mode 100644 finn
echo "Now I'm outside." >>finn
echo ">>> git add finn"
git add finn
echo -e "\n>>> cat finn shows two lines:"
cat finn

echo ">>> 9. finn and george are committed together as 2 files:"
MSG="9a. I'm George. I'm a frequent traveler."
echo $MSG>george
git add george
git commit -m"5th commit - $MSG"

echo "Now I'm outside." >>george
git add george
MSG="9b. George is committed again."
git commit -m"6th commit - $MSG"

MSG="10. I'm Harry."
echo -e "\n>>> $MSG"
echo $MSG>harry
echo ">>> Harry will be stashed and removed without entering commit."

echo -e "\n>>> 11. Listing files (using ls -a) in folder $WORKING_FOLDER :"
ls -a
   # .          ..         .git       .gitignore README.md  amy        bob        chris      don        ed         finn       george     harry
echo -e "\n>>> 12. Git status -s -b"
git status -s -b
   # ## master
   #  M ed
   # ?? bob
   # ?? harry
echo ">>> NOTE: Ignored (amy) and Committed files (chris, don, ed, finn, george) don't appear on git status."
echo ">>> PROTIP: The "M" nex to file ed means Modified and thus being tracked by Git."

echo -e "\n>>> 13. git log after initial commits:"
git log --pretty=format:"%h %s %ad" --graph --since=10.days --date=relative
   # * 9af0a6d 6th commit - 9b. George rises again. 0 seconds ago
   # * 473b096 5th commit - 9a. I'm George. My first commit. 0 seconds ago
   # * c21af48 4th commit - 8. I'm Finn. I  got edited and added back, but not committed. 0 seconds ago
   # * 4e4bada 3rd commit - 7. I'm Ed. But I'll soon escape by being edited. 0 seconds ago
   # * f6e6fb3 2nd commit - 6. I'm Don. I got committed once. 0 seconds ago
   # * 4ca8a19 1st commit - 2. Add README.md and .gitignore to staging 0 seconds ago

echo -e "\n>>> 14. git reflog (of git actions) after initial commits:"
git reflog
   # 9af0a6d (HEAD -> master) HEAD@{0}: commit: 6th commit - 9b. George rises again.
   # 473b096 HEAD@{1}: commit: 5th commit - 9a. I'm George. My first commit.
   # c21af48 HEAD@{2}: commit: 4th commit - 8. I'm Finn. I got edited and added back, but not committed.
   # 4e4bada HEAD@{3}: commit: 3rd commit - 7. I'm Ed. But I'll soon escape by being edited.
   # f6e6fb3 HEAD@{4}: commit: 2nd commit - 6. I'm Don. I got committed once.
   # 4ca8a19 HEAD@{5}: commit (initial): 1st commit - 2. Add README.md and .gitignore to staging

echo -e "\n>>> 15. git checkout HEAD@{4} attempt (at TIME TRAVEL):"
git checkout HEAD@{4}
   # error: Your local changes to the following files would be overwritten by checkout:
   # 	ed
   # Please commit your changes or stash them before you switch branches.
   # Aborting

echo -e "\n>>> 16. git stash save \"working on ed outside after adding Harry.\""
git stash save "working on ed outside after adding Harry."
echo ">>> NOTE: Untracked files do not get stashed by default."

echo -e "\n>>> 17. git stash list:"
git stash list

echo -e "\n>>> 18. git stash show:"
git stash show

echo -e "\n>>> 19. git status -s -b after git stash and before going back in time:"
git status -s -b
echo ">>> NOTE: Untracked files still there on the sidelines."

echo -e "\n>>> 20. git checkout HEAD@{4} when Don was committed:"
git checkout HEAD@{4}
   # Note: checking out 'HEAD@{4}'.
   # You are in 'detached HEAD' state. You can look around, make experimental
   # changes and commit them, and you can discard any commits you make in this
   # state without impacting any branches by performing another checkout.
   # HEAD is now at 744646a 3rd commit - 7. I'm Ed. But I'll soon be modified.

echo -e "\n>>> 21. cat ed contents: It doesn't contain 2nd line:"
cat ed
echo ">>> end of file."

echo -e "\n>>> 22. ls -a - listing files after checkout:"
ls -a
   # .          ..         .git       .gitignore README.md  amy        bob        chris      don        ed         harry
echo ">>> Notice finn and george are not included because they happen after the point of checkout."

echo -e "\n>>> 23. git reflog -n 6 after checkout HEAD@{4}:"
git reflog -n 6
   # 4e4bada (HEAD) HEAD@{0}: checkout: moving from master to HEAD@{4}
   # 9af0a6d (master) HEAD@{1}: reset: moving to HEAD
   # 9af0a6d (master) HEAD@{2}: commit: 6th commit - 9b. George rises again.
   # 473b096 HEAD@{3}: commit: 5th commit - 9a. I'm George. My first commit.
   # c21af48 HEAD@{4}: commit: 4th commit - 8. I'm Finn. I got edited and added back, but not committed.
   # 4e4bada (HEAD) HEAD@{5}: commit: 3rd commit with 7. I'm Ed. But I'll soon escape by being edited.
echo ">>> NOTE: finn, george are included in reflog because it lists all actions."

echo -e "\n>>> 24. Line \"Touched while away\" is added to file don:"
echo "Touched while away">>don

echo -e "\n>>> 25. git status shows file done was modified:"
git status -s -b

echo -e "\n>>> 26. git checkout back to master:"
git checkout master
   # M  don
   # Previous HEAD position was 9c31cef 3rd commit - 7. I'm Ed. But I'll soon be modified.
   # Switched to branch 'master'

echo -e "\n>>> 27. Listing files shows the whole gang is back together (from amy to george)."
ls -a

echo -e "\n>>> 28. git status shows file after getting back to master:"
cat don
echo ">>> Modification to don is carried forward."

echo -e "\n>>> 29. git stash pop:"
git stash pop
   # Dropped refs/stash@{0} (6023f95782622e62ee219fac3076827ee1463e1c)

echo -e "\n>>> 30. Git status -s -b after stack pop:"
git status -s -b
   # ## master
   #  M ed
   # ?? bob
   # ?? harry

echo -e "\n>>> 31. cat (display contents of) file ed:"
cat ed 
echo ">>> NOTE: see the second line is back."

echo -e "\n>>> 32. git stash list after pop:"
git stash list
echo ">>> nothing returns if the list is empty."

echo -e "\n>>> 33. git reflog after checkout master:"
git reflog -n 3
   # 32fa405 (HEAD -> master) HEAD@{0}: checkout: moving from 2bebeecd4ca251429b958275805675d206501353 to master
   # 2bebeec HEAD@{1}: checkout: moving from master to HEAD@{4}
   # 32fa405 (HEAD -> master) HEAD@{2}: reset: moving to HEAD

echo -e "\n>>> 34a. Some prefer an alternate to stash in checking out a branch:"
echo "git checkout -b tmpbranch:"
git checkout -b tmpbranch
echo -e "\n>>> 34b. cat (display contents) of harry"
cat harry
echo ">>> end of file"
echo -e "\n>>> 34c. git add & commit -m\"saving harry\" "
git add harry
git commit -m "saving harry"
echo -e "\n>>> 34d. git status -s -b after saving harry:"
git status -s -b
   # ## master
   #  M ed
   # ?? bob
   # ?? harry

echo -e "\n>>> 34f. checkout master"
git checkout master
echo -e "\n>>> 34g. Listing files shows the whole gang is back together (from amy to george)."
ls -a

exit

echo -e "\n>>> 36. New branch AddIngrid:"
git checkout -b Add-Ingrid
echo -e "\n>>> Git reflog:"
git reflog -n 5
