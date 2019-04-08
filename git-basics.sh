#!/bin/bash
# This is git-basics.sh within https://github.com/wilsonmar/git-utilities
# by WilsonMar@gmail.com
# To minimize troubleshooting, this script "types" what the reader is asked to manually type in the tutorial at
# https://wilsonmar.github.io/git-basics
# chmod +x git-basics.sh | then copy this command to paste in your terminal:
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/git-utilities/master/git-basics.sh)"

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

RUNTYPE=""
       # remove
       # upgrade
       # reset  (to wipe out files saved in git-utilities)
       # reuse (previous version of repository)
 
# A description of these Bash generic code is at https://wilsonmar.github.io/

### Set color variables (based on aws_code_deploy.sh): 
bold="\e[1m"
dim="\e[2m"
underline="\e[4m"
blink="\e[5m"
reset="\e[0m"
red="\e[31m"
green="\e[32m"
blue="\e[34m"

### Generic functions used across bash scripts:
function echo_f() {  # echo fancy comment
  local fmt="$1"; shift
  printf "\\n    >>> $fmt\\n" "$@"
}
function echo_g() {  # echo fancy comment
  local fmt="$1"; shift
  printf "        $fmt\\n" "$@"
}
function echo_c() {  # echo command
  local fmt="$1"; shift
  printf "\\n  $ $fmt\\n" "$@"
}
command_exists() {  # newer than which {command}
  command -v "$@" > /dev/null 2>&1
}

clear

# For Git on Windows, see http://www.rolandfg.net/2014/05/04/intellij-idea-and-git-on-windows/
TIME_START="$(date -u +%s)"
#FREE_DISKBLOCKS_END=$(df | sed -n -e '2{p;q}' | cut -d' ' -f 6) # no longer works
FREE_DISKBLOCKS_START="$(df -P | awk '{print $4}' | sed -n 2p)"  # e.g. 342771200 from:
   # Filesystem    512-blocks      Used Available Capacity  Mounted on
   # /dev/disk1s1   976490568 611335160 342771200    65%    /
LOG_PREFIX=$(date +%Y-%m-%dT%H:%M:%S%z)-$((1 + RANDOM % 1000))
   # ISO-8601 date plus RANDOM=$((1 + RANDOM % 1000))  # 3 digit random number.
   #  LOGFILE="$0.$LOG_PREFIX.log"
echo_f "1.1 $0 within $PWD "
echo_g "starting at $LOG_PREFIX with $FREE_DISKBLOCKS_START blocks free ..."

### OS detection:
echo_c "uname -a"
unamestr=$( uname )
echo "$unamestr"
UNAME_PREFIX="${unamestr%%-*}" 
              platform='unknown'
if [[ "$unamestr" == 'Darwin' ]]; then
              platform='macos'
elif [[ "$unamestr" == 'Linux' ]]; then
              platform='linux'
elif [[ "$unamestr" == 'FreeBSD' ]]; then
              platform='freebsd'
elif [[ "$UNAME_PREFIX" == 'MINGW64_NT' ]]; then  # MINGW64_NT-6.1 or MINGW64_NT-10 for Windows 10
              platform='windows'  # systeminfo on windows https://en.wikipedia.org/wiki/MinGW
fi
echo "Platform: $platform"


if [[ $platform == 'macos' ]]; then

   echo_c "sw_vers"
      echo -e "$(sw_vers)"
      echo -e "/n$(xcode-select --version)"  # Example: xcode-select version 2354.

   echo_f "1.2 Homebrew:"
   # Remove to be done manually.
   if ! command_exists brew ; then
       RUBY_VERSION="$(ruby --version)"
       echo_f "1.2 Installing homebrew using in-built $RUBY_VERSION ..." 
       ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
       brew tap caskroom/cask
   else
       # Upgrade if run-time attribute contains "upgrade":
       if [[ "${RUNTYPE}" == *"update"* ]]; then
          BREW_VERSION="$(brew --version | grep "Homebrew ")"
          echo_f "1.2 Brew upgrading $BREW_VERSION ..." 
          brew update 
       fi
   fi
   echo "$(brew --version)"


   if ! command_exists git ; then
     if [[ $platform == 'macos' ]]; then
       echo_f "1.3 Installing git using Homebrew ..." 
       brew install git
     fi
   fi
       GIT_VERSION="$( git --version )"
       echo_f "1.3 $GIT_VERSION installed ..."


   ## Based on https://hub.github.com/
   if ! command_exists hub ; then
     if [[ $platform == 'macos' ]]; then
         echo_f "1.4a brew install hub  # add-in to Git ..."
         brew install hub
     fi
   fi
         HUB_VERSION="$( hub version | grep "hub" )"
         echo_f "1.4a $HUB_VERSION already installed for Git to manage GitHub."

# elif [[ $platform == 'linux' ]]; then
   # ubuntu
   # etc.

fi


###
   cd ~/
echo_f "1.5 At $PWD ..."

   if [ ! -f "git-basics.env" ]; then
      echo_f "1.5 Downloading git-basics.env from GitHub ..."
      curl -O "https://raw.githubusercontent.com/wilsonmar/git-utilities/master/git-basics.env"
           # 15 bytes Received
   else
      echo_f "1.5 Using existing git-basics.env ..."
   fi
echo_c "source git-basics.env"
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
      echo_f "1.6 Hello $MYACCT_USERID" 
#   elif [[ "$MAC_USERID" == *"$MYACCT"* ]]; then
#      echo_f "1.6 $MAC_USERID == $MYACCT"
   else
      echo_f "1.6 Assuming \"$MAC_USERID\" is your GitHub and Gmail account ..."
      MYACCT_USERID="$MAC_USERID"
      MYACCT_USER_NAME="$MAC_USERID"
      MYACCT_USER_EMAIL="$MAC_USERID@gmail.com"
   echo "MYACCT_USERID=$MYACCT_USERID"           # wilsonmar
   echo "MYACCT_USER_NAME=$MYACCT_USER_NAME"     # "Wilson Mar"
   echo "MYACCT_USER_EMAIL=$MYACCT_USER_EMAIL"   # "wilsonmar+GitHub@gmail.com"
   fi


echo_f "1.6 Create persistent folder git-scripts in $PWD ..."

      if [ ! -d "git-scripts" ]; then
         echo_c "mkdir git-scripts && cd git-scripts"
                 mkdir git-scripts && cd git-scripts
#      else
#           # if flagged to do it:
#           rm -rf git-scripts
#           mkdir git-scripts
      fi


### 
   # TODO: Replace if requested in env:
   if [ ! -f "git-basics.sh" ]; then
      echo_f "1.7 Downloading git-basics.sh from GitHub for next run ..."
      curl -O "https://raw.githubusercontent.com/wilsonmar/git-utilities/master/git-basics.sh"
           # 10835 bytes Received
   else
      echo_f "1.7 Using existing git-basics.sh ..."
   fi
   ls -al git-basics.sh


#echo_f "1.8 To halt processing for customizations, press control+c or "
#read -rsp $'1.8 press any key to continue default processing ...\n' -n 1 key
# Comment the above two lines out when you're editing this script for local run.

   ALIAS_FILENAME="aliases.bash"
   if [ ! -f "$ALIAS_FILENAME" ]; then
      echo_f "1.9 Downloading $ALIAS_FILENAME from GitHub ..."
      curl -O "https://raw.githubusercontent.com/wilsonmar/git-utilities/master/$ALIAS_FILENAME"
           # 1727 bytes Received
   else
      echo_f "1.9 Using existing $ALIAS_FILENAME ..."
   fi

   BASHFILE="$HOME/.bash_profile"
      if [ ! -f "$BASHFILE" ]; then
         echo_f "1.10 $BASHFILE not found. Creating it ..."
         # echo "Created by git-basics.sh" >>$BASHFILE
      else
         echo_f "1.10 $BASHFILE found ..."
         ls -al "$BASHFILE"  # 9462 bytes
      fi

   if grep "$ALIAS_FILENAME" "$BASHFILE" ; then # already in file:
      echo_f "1.11 $ALIAS_FILENAME already found in $BASHFILE."
   else
      echo_f "1.11 Concatenating aliases file $ALIAS_FILENAME into $BASHFILE ..."
      ls -al "$BASHFILE" 
      ls -al "$ALIAS_FILENAME" 
      echo "$ALIAS_FILENAME" >>"$BASHFILE"
      echo_c "source \"$BASHFILE\" "
              source  "$BASHFILE"  # requires password.
# ./git-basics.sh: line 143: ~/.bash_profile: No such file or directory
   fi 

echo_f "1.12 Volatile WORKSPACE_FOLDER=$WORKSPACE_FOLDER ..."
   # Delete folder from last run:
   cd ~/
       rm -rf "$WORKSPACE_FOLDER"
       mkdir  "$WORKSPACE_FOLDER"
          cd  "$WORKSPACE_FOLDER"
echo_c "cd \$WORKSPACE_FOLDER"
        echo "at pwd=$PWD ..."


echo_f "2.1 Git Config ..."

echo_f "2.1 Attribution for git commits ..."
echo_c "git config --global user.name \"MYACCT_USER_NAME\""
        git config --global user.name "$MYACCT_USER_NAME"
      # git config --global user.name "wilson Mar"

echo_c "git config --global user.email \"$MYACCT_USER_EMAIL\""
        git config --global user.email  "$MYACCT_USER_EMAIL"
      # git config --global user.email "wilsonmar+GitHub@gmail.com"

echo_f "2.2 sample global git config..."
echo_c "git config --global core.safecrlf false"
        git config --global core.safecrlf false

echo_f "2.3 git config --list  # (could be a long file) ..."
# git config --list

# difftool command (after installing DiffMerge) analyzes differences among 3 files
# Per https://sourcegear.com/diffmerge/webhelp/sec__git__mac.html
        git config --global diff.tool diffmerge
        git config --global difftool.diffmerge.cmd "/usr/local/bin/diffmerge \"\$LOCAL\" \"\$REMOTE\""
        git config --global merge.tool diffmerge
        git config --global mergetool.diffmerge.trustExitCode true
        git config --global mergetool.diffmerge.cmd \
        "/usr/local/bin/diffmerge --merge --result=\"\$MERGED\" \
        \"\$LOCAL\" \"\$BASE\" \"\$REMOTE\""

        # Change the font size:
        # open -e "$HOME/Library/Preferences/SourceGear DiffMerge preferences"
        # [file]
        # Font:27:76:consolas

echo_f "2.4 NO Create gits folder ..."

echo_f "2.5 NO myacct container ..."



echo_f "3.1 ssh-keygen is done manually, just once."

echo_c "ls -a ~/.ssh"
        ls -a ~/.ssh

echo_f "3.3 Manually delete $MYACCT_USERID/$OTHER_REPO so this script can create a new one ..."
         read -rsp $'Press any key after deleting the repo ...\n' -n 1 key

echo_f "3.4 Use hub to clone \"$OTHER_ACCT/$OTHER_REPO\" ..."
echo_c "cd && cd \"$WORKSPACE_FOLDER\" "
        cd && cd  "$WORKSPACE_FOLDER"

# Check if repo exists: if you have credentials for it:
# git ls-remote "$OTHER_ACCT/$OTHER_REPO" -q
#    -q if for quieting list of hashes.
# git ls-remote https://github.com/hotwilson/some-repo -q
# Username for 'https://github.com':
# echo $?
# 0 means that the repo was found, otherwise you'll get a non-zero value.
# See https://gist.github.com/salcode/342391ccbaa8cbf48567 = Notes for bash scripting git commands 

echo_c "hub clone \"$OTHER_ACCT/$OTHER_REPO\""
      hub clone "$OTHER_ACCT/$OTHER_REPO" # hotwilson/some-repo"
echo_c "cd \"$OTHER_REPO\" && PWD && git remote -v && ls -al ..."
      cd "$OTHER_REPO"
      echo "PWD=$PWD"
      git remote -v
      ls -al

echo_f "3.5 Use hub to fork \"$OTHER_ACCT/$OTHER_REPO\" ..."
echo_c "hub fork \"$OTHER_ACCT/$OTHER_REPO\""
        hub fork  "$OTHER_ACCT/$OTHER_REPO" 

echo_c "cd \"$OTHER_REPO\" && PWD && git remote -v && ls -al ..."
      cd "$OTHER_REPO"
      echo "PWD=$PWD"
      git remote -v
      ls -al

echo_c "hub remote add \"$MYACCT_USERID\""
        hub remote add  "$MYACCT_USERID"  # wilsonmar

echo_c "git remote rename origin upstream"
        git remote rename origin upstream

echo_c "git remote rename "$MYACCT_USERID" origin"
        git remote rename "$MYACCT_USERID" origin

echo_c "git pull --all"
        git pull --all

echo_f "3.5 git remote -v"
            git remote -v

# 1. fork https://github.com/hotwilson/some-repo to wilsonmar

#echo_f "4.2 git clone $MYACCT_USERID/$SAMPLE_REPO ..."
# if RUNTYPE != "reuse"
#   git clone "git@github.com:$MYACCT_USERID/$SAMPLE_REPO" --depth=1

echo_f "3.7 cd into repo $MYACCT_USERID/$SAMPLE_REPO ..."
        cd "$SAMPLE_REPO"
        echo "PWD=$PWD"

echo_f "3.8 ls -al files and folders at $PWD ..."
                ls -al

echo_f "3.9 git remote -v = remote ..."
                git remote -v

echo_f "3.10 git branch -avv (to list master ..."
                 git branch -avv


echo_f "4.1 Checkout new branch ..."
       echo_c "git checkout -b \"$NEW_BRANCH\""
               git checkout -b  "$NEW_BRANCH"

echo_f "4.2 git branch -avv"
                git branch -avv

echo_f "4.3 Add and configure .gitignore file ..."

echo_c "echo \"peace\" >newfile.md"
        echo  "peace"  >newfile.md

   if [ ! -d ".gitignore" ]; then # NOT found:
      echo_c "touch .gitignore"
              touch .gitignore
   fi

   if ! grep -q ".DS_Store" ".gitignore" ; then # NOT in file :
      echo_c "echo -e \".DS_Store\" >>.gitignore"
              echo -e "\n.DS_Store" >>.gitignore
   fi

echo_f "4.4 tail -3 .gitignore to view last 3 lines of contents:"
                tail -3 .gitignore

echo_f "4.5 git status -s -b [gsl]"
                git status -s -b


echo_f "5.1 cat .git/config  # attribution for local repo"
                cat .git/config

echo_f "5.2 git diff --cached"
                git diff --cached

echo_f "5.3 git add . -A "
                git add . -A

echo_f "5.4 git diff --cached"
                git diff --cached

echo_f "5.5 git status -s -b [gsl] again"
                git status -s -b

echo_f "5.6 git log origin..HEAD"
                git log origin..HEAD

echo_f "5.7 git commit -m\"Add .DS_Store to .gitignore @$OTHER_ACCT\" "
                git commit -m "Add .DS_Store to .gitignore @$OTHER_ACCT"

echo_f "5.8 git reflog -5"
                git reflog -5

echo_f "5.9 git log --oneline -5"  # | tail -n 10 
                git log --oneline -5
              # git log --pretty=format:"%h %s %ad" --graph --date=relative

#echo_f "5.10 git rebase -i is optional"
 

echo_f "6.1 git push origin $NEW_BRANCH"
                git push origin "$NEW_BRANCH"

# TODO: Stop if above not successful.

#  To get rid of tag from prior run, manually delete repo and
#  Fork again. This is not working:
#echo_f "6.2 git push --tag origin :v1.2.3  # : to remove tag in cloud"
#                git push --tag origin :v1.2.3

echo_f "6.3 git tag -a v1.2.3 -m \"New version\" "
                git tag -a v1.2.3 -m  "New version"
# See annotated tag https://git-scm.com/book/en/v2/Git-Basics-Tagging

echo_f "6.4 git push origin --tags"
                git push origin --tags

# TODO: Stop if above not successful.

echo_f "6.5 git checkout master "
                git checkout master

echo_f "6.6 git branch -D feat1  # to remove locally"
                git branch -D "$NEW_BRANCH"

echo_f "6.7 git push origin :feat1  # to remove in cloud"
                git push origin :"$NEW_BRANCH"


# Check manually on GitHub for new tag.

echo_f "7.1 On origin   $MYACCT_USERID/$OTHER_REPO, create a Pull/Merge Request."
echo_f "7.2 On upstream $OTHER_CCT/$OTHER_REPO, Squash and merge."
echo_f "7.3 In upstream $OTHER_ACCT/$OTHER_REPO, Ask maintainter to make a change (add file)."
         read -rsp $'Press any key after creating a new file in that repo ...\n' -n 1 key
         # See https://unix.stackexchange.com/questions/134437/press-space-to-continue
         # See https://stackoverflow.com/questions/92802/what-is-the-linux-equivalent-to-dos-pause


echo_f "8.2 git remote add upstream https://$GITHOST/$OTHER_ACCT/$OTHER_REPO ..."
                git remote add upstream "https://$GITHOST/$OTHER_ACCT/$OTHER_REPO"
    echo ">>> No output expected."

echo_f "8.3 git remote -v "
                git remote -v  

echo_f "8.4a git fetch upstream master --dry-run  # not all branches"
                 git fetch upstream master --dry-run

echo_f "8.4b git fetch upstream master # not all branches"
                 git fetch upstream master

echo_f "8.5 git checkout master "
                git checkout master

echo_f "8.6 git diff HEAD @{u} --name-only"
                git diff HEAD @{u} --name-only

echo_f "8.7 git merge upstream/master -m\"8.7\""
                git merge upstream/master -m "8.7"

echo_f "8.8 git push origin master"
                git push origin master


echo_f "9.1 Change something on the origin in GitHub $MYACCT_USERID/$OTHER_REPO ..."
         read -rsp $'Press any key after adding a file ...\n' -n 1 key

echo_f "9.2 git fetch origin" 
                git fetch origin

echo_f "9.3 git diff master..origin/master"
                git diff master..origin/master
                #gitk master..origin/master

echo_f "9.4 git merge origin/master -m\"9.4 thank you\" --no-edit"
                git merge origin/master -m "9.4 thank you"  --no-edit

echo_f "9.5 git diff master..origin/master  # again to verify"
                git diff master..origin/master

FREE_DISKBLOCKS_END="$(df -P | awk '{print $4}' | sed -n 2p)"
DIFF=$(((FREE_DISKBLOCKS_START-FREE_DISKBLOCKS_END)/2048))
# 380691344 / 182G = 2091710.681318681318681 blocks per GB
# 182*1024=186368 MB
# 380691344 / 186368 G = 2042 blocks per MB

TIME_END=$(date -u +%s);
DIFF=$((TIME_END-TIME_START))
MSG="End of script after $((DIFF/60))m $((DIFF%60))s seconds elapsed"
echo_f "$MSG and $DIFF MB disk space consumed."
#say "script ended."  # through speaker
