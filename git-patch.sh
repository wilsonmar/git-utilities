#!/bin/bash
# git-patch.sh from https://github.com/wilsonmar/git-utilities
# This creates a patch file from one repository and adds it to another repository.
# Note: Creating a patch provides a log of exactly what is inserted into the target repo. 
# customized based on specification in file secrets.sh within the same repo.
# TODO: https://wilsonmar.github.io/git-patch.md
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/git-utilities/master/git-patch.sh)"

# 1. Define variables containing the origin's repos. For example:

   REPO_FROM_CONTAINER="$HOME/temp/hotwilson"
     REPO_TO_CONTAINER="$HOME/temp/hotwilson"

   GIT_HOST_FROM="https://github.com"  # git@github.com: for SSH
     GIT_HOST_TO="https://github.com"  # git@github.com: for SSH

   REPO_FROM_ACCOUNT="wilsonmar"
     REPO_TO_ACCOUNT="github-candidate"

   REPO_NAME_FROM="devops-cert-activity-wilsonmar2"
     REPO_NAME_TO="devops-cert-activity-wilsonmar"

     SHA_TO="6e6d819"  # least recent 6e6d819
   SHA_FROM="b0de12f"  # most  recent

   # Feature flags:
   RELOAD_GITHUB_FROM="1"  # 1=YES (remove folder from previous run), 0=No
   RELOAD_GITHUB_TO="1"    # 1=YES, 0=No
   
   PAUSE_FOR_SHA="0"  # 1=YES, 0=No ()

   PATCH_FILE="0new-feature.patch"

   REMOVE_REPO_FROM_WHEN_DONE="1" # 0=No (default), "1"=Yes
     REMOVE_REPO_TO_WHEN_DONE="1" # 0=No (default), "1"=Yes

# 2. Define utility functions:

function echo_f() {  # echo fancy comment
  local fmt="$1"; shift
  printf "\\n    >>> $fmt\\n" "$@"
}
function echo_c() {  # echo command
  local fmt="$1"; shift
  printf "        $fmt\\n" "$@"
}

#4 Collect starting system information and display on console:
TIME_START="$(date -u +%s)"
#FREE_DISKBLOCKS_END=$(df | sed -n -e '2{p;q}' | cut -d' ' -f 6) # no longer works
FREE_DISKBLOCKS_START="$(df -P | awk '{print $4}' | sed -n 2p)"  # e.g. 342771200 from:
   # Filesystem    512-blocks      Used Available Capacity  Mounted on
   # /dev/disk1s1   976490568 611335160 342771200    65%    /
LOG_PREFIX=$(date +%Y-%m-%dT%H:%M:%S%z)-$((1 + RANDOM % 1000))
   # ISO-8601 date plus RANDOM=$((1 + RANDOM % 1000))  # 3 digit random number.
   #  LOGFILE="$0.$LOG_PREFIX.log"
echo_f "STARTING $0 from within $PWD ##################################"
echo_c "at $LOG_PREFIX with $FREE_DISKBLOCKS_START blocks free ..."

# 3. Navigate to the origin's repo. For example:

   if [ ! -d "$REPO_FROM_CONTAINER" ]; then
      echo_f "Directory $REPO_FROM_CONTAINER not found. Making it ..."
      cd ~
      mkdir "$REPO_FROM_CONTAINER"
      cd    "$REPO_FROM_CONTAINER"
   else
      echo_f "Navigating from PWD=$PWD to $REPO_FROM_CONTAINER"
      cd ~
      cd    "$REPO_FROM_CONTAINER"
   fi

   if [ ! -d "$REPO_FROM_CONTAINER" ]; then
      echo_f "Error creating directory at PWD=$REPO_FROM_CONTAINER."
      exit
   else
      echo_c "Directories now:"
      ls -d */
   fi

# 4. Delete the folder for download again?

   echo_f "REPO_NAME_FROM=$REPO_NAME_FROM"
   if [ $RELOAD_GITHUB_FROM -eq "1" ]; then  # 1=YES, 0=No
      rm -rf "$REPO_NAME_FROM"  # remove ...   
      echo_f "Cloning $GIT_HOST_FROM/$REPO_FROM_ACCOUNT/$REPO_NAME_FROM ..."
      git clone    "$GIT_HOST_FROM/$REPO_FROM_ACCOUNT/$REPO_NAME_FROM"
      ls -l | egrep '^d'  # list only folders using regular expression
   fi
   cd "$REPO_NAME_FROM"
   URL_FROM="$PWD"
   echo_f "Now at PWD=$URL_FROM"

# 5. Pause or go to identify SHAs:

   if [ $PAUSE_FOR_SHA -eq "1" ]; then  # 1=YES, 0=No
     # By default, pause and list SHA's. 
      git log --oneline
      exit  # to edit this script with SHA values.
   else
      echo_f "SHA_FROM=\"$SHA_FROM\" - SHA_TO=\"$SHA_TO\" "
      git log --oneline
   fi

# 6. Create patch message file(s):

   echo_f "Creating git patch message file $PATCH_FILE ..."
   git format-patch "$SHA_FROM^..$SHA_TO" --stdout > "$PATCH_FILE"
      # See https://git-scm.com/docs/git-format-patch 
      # NOTE: --stdout > 0new-feature.patch creates a single file from several patch files output.
         # See https://thoughtbot.com/blog/send-a-patch-to-someone-using-git-format-patch
      #git format-patch -1  # for just the lastest commit. See https://thoughtbot.com/blog/send-a-patch-to-someone-using-git-format-patch
   ls -al *.patch
      # 0001-reset-for-secret-new-Gemfile.patch

      # -1 for a single commit SHA or
      # "$SHA_FROM^..$SHA_TO" for a range of commits.

   # Exit if file created not found:

# 7. Navigate to the target repo:

   cd ..
   echo_f "REPO_TO at $PWD/$REPO_NAME_TO"
   if [ $RELOAD_GITHUB_TO -eq "1" ]; then  # 1=YES, 0=No
      rm -rf "$REPO_NAME_TO"  # remove ...   
      echo_f "Cloning $GIT_HOST_TO/$REPO_TO_ACCOUNT/$REPO_NAME_TO ..."
      git clone    "$GIT_HOST_TO/$REPO_TO_ACCOUNT/$REPO_NAME_TO"

      echo_f "Directories within $REPO_TO_CONTAINER :"
      ls -l | egrep '^d'  # list only folders using regular expression
   fi
   cd "$REPO_NAME_TO"
   echo_f "Now at PWD=$PWD"
# 8. Verify .git/hooks actions for 

   # See https://wilsonmar.github.io/git-hooks
   # applypatch-msg, pre-applypatch, and post-applypatch.   
   if [ -f ".git/hooks/applypatch-msg" ]; then
      echo_f "Beware .git/hooks/applypatch-msg specifies:"
      cat .git/hooks/applypatch-msg
   fi

   if [ -f ".git/hooks/pre-applypath" ]; then
      echo_f "Beware .git/hooks/pre-applypath specifies:"
      cat .git/hooks/pre-applypath
   fi

   if [ -f ".git/hooks/post-applypatch" ]; then
      echo_f "Beware .git/hooks/post-applypatch specifies:"
      cat .git/hooks/post-applypatch
   fi

# 9. Apply patch:

   # TODO: Move patch files to TO repo folder?

   echo_f "Using git am to apply patch file $URL_FROM/$PATCH_FILE"
   ls -l $URL_FROM/$PATCH_FILE   # not 0*.patch

   # See https://git-scm.com/docs/git-am/2.0.0 for options:
   # git am $URL_FROM/0*.patch # doesn't read all files and issues errors.
      # -3 means trying the three-way merge if the patch fails to apply cleanly
   cat "$URL_FROM/$PATCH_FILE" | git am --ignore-space-change --ignore-whitespace
   if [ $? -eq 0 ]; then
      echo_f "No error in $? status returned."
   else
      echo_f "Error $? from statement. git am --abort --show-current-patch ..."
      git am --abort
#      git am --show-current-patch
   fi
      echo_f "Git log of new SHAs in $REPO_NAME_TO after messages applied:"
      git log --oneline
         # Note: the SHA of the patch that you merge with git am will not be the same SHA. 
         # However, the commit message text will be intact.

# 10. TODO: Create pull request in GitHub
   # Using hub: https://www.skcript.com/svr/cli-pr-pull-request-command-line-github/
   # Using GitHub API: See https://gist.github.com/devongovett/10399980
   # Using GitHub API: See https://github.com/wjmelements/scripts#cpr

# 11. Remove folders

   if [ "$REMOVE_REPO_FROM_WHEN_DONE" -eq "1" ]; then  # 0=No (default), "1"=Yes
      echo_f "Removing $URL_FROM/$PATCH_FILE as REMOVE_REPO_FROM_WHEN_DONE=$REMOVE_REPO_FROM_WHEN_DONE"
      rm -rf  "$REPO_TO_CONTAINER/$REPO_NAME_FROM"
      # Verify:
      if [ -d "$REPO_FROM_CONTAINER/$REPO_NAME_FROM" ]; then
         FOLDER_DISK_SPACE="$(du -hs)"
         echo_f "WARNING: $FOLDER_DISK_SPACE folder still at $REPO_FROM_CONTAINER/$REPO_NAME_FROM."
         ls -al
      fi
   else
      if [ -d "$REPO_FROM_CONTAINER/$REPO_NAME_FROM" ]; then
         FOLDER_DISK_SPACE="$(du -hs)"
         echo_f "WARNING: $FOLDER_DISK_SPACE folder remains at $REPO_FROM_CONTAINER/$REPO_NAME_FROM."
      else
         echo_f "Folder no longer at $REPO_FROM_CONTAINER/$REPO_NAME_FROM."
      fi
   fi

   if [ "$REMOVE_REPO_TO_WHEN_DONE" -eq "1" ]; then  # 0=No (default), "1"=Yes
      echo_f "Removing $REPO_TO_CONTAINER/$REPO_NAME_TO as REMOVE_REPO_TO_WHEN_DONE=$REMOVE_REPO_TO_WHEN_DONE"
      rm -rf  "$REPO_TO_CONTAINER/$REPO_NAME_TO"
      if [ -d "$REPO_TO_CONTAINER/$REPO_NAME_TO" ]; then
         FOLDER_DISK_SPACE="$(du -hs)"
         echo_f "WARNING: $FOLDER_DISK_SPACE folder still at $REPO_TO_CONTAINER/$REPO_NAME_TO."
         ls -al
      fi
   else
      if [ -d "$REPO_TO_CONTAINER/$REPO_NAME_TO" ]; then
         FOLDER_DISK_SPACE="$(du -hs)"
         echo_f "WARNING: $FOLDER_DISK_SPACE folder remains at $REPO_TO_CONTAINER/$REPO_NAME_TO."
      else
         echo_f "Folder no longer at $REPO_TO_CONTAINER/$REPO_NAME_TO."
      fi
   fi


### References

# https://stackoverflow.com/questions/3816040/git-apply-changes-introduced-by-commit-in-one-repo-to-another-repo/3816292#3816292
# https://stackoverflow.com/questions/5120038/is-it-possible-to-cherry-pick-a-commit-from-another-git-repository/9507417#9507417


#########

#18 Calculate and display end of run statistics:
FREE_DISKBLOCKS_END="$(df -P | awk '{print $4}' | sed -n 2p)"
DIFF=$(((FREE_DISKBLOCKS_START-FREE_DISKBLOCKS_END)/2048))
# 380691344 / 182G = 2091710.681318681318681 blocks per GB
# 182*1024=186368 MB
# 380691344 / 186368 G = 2042 blocks per MB
TIME_END=$(date -u +%s);
DIFF=$((TIME_END-TIME_START))
MSG="End of script after $((DIFF/60))m $((DIFF%60))s elapsed"
echo_f "$MSG and $DIFF MB disk space consumed."
#say "script ended."  # through speaker
