#!/bin/bash
# This is git-basics.sh from https://github.com/wilsonmar/git-utilities
# by WilsonMar@gmail.com
# Described in https://github.com/wilsonmar/git-utilities/blob/master/git-basics.sh

# This script performs the most common actions resulting in the various statuses,
# so you can make changes and see the effect.
# Remember to chmod +x git-basics.sh first, then paste this command in your terminal
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/git-utilities/master/git-basics.sh)"

RUNTYPE=""
       # remove
       # upgrade
       # reset  (to wipe out files saved in git-utilities)
       # reuse (previous version of repository)

function fancy_echo() {
  local fmt="$1"; shift
  printf "\\n    >>> $fmt\\n" "$@"
}
function c_echo() {
  local fmt="$1"; shift
  printf "\\n  $ $fmt\\n" "$@"
}
command_exists() {  # newer than which {command}
  command -v "$@" > /dev/null 2>&1
}

clear

fancy_echo "1.1 Local machine metadata ..."

# For Git on Windows, see http://www.rolandfg.net/2014/05/04/intellij-idea-and-git-on-windows/
TIME_START="$(date -u +%s)"
FREE_DISKBLOCKS_START="$(df | sed -n -e '2{p;q}' | cut -d' ' -f 6)"

LOG_PREFIX=$(date +%Y-%m-%dT%H:%M:%S%z)-$((1 + RANDOM % 1000))
   # ISO-8601 date plus RANDOM=$((1 + RANDOM % 1000))  # 3 digit random number.
   #  LOGFILE="$0.$LOG_PREFIX.log"
c_echo "$0 starting at $LOG_PREFIX ..."

### OS detection:
c_echo "uname -a "
   echo -e "$(uname -a)"

platform='unknown'
unamestr=$( uname )
if [[ "$unamestr" == 'Darwin' ]]; then
            platform='macos'
elif [[ "$unamestr" == 'Linux' ]]; then
              platform='linux'
elif [[ "$unamestr" == 'FreeBSD' ]]; then
              platform='freebsd'
elif [[ "$unamestr" == 'MINGW64_NT-6.1' ]]; then  # git bash on Windows 10
              platform='windows'  # systeminfo on windows https://en.wikipedia.org/wiki/MinGW
fi
echo "I'm $unamestr = $platform"


if [[ $platform == 'macos' ]]; then

   c_echo "sw_vers "
      echo -e "$(sw_vers)"

   fancy_echo "1.2 Ensure Homebrew client is installed ..."
   # Remove to be done manually.
   if ! command_exists brew ; then
       RUBY_VERSION="$(ruby --version)"
       fancy_echo "1.2 Installing homebrew using in-built $RUBY_VERSION ..." 
       ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
       brew tap caskroom/cask
   else
       # Upgrade if run-time attribute contains "upgrade":
       if [[ "${RUNTYPE}" == *"update"* ]]; then
          BREW_VERSION="$(brew --version | grep "Homebrew ")"
          fancy_echo "1.2 Brew upgrading $BREW_VERSION ..." 
          brew update 
       fi
   fi
   echo "$(brew --version)"


   if ! command_exists git ; then
     if [[ $platform == 'macos' ]]; then
       fancy_echo "1.3 Installing git using Homebrew ..." 
       brew install git
     fi
   fi
       GIT_VERSION="$( git --version )"
       fancy_echo "1.3 $GIT_VERSION installed ..."


   ## Based on https://hub.github.com/
   if ! command_exists hub ; then
     if [[ $platform == 'macos' ]]; then
         fancy_echo "1.4a brew install hub  # add-in to Git ..."
         brew install hub
     fi
   fi
         HUB_VERSION="$( hub version | grep "hub" )"
         fancy_echo "1.4a $HUB_VERSION already installed for Git to manage GitHub."
fi

exit

###
   cd ~/
fancy_echo "1.5 At $PWD ..."

   if [ ! -f "git-basics.env" ]; then
      fancy_echo "1.5 Downloading git-basics.env from GitHub ..."
      curl -O "https://raw.githubusercontent.com/wilsonmar/git-utilities/master/git-basics.env"
           # 15 bytes Received
   else
      fancy_echo "1.5 Using existing git-basics.env ..."
   fi
c_echo "source git-basics.env"
        source git-basics.env

   echo "GITHOST=$GITHOST"               # "github.com" or "gitlab.com"
   echo "MYACCT_USER_NAME=$MYACCT_USER_NAME"     # "Wilson Mar"
   echo "MYACCT_USER_EMAIL=$MYACCT_USER_EMAIL"   # "wilsonmar+GitHub@gmail.com"
   echo "WORKSPACE_FOLDER=$WORKSPACE_FOLDER" # git-basics-workspace"
   echo "MYACCT_USERID=$MYACCT_USERID" # wilsonmar
  #echo "MYACCT_PASSWORD should never be displayed.
   echo "SAMPLE_REPO=$SAMPLE_REPO" # local-init
   echo "OTHER_ACCT=$OTHER_ACCT"   # hotwilson"
   echo "OTHER_REPO=$OTHER_REPO"   # some-repo"
   echo "NEW_BRANCH=$NEW_BRANCH"   # feat1"

  # Assign userid to be GitHub ID if not changed:
  MAC_USERID=$(id -un 2>/dev/null || true)  # example: wilsonmar
    #   echo "MAC_USERID=$MAC_USERID"
   if [[ "$MYACCT_USERID" != "wilsonmar" ]]; then # it was changed.
      fancy_echo "1.6 Hello $MYACCT_USERID" 
#   elif [[ "$MAC_USERID" == *"$MYACCT"* ]]; then
#      fancy_echo "1.6 $MAC_USERID == $MYACCT"
   else
      fancy_echo "1.6 Assuming \"$MAC_USERID\" is your GitHub and Gmail account ..."
      MYACCT_USERID="$MAC_USERID"
      MYACCT_USER_NAME="$MAC_USERID"
      MYACCT_USER_EMAIL="$MAC_USERID@gmail.com"
   echo "MYACCT_USERID=$MYACCT_USERID"           # wilsonmar
   echo "MYACCT_USER_NAME=$MYACCT_USER_NAME"     # "Wilson Mar"
   echo "MYACCT_USER_EMAIL=$MYACCT_USER_EMAIL"   # "wilsonmar+GitHub@gmail.com"
   fi


fancy_echo "1.6 Create persistent folder git-scripts in $PWD ..."

      if [ ! -d "git-scripts" ]; then
         c_echo "mkdir git-scripts && cd git-scripts"
                 mkdir git-scripts && cd git-scripts
#      else
#           # if flagged to do it:
#           rm -rf git-scripts
#           mkdir git-scripts
      fi


### 
   if [ ! -f "git-basics.sh" ]; then
      fancy_echo "1.7 Downloading git-basics.sh from GitHub for next run ..."
      curl -O "https://raw.githubusercontent.com/wilsonmar/git-utilities/master/git-basics.sh"
           # 10835 bytes Received
   else
      fancy_echo "1.7 Using existing git-basics.sh ..."
   fi
   ls -al git-basics.sh


#fancy_echo "1.8 To halt processing for customizations, press control+c or "
#read -rsp $'1.8 press any key to continue default processing ...\n' -n 1 key
# Comment the above two lines out when you're editing this script for local run.

   ALIAS_FILENAME="aliases.txt"
   if [ ! -f "$ALIAS_FILENAME" ]; then
      fancy_echo "1.9 Downloading $ALIAS_FILENAME from GitHub ..."
      curl -O "https://raw.githubusercontent.com/wilsonmar/git-utilities/master/$ALIAS_FILENAME"
           # 1727 bytes Received
   else
      fancy_echo "1.9 Using existing $ALIAS_FILENAME ..."
   fi

   BASHFILE="$HOME/.bash_profile"
      if [ ! -f "$BASHFILE" ]; then
         fancy_echo "1.10 $BASHFILE not found. Creating it ..."
         # echo "Created by git-basics.sh" >>$BASHFILE
      else
         fancy_echo "1.10 $BASHFILE found ..."
         ls -al "$BASHFILE"  # 9462 bytes
      fi


   if grep "$ALIAS_FILENAME" "$BASHFILE" ; then # already in file:
      fancy_echo "1.11 $ALIAS_FILENAME already found in $BASHFILE."
   else
      fancy_echo "1.11 Concatenating aliases file $ALIAS_FILENAME into $BASHFILE ..."
      ls -al "$BASHFILE" 
      ls -al "$ALIAS_FILENAME" 
      echo "$ALIAS_FILENAME" >>"$BASHFILE"
      c_echo "source \"$BASHFILE\" "
              source  "$BASHFILE"  # requires password.
# ./git-basics.sh: line 143: ~/.bash_profile: No such file or directory
   fi 

fancy_echo "1.12 Volatile WORKSPACE_FOLDER=$WORKSPACE_FOLDER ..."
   # Delete folder from last run:
   cd ~/
       rm -rf "$WORKSPACE_FOLDER"
       mkdir  "$WORKSPACE_FOLDER"
          cd  "$WORKSPACE_FOLDER"
c_echo "cd \$WORKSPACE_FOLDER"
        echo "at pwd=$PWD ..."


fancy_echo "2.1 Git Config ..."

fancy_echo "2.1 Attribution for git commits ..."
c_echo "git config --global user.name \"MYACCT_USER_NAME\""
        git config --global user.name "$MYACCT_USER_NAME"
      # git config --global user.name "wilson Mar"

c_echo "git config --global user.email \"$MYACCT_USER_EMAIL\""
        git config --global user.email  "$MYACCT_USER_EMAIL"
      # git config --global user.email "wilsonmar+GitHub@gmail.com"

fancy_echo "2.2 sample global git config..."
c_echo "git config --global core.safecrlf false"
        git config --global core.safecrlf false

fancy_echo "2.3 git config --list  # (could be a long file) ..."
# git config --list

fancy_echo "2.4 NO Create gits folder ..."

fancy_echo "2.5 NO myacct container ..."



fancy_echo "3.1 ssh-keygen is done manually, just once."

c_echo "ls -a ~/.ssh"
        ls -a ~/.ssh



fancy_echo "3.4 Use hub to clone \"$OTHER_ACCT/$OTHER_REPO\" ..."
c_echo "cd && cd \"$WORKSPACE_FOLDER\" "
        cd && cd  "$WORKSPACE_FOLDER"

c_echo "hub clone \"$OTHER_ACCT/$OTHER_REPO\""
      hub clone "$OTHER_ACCT/$OTHER_REPO" # hotwilson/some-repo"
c_echo "cd \"$OTHER_REPO\" && PWD && git remote -v && ls -al ..."
      cd "$OTHER_REPO"
      echo "PWD=$PWD"
      git remote -v
      ls -al

fancy_echo "3.5 Use hub to fork \"$OTHER_ACCT/$OTHER_REPO\" ..."
c_echo "hub fork \"$OTHER_ACCT/$OTHER_REPO\""
        hub fork  "$OTHER_ACCT/$OTHER_REPO" 

c_echo "cd \"$OTHER_REPO\" && PWD && git remote -v && ls -al ..."
      cd "$OTHER_REPO"
      echo "PWD=$PWD"
      git remote -v
      ls -al

c_echo "hub remote add \"$MYACCT_USERID\""
        hub remote add  "$MYACCT_USERID"  # wilsonmar

c_echo "git remote rename origin upstream"
        git remote rename origin upstream

c_echo "git remote rename "$MYACCT_USERID" origin"
        git remote rename "$MYACCT_USERID" origin

c_echo "git pull --all"
        git pull --all

fancy_echo "3.5 git remote -v"
                git remote -v

fancy_echo "3.6 Manually see the fork in your cloud account  ..."
#         read -rsp $'Press any key after deleting ...\n' -n 1 key

# 1. fork https://github.com/hotwilson/some-repo to wilsonmar

#fancy_echo "4.2 git clone $MYACCT_USERID/$SAMPLE_REPO ..."
# if RUNTYPE != "reuse"
#   git clone "git@github.com:$MYACCT_USERID/$SAMPLE_REPO" --depth=1

fancy_echo "3.7 cd into repo $MYACCT_USERID/$SAMPLE_REPO ..."
        cd "$SAMPLE_REPO"
        echo "PWD=$PWD"

fancy_echo "3.8 ls -al files and folders at $PWD ..."
                ls -al

fancy_echo "3.9 git remote -v = remote ..."
                git remote -v

fancy_echo "3.10 git branch -avv (to list master ..."
                 git branch -avv


fancy_echo "4.1 Checkout new branch ..."
       c_echo "git checkout -b \"$NEW_BRANCH\""
               git checkout -b  "$NEW_BRANCH"

fancy_echo "4.2 git branch -avv"
                git branch -avv

fancy_echo "4.3 Add and configure .gitignore file ..."

c_echo "echo \"peace\" >newfile.md"
        echo  "peace"  >newfile.md

   if [ ! -d ".gitignore" ]; then # NOT found:
      c_echo "touch .gitignore"
              touch .gitignore
   fi

   if ! grep -q ".DS_Store" ".gitignore" ; then # NOT in file :
      c_echo "echo -e \".DS_Store\" >>.gitignore"
              echo -e "\n.DS_Store" >>.gitignore
   fi

fancy_echo "4.4 tail -3 .gitignore to view last 3 lines of contents:"
                tail -3 .gitignore

fancy_echo "4.5 git status -s -b [gsl]"
                git status -s -b


fancy_echo "5.1 cat .git/config  # attribution for local repo"
                cat .git/config

fancy_echo "5.2 git diff --cached"
                git diff --cached

fancy_echo "5.3 git add . -A "
                git add . -A

fancy_echo "5.4 git diff --cached"
                git diff --cached

fancy_echo "5.5 git status -s -b [gsl] again"
                git status -s -b

fancy_echo "5.6 git log origin..HEAD"
                git log origin..HEAD

fancy_echo "5.7 git commit -m\"Add .DS_Store to .gitignore @$OTHER_ACCT\" "
                git commit -m "Add .DS_Store to .gitignore @$OTHER_ACCT"

fancy_echo "5.8 git reflog -5"
                git reflog -5

fancy_echo "5.9 git log --oneline -5"  # | tail -n 10 
                git log --oneline -5
              # git log --pretty=format:"%h %s %ad" --graph --date=relative

#fancy_echo "5.10 git rebase -i is optional"
 

fancy_echo "6.1 git push origin $NEW_BRANCH"
                git push origin "$NEW_BRANCH"

# TODO: Stop if above not successful.

#  To get rid of tag from prior run, manually delete repo and
#  Fork again. This is not working:
#fancy_echo "6.2 git push --tag origin :v1.2.3  # : to remove tag in cloud"
#                git push --tag origin :v1.2.3

fancy_echo "6.3 git tag -a v1.2.3 -m \"New version\" "
                git tag -a v1.2.3 -m  "New version"
# See annotated tag https://git-scm.com/book/en/v2/Git-Basics-Tagging

fancy_echo "6.4 git push origin --tags"
                git push origin --tags

# TODO: Stop if above not successful.

fancy_echo "6.5 git checkout master "
                git checkout master

fancy_echo "6.6 git branch -D feat1  # to remove locally"
                git branch -D "$NEW_BRANCH"

fancy_echo "6.7 git push origin :feat1  # to remove in cloud"
                git push origin :"$NEW_BRANCH"


# Check manually on GitHub for new tag.

fancy_echo "7.1 On origin   $MYACCT_USERID/$OTHER_REPO, create a Pull/Merge Request."
fancy_echo "7.2 On upstream $OTHER_CCT/$OTHER_REPO, Squash and merge."
fancy_echo "7.3 In upstream $OTHER_ACCT/$OTHER_REPO, Add file."
         read -rsp $'Press any key after creating a new file in that repo ...\n' -n 1 key
         # See https://unix.stackexchange.com/questions/134437/press-space-to-continue
         # See https://stackoverflow.com/questions/92802/what-is-the-linux-equivalent-to-dos-pause


fancy_echo "8.2 git remote add upstream https://$GITHOST/$OTHER_ACCT/$OTHER_REPO ..."
                git remote add upstream "https://$GITHOST/$OTHER_ACCT/$OTHER_REPO"
    echo ">>> No output expected."

fancy_echo "8.3 git remote -v "
                git remote -v  

fancy_echo "8.4a git fetch upstream master --dry-run  # not all branches"
                 git fetch upstream master --dry-run

fancy_echo "8.4b git fetch upstream master # not all branches"
                 git fetch upstream master

fancy_echo "8.5 git checkout master "
                git checkout master

fancy_echo "8.6 git diff HEAD @{u} --name-only"
                git diff HEAD @{u} --name-only

fancy_echo "8.7 git merge upstream/master -m\"8.7\""
                git merge upstream/master -m "8.7"

fancy_echo "8.8 git push origin master"
                git push origin master


fancy_echo "9.1 Change something on the origin in GitHub $MYACCT_USERID/$OTHER_REPO ..."
         read -rsp $'Press any key after adding a file ...\n' -n 1 key

fancy_echo "9.2 git fetch origin" 
                git fetch origin

fancy_echo "9.3 git diff master..origin/master"
                git diff master..origin/master
                #gitk master..origin/master

fancy_echo "9.4 git merge origin/master -m\"9.4 thank you\" --no-edit"
                git merge origin/master -m "9.4 thank you"  --no-edit

fancy_echo "9.5 git diff master..origin/master  # again to verify"
                git diff master..origin/master

FREE_DISKBLOCKS_END=$(df | sed -n -e '2{p;q}' | cut -d' ' -f 6) 
DIFF=$(((FREE_DISKBLOCKS_START-FREE_DISKBLOCKS_END)/2048))
# 380691344 / 182G = 2091710.681318681318681 blocks per GB
# 182*1024=186368 MB
# 380691344 / 186368 G = 2042 blocks per MB

TIME_END=$(date -u +%s);
DIFF=$((TIME_END-TIME_START))
MSG="End of script after $((DIFF/60))m $((DIFF%60))s seconds elapsed."
fancy_echo "$MSG and $DIFF MB disk space consumed."
#say "script ended."  # through speaker
