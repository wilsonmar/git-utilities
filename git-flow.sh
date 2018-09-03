#!/bin/bash
# This is git-flow.sh from https://github.com/wilsonmar/git-utilities
# by WilsonMar@gmail.com
# Described in https://wilsonmar.github.io/git-flow
# This script performs the most common actions resulting in the various statuses,
# so you can make changes and see the effect.
# Remember to chmod +x git-flow.sh first, then paste this command in your terminal
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/git-utilities/master/git-flow.sh)"

function fancy_echo() {
  local fmt="$1"; shift
  printf "\\n   >>> $fmt\\n" "$@"
}
function c_echo() {
  local fmt="$1"; shift
  printf "\\n $ $fmt\\n" "$@"
}
command_exists() {
  command -v "$@" > /dev/null 2>&1
}

clear

RUNTYPE=""
       #remove
       #update

fancy_echo "1.1 Local machine metadata ..."

# For Git on Windows, see http://www.rolandfg.net/2014/05/04/intellij-idea-and-git-on-windows/
TIME_START="$(date -u +%s)"
FREE_DISKBLOCKS_START="$(df | sed -n -e '2{p;q}' | cut -d' ' -f 6)"

LOG_PREFIX=$(date +%Y-%m-%dT%H:%M:%S%z)-$((1 + RANDOM % 1000))
   # ISO-8601 date plus RANDOM=$((1 + RANDOM % 1000))  # 3 digit random number.
   #  LOGFILE="$0.$LOG_PREFIX.log"
c_echo "$0 starting at $LOG_PREFIX ..."

c_echo "uname -a "
   echo -e "$(uname -a)"
   # if Mac/Darwin:
   c_echo "sw_vers "
      echo -e "$(sw_vers)"

MAC_USERID=$(id -un 2>/dev/null || true)  # example: wilsonmar
   echo "MAC_USERID=$MAC_USERID"


fancy_echo "1.2 Ensure Homebrew client is installed ..."
   # Remove to be done manually.
   if ! command_exists brew ; then
       RUBY_VERSION="$(ruby --version)"
       fancy_echo "Installing homebrew using in-built $RUBY_VERSION ..." 
       ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
       brew tap caskroom/cask
   else
       # Upgrade if run-time attribute contains "upgrade":
       if [[ "${RUNTYPE}" == *"update"* ]]; then
          BREW_VERSION="$(brew --version | grep "Homebrew ")"
          fancy_echo "Brew upgrading $BREW_VERSION ..." 
          brew update 
       fi
   fi
   echo "$(brew --version)"

fancy_echo "1.3 Ensure Git client(s) availabilty ..."

c_echo "git --version"
        git --version


   #  Define folder name if it's not specified in 1st command argument:
               WORKSPACE_FOLDER="$1"
   if [[ -z "${WORKSPACE_FOLDER// }"  ]]; then  #it's blank so assign default:
               WORKSPACE_FOLDER="git-flow-workspace"
   fi
fancy_echo "1.4 WORKSPACE_FOLDER=$WORKSPACE_FOLDER ..."

   # Delete folder from last run:
   cd ~/
       rm -rf $WORKSPACE_FOLDER
       mkdir  $WORKSPACE_FOLDER
          cd  $WORKSPACE_FOLDER
c_echo "cd \$WORKSPACE_FOLDER"
        echo "at pwd=$PWD ..."


   ALIAS_FILENAME="aliases.txt"
   BASHFILE="~/.bash_profile"
fancy_echo "1.5 Ensure ALIAS_FILENAME=$ALIAS_FILENAME for ~/.bash_profile ..."
ls -al "$BASHFILE"  # 9462 bytes
      if [ ! -f "$BASHFILE" ]; then
         fancy_echo "$BASHFILE not found. Creating it ..."
         # echo "Created by git-flow.sh" >>$BASHFILE
      fi

   # Alternately, clone in git-utilities

fancy_echo "1.6 Ensure $ALIAS_FILENAME  is configured under ~/.bash_profile ..."
if grep "$ALIAS_FILENAME" "$BASHFILE" ; then # already in file:
   fancy_echo "$ALIAS_FILENAME already in $BASHFILE."
else
   echo "at pwd=$PWD ..."
   curl -O "https://raw.githubusercontent.com/wilsonmar/git-utilities/master/$ALIAS_FILENAME"
           # 1345 bytes

   fancy_echo "Concatenating aliases file $ALIAS_FILENAME into $BASHFILE ..."
#   cat "$HOME/$ALIAS_FILENAME" >> "$BASHFILE"
      ls -al $ALIAS_FILENAME 

# DEBUGGING:
#   c_echo "source $BASHFILE"
#             source "$BASHFILE"  # requires password.
# TODO: If not right, exit here.
fi 


fancy_echo "1.2 Get GitHub account ..."


fancy_echo "1.1 Get GitHub account ..."



fancy_echo "1.4 Install Git client ..."


fancy_echo "1.5 Configure ~/.git-config with git config commands ..."

exit
 
   # Mute warnings on Windows machines:
   git config --global core.safecrlf false
      # No response is expected.

fancy_echo "1. git init within $PWD:"
git init  # to initialized empty repository
   # Initialized empty Git repository in /Users/wilsonmar/git_repo/.git/

fancy_echo "2. Add README.md and .gitignore to staging"
echo "$ echo \"#git-flow.sh\" > README.md"
        echo "#git-flow.sh">README.md

echo "$ echo \"amy\">.gitignore"
        echo "amy">.gitignore

echo "$ git add ."
        git add .

echo "$ git commit -m\"1st commit - $MSG\""
        git commit -m"1st commit - $MSG"
   # [master (root-commit) 4ca8a19] 1st commit - 2. Add README.md and .gitignore to staging
   #  2 files changed, 2 insertions(+)
   #  create mode 100644 .gitignore
   #  create mode 100644 README.md
echo ">>> NOTE: hash code 4ca8a19 and others are new with every run."

MSG="3. I'm Amy. I get ignored."
echo "$ echo \"$MSG\">amy"
        echo "$MSG">amy

MSG="4. I'm Bob. I never go anywhere and stay untracked."
echo "$ echo \"$MSG\">bob"
        echo "$MSG">bob

MSG="5. I'm Chris. I visit the Index."
echo "$ echo \"$MSG\">chris"
        echo "$MSG">chris

echo "$ git add chris"
        git add chris
echo ">>> git add does not issue a response message unless there is an error."

MSG="6. I'm Don. I got committed once."
echo "$ echo \"$MSG\">don"
        echo "$MSG">don

echo "$ git add don"
        git add don

echo "$ git commit -m\"2nd commit - $MSG\""
        git commit -m"2nd commit - $MSG"
   # [master f6e6fb3] 2nd commit - 6. I'm Don. I got committed once.
   #  2 files changed, 2 insertions(+)
   #  create mode 100644 chris
   #  create mode 100644 don
echo ">>> NOTE: chris and don got committed together."

MSG="7. I'm Ed. But I'll soon be modified."
echo "$ echo \"$MSG\">ed"
        echo  "$MSG" >ed

echo "$ git add ed"
        git add ed

echo "$ git commit -m\"3rd commit - $MSG\""
        git commit -m "3rd commit - $MSG"
   # [master 4e4bada] 3rd commit with 7. I'm Ed. But I'll soon escape by being edited.
   #  1 file changed, 1 insertion(+)
   #  create mode 100644 ed
echo "$ echo \"Now I'm outside.\" >>ed   # concatenated."
        echo "Now I'm outside." >>ed  # concatenated.

fancy_echo "Add 2nd line to file ed. cat ed shows two lines:"
echo "$ cat ed"
        cat ed
echo ">>> End of file we're actively working on."

MSG="8. I'm Finn. I  got edited and added back, but not committed."
echo -e "\n$ echo \"$MSG\" >finn"
        echo $MSG>finn

echo "$ git add finn"
        git add finn

echo "$ git commit -m\"4th commit - $MSG\""
        git commit -m"4th commit - $MSG"
    # [master c21af48] 4th commit - 8. I'm Finn. I  got edited and added back, but not committed.
    #  1 file changed, 1 insertion(+)
    #  create mode 100644 finn

echo "$ echo \"Now I'm outside.\" >>finn"
        echo ">>> git add finn"

echo "$ git add finn"
        git add finn

fancy_echo "cat finn shows two lines:"
echo "$ cat finn"
        cat finn

echo ">>> 9. finn and george are committed together as 2 files:"
MSG="9a. I'm George. I'm a frequent traveler."
echo "$ echo \"$MSG\">george"
        echo "$MSG">george
echo "$ git add george"
        git add george

echo "$ git commit -m\"5th commit - $MSG\""
        git commit -m"5th commit - $MSG"

echo "$ echo \"Now I'm outside.\" >>george\"  # concatenate"
        echo "Now I'm outside." >>george

echo "$ git add george"
        git add george

MSG="9b. George is committed again."
echo "$ git commit -m\"6th commit - $MSG\" "
        git commit -m"6th commit - $MSG"

MSG="10. I'm Harry."
echo "$ \"$MSG\">harry"
    echo "$MSG">harry
echo ">>> (Harry will later be stashed and removed without entering commit.)"

fancy_echo "11. ls -a  # Listing files (using ls -a) in folder $WORKSPACE_FOLDER :"
ls -a
   # .          ..         .git       .gitignore README.md  amy        bob        chris      don        ed         finn       george     harry
fancy_echo "12. git status -s -b"
git status -s -b
   # ## master
   #  M ed
   # ?? bob
   # ?? harry
echo ">>> NOTE: Ignored (amy) and Committed files (chris, don, ed, finn, george) don't appear on git status."
echo ">>> PROTIP: The "M" nex to file ed means Modified and thus being tracked by Git."

fancy_echo "13. git log --pretty=format:"%h %s %ad" --graph --since=10.days --date=relative "
git log --pretty=format:"%h %s %ad" --graph --since=10.days --date=relative
   # * 9af0a6d 6th commit - 9b. George rises again. 0 seconds ago
   # * 473b096 5th commit - 9a. I'm George. My first commit. 0 seconds ago
   # * c21af48 4th commit - 8. I'm Finn. I  got edited and added back, but not committed. 0 seconds ago
   # * 4e4bada 3rd commit - 7. I'm Ed. But I'll soon escape by being edited. 0 seconds ago
   # * f6e6fb3 2nd commit - 6. I'm Don. I got committed once. 0 seconds ago
   # * 4ca8a19 1st commit - 2. Add README.md and .gitignore to staging 0 seconds ago

fancy_echo "14. git reflog  # (of git actions) after initial commits:"
git reflog
   # 9af0a6d (HEAD -> master) HEAD@{0}: commit: 6th commit - 9b. George rises again.
   # 473b096 HEAD@{1}: commit: 5th commit - 9a. I'm George. My first commit.
   # c21af48 HEAD@{2}: commit: 4th commit - 8. I'm Finn. I got edited and added back, but not committed.
   # 4e4bada HEAD@{3}: commit: 3rd commit - 7. I'm Ed. But I'll soon escape by being edited.
   # f6e6fb3 HEAD@{4}: commit: 2nd commit - 6. I'm Don. I got committed once.
   # 4ca8a19 HEAD@{5}: commit (initial): 1st commit - 2. Add README.md and .gitignore to staging

fancy_echo "15. git checkout HEAD@{4}  # attempt (at TIME TRAVEL):"
git checkout HEAD@{4}
   # error: Your local changes to the following files would be overwritten by checkout:
   # 	ed
   # Please commit your changes or stash them before you switch branches.
   # Aborting

fancy_echo "16. git stash save \"working on ed outside after adding Harry.\""
git stash save "working on ed outside after adding Harry."
echo ">>> NOTE: Untracked files do not get stashed by default."

fancy_echo "17. git stash list"
git stash list

fancy_echo "18. git stash show"
git stash show

fancy_echo "19. git status -s -b   # after git stash and before going back in time:"
git status -s -b
echo ">>> NOTE: Untracked files still there on the sidelines."

fancy_echo "20. git checkout HEAD@{4}   # when Don was committed:"
git checkout HEAD@{4}
   # Note: checking out 'HEAD@{4}'.
   # You are in 'detached HEAD' state. You can look around, make experimental
   # changes and commit them, and you can discard any commits you make in this
   # state without impacting any branches by performing another checkout.
   # HEAD is now at 744646a 3rd commit - 7. I'm Ed. But I'll soon be modified.

fancy_echo "21. cat ed  # contents: It doesn't contain 2nd line:"
cat ed
echo ">>> end of file."

fancy_echo "22. ls -a   # listing files after checkout:"
ls -a
   # .          ..         .git       .gitignore README.md  amy        bob        chris      don        ed         harry
echo ">>> Notice finn and george are not included because they happen after the point of checkout."

fancy_echo "23. git reflog -n 6   # after checkout HEAD@{4}:"
git reflog -n 6
   # 4e4bada (HEAD) HEAD@{0}: checkout: moving from master to HEAD@{4}
   # 9af0a6d (master) HEAD@{1}: reset: moving to HEAD
   # 9af0a6d (master) HEAD@{2}: commit: 6th commit - 9b. George rises again.
   # 473b096 HEAD@{3}: commit: 5th commit - 9a. I'm George. My first commit.
   # c21af48 HEAD@{4}: commit: 4th commit - 8. I'm Finn. I got edited and added back, but not committed.
   # 4e4bada (HEAD) HEAD@{5}: commit: 3rd commit with 7. I'm Ed. But I'll soon escape by being edited.
echo ">>> NOTE: finn, george are included in reflog because it lists all actions."

fancy_echo "24. concatenate line to file don:"
echo "$ echo \"Touched while away\" >>don "
        echo  "Touched while away"  >>don

fancy_echo "25. git status -s -b  # shows file done was modified:"
git status -s -b

fancy_echo "26. git checkout master  # back to master:"
git checkout master
   # M  don
   # Previous HEAD position was 9c31cef 3rd commit - 7. I'm Ed. But I'll soon be modified.
   # Switched to branch 'master'

fancy_echo "27. ls -a  # Listing files shows the whole gang is back together (from amy to george)."
ls -a

fancy_echo "28. cat don  "
cat don
echo ">>> Modification to don is carried forward."

fancy_echo "29. git stash pop"
git stash pop
   # Dropped refs/stash@{0} (6023f95782622e62ee219fac3076827ee1463e1c)

fancy_echo "30. git status -s -b   # after stack pop:"
git status -s -b
   # ## master
   #  M ed
   # ?? bob
   # ?? harry

fancy_echo "31. cat ed  # (display contents of) file ed:"
cat ed 
echo ">>> NOTE: see the second line is back."

fancy_echo "32. git stash list  # after pop:"
git stash list
echo ">>> nothing returns if the list is empty."

fancy_echo "33. git reflog -n 3  # after checkout master:"
git reflog -n 3
   # 32fa405 (HEAD -> master) HEAD@{0}: checkout: moving from 2bebeecd4ca251429b958275805675d206501353 to master
   # 2bebeec HEAD@{1}: checkout: moving from master to HEAD@{4}
   # 32fa405 (HEAD -> master) HEAD@{2}: reset: moving to HEAD

fancy_echo "34a. Some prefer an alternate to stash in checking out a branch:"
echo "$ git checkout -b tmpbranch:"
        git checkout -b tmpbranch

fancy_echo "34b. cat (display contents) of harry"
cat harry
echo ">>> end of file"

fancy_echo "34c. git add & commit -m\"saving harry\" "
git add harry
git commit -m "saving harry"

fancy_echo "34d. git status -s -b after saving harry:"
git status -s -b
   # ## master
   #  M ed
   # ?? bob
   # ?? harry

fancy_echo "34f. git checkout master"
git checkout master

fancy_echo "34g. git branch -vv"
git branch -vv

fancy_echo "34h. ls -a  # Listing files shows the whole gang is back together (from amy to george)."
ls -a


#fancy_echo "36. New branch AddIngrid:"
#git checkout -b Add-Ingrid
#fancy_echo "Git reflog:"
#git reflog -n 5



FREE_DISKBLOCKS_END=$(df | sed -n -e '2{p;q}' | cut -d' ' -f 6) 
DIFF=$(((FREE_DISKBLOCKS_START-FREE_DISKBLOCKS_END)/2048))
echo -e "\n   $DIFF MB of disk space consumed during this script run." >>$LOGFILE
# 380691344 / 182G = 2091710.681318681318681 blocks per GB
# 182*1024=186368 MB
# 380691344 / 186368 G = 2042 blocks per MB

TIME_END=$(date -u +%s);
DIFF=$((TIME_END-TIME_START))
MSG="End of script after $((DIFF/60))m $((DIFF%60))s seconds elapsed."
fancy_echo "$MSG"
echo -e "\n$MSG" >>$LOGFILE
say "script ended."  # through speaker
