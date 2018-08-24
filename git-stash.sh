#!/bin/bash
# This is git-stash.sh from https://github.com/wilsonmar/git-utilities
# Described in https://wilsonmar.github.io/git-stash
# This script performs the most common actions resulting in the various statuses,
# so you can make changes and see the effect.
# Remember to chmod +x git-stash.sh first, then paste this command in your terminal
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/git-utilities/master/git-stash.sh)"

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
echo -e "\n>>> 1. git init within $PWD:"
git init  # to initialized empty repository
   # Initialized empty Git repository in /Users/wilsonmar/git_repo/.git/

echo -e "\n>>> 2. Create README.md & .gitignore:"
echo "#git-stash.sh">README.md
echo "amy">.gitignore
MSG="2. Add README.md and .gitignore to staging"
echo ">>> 2. git add & commit -m\"$MSG\" (no response)"
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
echo -e "\n>>> git add chris ($MSG)"
echo $MSG>chris
git add chris

MSG="6. I'm Don. I got commited once."
echo -e "\n>>> add & commit -m\"$MSG\""
echo $MSG>don
git add don
git commit -m"2nd commit - $MSG"
   # [master f6e6fb3] 2nd commit - 6. I'm Don. I got commited once.
   #  2 files changed, 2 insertions(+)
   #  create mode 100644 chris
   #  create mode 100644 don
echo ">>> NOTE: chris and don got committed together."

MSG="7. I'm Ed. But I'll soon escape by being edited."
echo -e "\n>>> $MSG"
echo $MSG>ed
git add ed
git commit -m "3rd commit with $MSG"
   # [master 4e4bada] 3rd commit with 7. I'm Ed. But I'll soon escape by being edited.
   #  1 file changed, 1 insertion(+)
   #  create mode 100644 ed
echo "Now I'm outside." >>ed  # concatenated.
echo ">>> cat ed to show two lines:"
cat ed
echo ">>> End of file."

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

echo -e "\n>>> cat finn"
cat finn

MSG="9a. I'm George. My first commit."
echo -e "\n>>> $MSG"
echo $MSG>george
git add george
git commit -m"5th commit - $MSG"

echo "Now I'm outside." >>george
git add george
MSG="9b. George rises again."
git commit -m"6th commit - $MSG"

MSG="10. I'm Harry. I just joined."
echo -e "\n>>> $MSG"
echo $MSG>harry

echo -e "\n>>> 11. Listing files in folder $WORKING_FOLDER :"
ls -a
   # .          ..         .git       .gitignore README.md  amy        bob        chris      don        ed         finn       george     harry
echo -e "\n>>> 12. Git status -s -b:"
git status -s -b
   # ## master
   #  M ed
   # ?? bob
   # ?? harry
echo ">>> NOTE: Ignored (amy) and Committed files (chris, don, ed, finn, george) don't appear on git status."

echo -e "\n>>> 13. git log after initial commits:"
git log --pretty=format:"%h %s %ad" --graph --since=1.days --date=relative
   # * 9af0a6d 6th commit - 9b. George rises again. 0 seconds ago
   # * 473b096 5th commit - 9a. I'm George. My first commit. 0 seconds ago
   # * c21af48 4th commit - 8. I'm Finn. I  got edited and added back, but not committed. 0 seconds ago
   # * 4e4bada 3rd commit with 7. I'm Ed. But I'll soon escape by being edited. 0 seconds ago
   # * f6e6fb3 2nd commit - 6. I'm Don. I got commited once. 0 seconds ago
   # * 4ca8a19 1st commit - 2. Add README.md and .gitignore to staging 0 seconds ago

echo -e "\n>>> 14. git reflog (of git actions) after initial commits:"
git reflog
   # 9af0a6d (HEAD -> master) HEAD@{0}: commit: 6th commit - 9b. George rises again.
   # 473b096 HEAD@{1}: commit: 5th commit - 9a. I'm George. My first commit.
   # c21af48 HEAD@{2}: commit: 4th commit - 8. I'm Finn. I got edited and added back, but not committed.
   # 4e4bada HEAD@{3}: commit: 3rd commit with 7. I'm Ed. But I'll soon escape by being edited.
   # f6e6fb3 HEAD@{4}: commit: 2nd commit - 6. I'm Don. I got commited once.
   # 4ca8a19 HEAD@{5}: commit (initial): 1st commit - 2. Add README.md and .gitignore to staging

echo -e "\n>>> 15. git checkout HEAD@{4} attempt:"
git checkout HEAD@{4}
   # error: Your local changes to the following files would be overwritten by checkout:
   # 	ed
   # Please commit your changes or stash them before you switch branches.
   # Aborting

echo -e "\n>>> 16a. git stash:"
git stash save "working on ed outside after adding Harry."
echo -e "\n>>> 16b. git stash list:"
git stash list
echo -e "\n>>> 16c. git stash show:"
git stash show
echo ">>> NOTE: Untracked files get stashed only when --untracked is specified on git stash."

echo -e "\n>>> 17. Listing files again in folder $WORKING_FOLDER before going back in time:"
ls -a
echo -e "\n>>> 18. git checkout HEAD@{4} when Don was committed:"
git checkout HEAD@{4}
   # Note: checking out 'HEAD@{4}'.
   # You are in 'detached HEAD' state. You can look around, make experimental
   # changes and commit them, and you can discard any commits you make in this
   # state without impacting any branches by performing another checkout.
   # HEAD is now at 2bebeec initial ed. Third commit.

echo -e "\n>>> 19. Git reflog -n 6 after checkout HEAD@{4}:"
git reflog -n 6
   # 4e4bada (HEAD) HEAD@{0}: checkout: moving from master to HEAD@{4}
   # 9af0a6d (master) HEAD@{1}: reset: moving to HEAD
   # 9af0a6d (master) HEAD@{2}: commit: 6th commit - 9b. George rises again.
   # 473b096 HEAD@{3}: commit: 5th commit - 9a. I'm George. My first commit.
   # c21af48 HEAD@{4}: commit: 4th commit - 8. I'm Finn. I got edited and added back, but not committed.
   # 4e4bada (HEAD) HEAD@{5}: commit: 3rd commit with 7. I'm Ed. But I'll soon escape by being edited.

echo -e "\n>>> 20. Listing files in folder $WORKING_FOLDER after checkout:"
ls -a
   # .          ..         .git       .gitignore README.md  amy        bob        chris      don        ed         harry

echo ">>> NOTE: finn, george wasn't committed yet."
echo -e "\n>>> 21. cat ed contents: It doesn't contain 2nd line:"
cat ed

echo -e "\n>>> 22. Git status -s -b after checkout:"
git status -s -b
   # ## HEAD (no branch)
   # ?? bob
   # ?? harry
echo ">>> NOTE: Untracked files still there on the sidelines."

echo -e "\n>>> 23. git checkout back to master:"
git checkout master
   # Previous HEAD position was 2bebeec initial ed. Third commit.
   # Switched to branch 'master'

echo -e "\n>>> 24. Git reflog after checkout master:"
git reflog -n 3
   # 32fa405 (HEAD -> master) HEAD@{0}: checkout: moving from 2bebeecd4ca251429b958275805675d206501353 to master
   # 2bebeec HEAD@{1}: checkout: moving from master to HEAD@{4}
   # 32fa405 (HEAD -> master) HEAD@{2}: reset: moving to HEAD

echo -e "\n>>> 15. Listing files in folder $WORKING_FOLDER :"
ls -a
echo ">>> NOTE: The whole gang is back together."

echo -e "\n>>> 26. git stash pop:"
git stash pop
   # Dropped refs/stash@{0} (6023f95782622e62ee219fac3076827ee1463e1c)

echo -e "\n>>> 27. Git status -s -b after stack pop:"
git status -s -b
   # ## master
   #  M ed
   # ?? bob
   # ?? harry

echo -e "\n>>> 28. git stash list after pop:"
git stash list
echo ">>> nothing returns if the list is empty."

echo -e "\n>>> 29. cat ed"
cat ed
   # 7. I'm Ed. But I'll soon escape by being edited.
   # Now I'm outside.
echo ">>> NOTE: 2nd line should appear now."

exit

echo -e "\n>>> 30. New branch AddIngrid:"
git checkout -b Add-Ingrid
echo -e "\n>>> Git reflog:"
git reflog -n 5
