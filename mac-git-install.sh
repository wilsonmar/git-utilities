#!/bin/bash
# From mac-git-install.sh in https://github.com/wilsonmar/git-utilities

set -a

fancy_echo() {
  local fmt="$1"; shift
  # shellcheck disable=SC2059
  printf "\n>>> $fmt\n" "$@"
}

# TODO: For Mac only
fancy_echo "This is for Mac only!"

######### Git command completion in Terminal:
# So you can type "git st" and press Tab to complete as "git status".
# See video on this: https://www.youtube.com/watch?v=VI07ouVS5FE
# If git-completion.bash file is already in home folder, download it:
FILE=.git-completion.bash
FILEPATH=~/.git-completion.bash
if [ -f $FILEPATH ]; then 
   # list file to confirm size:
   ls -al $FILEPATH
      # -rw-r--r--  1 wilsonmar  staff  68619 Mar 21 10:31 /Users/wilsonmar/.git-completion.bash
#   rm -rf $FILE
else
   # Download in home directory the file maintained by git people:
   curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o $FILEPATH
   # alt # cp $FILE  ~/$FILEPATH
fi

# show first line of file:
# line=$(read -r FIRSTLINE < ~/.git-completion.bash )


# If git-completion.bash file is mentioned in  ~/.bash_profile, add it:
INFILE=~/.bash_profile
if grep -q "$FILEPATH" "$INFILE" ; then    
   fancy_echo "$FILE already in $INFILE"
else
   fancy_echo "Adding code for $FILE in $INFILE..."
   echo "# Added by mac-git-install.sh ::"
   echo "if [ -f $FILEPATH ]; then" >>$INFILE
   echo "   . $FILEPATH" >>$INFILE
   echo "fi" >>$INFILE
   # Run .bash_profile to have changes take, run $FILEPATH:
   source $INFILE
fi 


######### Git command coloring:

# If git config color.ui returns true, skip:
git config color.ui | grep 'true' &> /dev/null
if [ $? == 0 ]; then
   fancy_echo "git config --global color.ui already true (on)."
else # false or blank response:
   fancy_echo "Setting git config --global color.ui true (on)..."
   git config --global color.ui true
fi

######### SSH-KeyGen:
RANDOM=$((1 + RANDOM % 1000))  # 5 digit random number.
FILE="$(uname -n)-$RANDOM"  # computer node name.
FILEPATH="~/.ssh/$FILE"
if [ -f "$FILEPATH" ]; then # found:
   fancy_echo "File \"${FILEPATH}\" already exists. Run Aborted."
   exit
else
   fancy_echo "ssh-keygen creating \"${FILEPATH}\" instead of id_rsa ..."
   cd ~/.ssh
   ssh-keygen -f "${FILE}" -t rsa -N ''
      # -Comment, -No passphrase or -P
   fancy_echo "Now copy contents of \"${FILEPATH}.pub\", "
   echo "and paste into GitHub/BitBucket..."
fi





######### Signing:

# Check if gpg has been installed:

