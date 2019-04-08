#!/bin/bash
# git-patch.sh
#
# Here is how to create a patch file from one repository to add to another repository.
# Note: Creating a patch provides a log of exactly what is inserted into the target repo. 

# 1. Define variables containing the origin's repos. For example:

   GIT_HOST_FROM="https://github.com"  # git@github.com: for SSH
     GIT_HOST_TO="https://github.com"  # git@github.com: for SSH

   REPO_FROM_ACCOUNT="wilsonmar"
     REPO_TO_ACCOUNT="github-candidate"

   REPO_NAME_FROM="devops-cert-activity-wilsonmar2"
     REPO_NAME_TO="devops-cert-activity-wilsonmar"

   REPO_FROM_CONTAINER="temp/hotwilson"
     REPO_TO_CONTAINER="gits/hotwilson"

     SHA_TO="6e6d819"  # least recent 6e6d819
   SHA_FROM="b0de12f"  # most  recent

   RELOAD_GITHUB_FROM="1"  # 1=YES (remove folder from previous run), 0=No
   RELOAD_GITHUB_TO="1"    # 1=YES, 0=No
   
   PAUSE_FOR_SHA="0"  # 1=YES, 0=No ()

   PATCH_FILE="0new-feature.patch"

# 2. Define utility functions:

#4 Collect starting system information and display on console:
TIME_START="$(date -u +%s)"
#FREE_DISKBLOCKS_END=$(df | sed -n -e '2{p;q}' | cut -d' ' -f 6) # no longer works
FREE_DISKBLOCKS_START="$(df -P | awk '{print $4}' | sed -n 2p)"  # e.g. 342771200 from:
   # Filesystem    512-blocks      Used Available Capacity  Mounted on
   # /dev/disk1s1   976490568 611335160 342771200    65%    /
LOG_PREFIX=$(date +%Y-%m-%dT%H:%M:%S%z)-$((1 + RANDOM % 1000))
   # ISO-8601 date plus RANDOM=$((1 + RANDOM % 1000))  # 3 digit random number.
   #  LOGFILE="$0.$LOG_PREFIX.log"
echo_f "STARTING $0 within $PWD"
echo_c "at $LOG_PREFIX with $FREE_DISKBLOCKS_START blocks free ..."

function echo_f() {  # echo fancy comment
  local fmt="$1"; shift
  printf "\\n    >>> $fmt\\n" "$@"
}
function echo_c() {  # echo command
  local fmt="$1"; shift
  printf "        $fmt\\n" "$@"
}

# 3. Navigate to the origin's repo. For example:

   echo_f "Navigating from PWD=$PWD"
   echo_c "Navigating to REPO_FROM_CONTAINER=$REPO_FROM_CONTAINER"
   # TODO: Delete folder if exists
   # if not there, create it:
      # FIXME: cd 
      # cd "$REPO_FROM_CONTAINER"
   # make "$REPO_FROM_CONTAINER"

   cd ~
   cd "$REPO_FROM_CONTAINER"
   echo_f "Directories now at PWD=$PWD" 
   # list only folders using regular expression - ls -l | egrep '^d'  
   ls -d */

# 4. Delete the folder and download again:

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

# 5. Pause or go:

   if [ $PAUSE_FOR_SHA -eq "1" ]; then  # 1=YES, 0=No
     # By default, pause and list SHA's. 
      git log --oneline
      exit  # to edit this script with SHA values.
   else
      echo_f "SHA_FROM=\"$SHA_FROM\" - SHA_TO=\"$SHA_TO\" "
   fi

# 6. Create a patch file(s):

   echo_f "Create patch file(s) ..."

   # See https://git-scm.com/docs/git-format-patch 
   git format-patch "$SHA_FROM^..$SHA_TO" --stdout > "$PATCH_FILE"
      # NOTE: --stdout > 0new-feature.patch creates a single file from several patch files output.
         # See https://thoughtbot.com/blog/send-a-patch-to-someone-using-git-format-patch
      #git format-patch -1  # for just the lastest commit. See https://thoughtbot.com/blog/send-a-patch-to-someone-using-git-format-patch
   echo_f "List patches ..."
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

      echo_f "List directories:"
      ls -l | egrep '^d'  # list only folders using regular expression
   fi
   cd "$REPO_NAME_TO"
   echo_f "Now at PWD=$PWD"

# 8. Apply patch:   

   echo_f "Patching from $URL_FROM/0*.patch"
   ls -l $URL_FROM/0*.patch

   # See https://git-scm.com/docs/git-am/2.0.0 for options:
   # git am $URL_FROM/0*.patch
      # -3 means trying the three-way merge if the patch fails to apply cleanly
   cat "$URL_FROM/$PATCH_FILE" | git am
   if [ $? -eq 0 ]; then
      echo_f "No error ..."
   else
      echo_f "Error $? from statement. git am --abort --show-current-patch ..."
      git am --abort
#      git am --show-current-patch
   fi

      echo_f "Git log after git am:"
      git log --oneline
         # Note: the SHA of the patch that you merge with git am will not be the same SHA. 
         # However, the commit message text will be intact.


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
