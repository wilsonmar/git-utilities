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

fancy_echo "Configure Terminal to show all files:"
defaults write com.apple.finder AppleShowAllFiles YES


# Ensure Apple's command line tools (such as cc) are installed:
if ! command -v cc >/dev/null; then
  fancy_echo "Installing Apple's xcode command line tools ..."
  xcode-select --install 
else
  fancy_echo "Mac OSX Xcode already installed:"
fi
pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep version
#swift --version

###### Install homebrew using whatever Ruby is installed.

# Ruby comes with MacOS:
ruby -v  # ruby 2.5.0p0 (2017-12-25 revision 61468) [x86_64-darwin16]

#brew tap caskroom/cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

if ! command -v brew >/dev/null; then
    fancy_echo "Installing homebrew using Ruby..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    fancy_echo "Brew already installed:"
fi
brew --version


if ! command -v git >/dev/null; then
    fancy_echo "Installing git using Homebrew ..."
    brew install git
else
    fancy_echo "Git already installed, upgrading ..."
    # To avoid response "Error: git not installed" to brew upgrade git
    brew uninstall git
    # NOTE: This does not remove .gitconfig file.
    brew install git
fi
git --version
    # git version 2.14.3 (Apple Git-98)


######### Git command completion in ~/.bash_profile:
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

# if internet download fails, use saved copy in GitHub repo:
if [ ! -f $FILEPATH ]; then 
   cp $FILE  $FILEPATH
fi

# show first line of file:
# line=$(read -r FIRSTLINE < ~/.git-completion.bash )


######### Read .secrets file:
source .secrets
# $GIT_NAME = 
# $GIT_ID = 
# GIT_EMAIL=

GITCONFIG=~/.gitconfig
if [ ! -f "$GITCONFIG" ]; then 
   fancy_echo "Git is not configured with $GITCONFIG! Exiting..."
   exit
fi

# ~/.gitconfig file contains:
#[user]
#	name = Wilson Mar
#	id = WilsonMar+GitHub@gmail.com
#	email = wilsonmar+github@gmail.com
#[color]
#	ui = true


if grep -q "[user]" "$GITCONFIG" ; then
   fancy_echo "[user] already defined in ~/.gitconfig"
else
   fancy_echo "Adding [user] info in in $GITCONFIG ..."
   git config --global user.name  $GIT_NAME
   git config --global user.email $GIT_ID
   git config --global user.email $GIT_EMAIL
fi 


######### Git Signing:
# NOTE: gpg is the command even though the package is gpg2:
if ! command -v gpg >/dev/null; then
  fancy_echo "Installing GPG2 for commit signing..."
  brew install gpg2
else
  fancy_echo "GPG2 already installed, upgrading ..."
  brew upgrade gpg2
fi
gpg2 --version  # outputs many lines!

# Mac users can store GPG key passphrase in the Mac OS Keychain using the GPG Suite:
# https://gpgtools.org/

# TODO: Check to see if an key has already been generated:


# See https://help.github.com/articles/generating-a-new-gpg-key/
  fancy_echo "Generate a GPG2 pair in batch mode ..."
  # Instead of manual: gpg --full-generate-key
  # See https://superuser.com/questions/1003403/how-to-use-gpg-gen-key-in-a-script
  # And https://gist.github.com/woods/8970150
  # And http://www.gnupg.org/documentation/manuals/gnupg-devel/Unattended-GPG-key-generation.html
cat >foo <<EOF
     %echo Generating a default key
     Key-Type: default
     Subkey-Type: default
     Name-Real: $GIT_NAME
     Name-Comment: 2 long enough passphrase
     Name-Email: $GIT_EMAIL
     Expire-Date: 0
     Passphrase: abc
     # Do a commit here, so that we can later print "done" :-)
     %commit
     %echo done
EOF
  gpg  --batch --genkey foo

exit

# List GPG keys for which you have both a public and private key:
#gpg --list-secret-keys --keyid-format LONG
   # RESPONSE FIRST TIME: gpg: /Users/wilsonmar/.gnupg/trustdb.gpg: trustdb created
   # RESPONSE AFTER a key is created:
   # Capture "3AA5C34371567BD2" from:
   # sec   4096R/3AA5C34371567BD2 2016-03-10 [expires: 2017-03-10]
#git config --global user.signingkey 3AA5C34371567BD2


# https://help.github.com/articles/telling-git-about-your-gpg-key/


# See https://help.github.com/articles/signing-commits-using-gpg/
# To sign all commits by default in any local repository on your computer, run:
# git config --global commit.gpgsign true
# Configure Git client to sign commits by default for a local repository, run:
# git config commit.gpgsign true. 


######### Bash.profile configuration:

# If git-completion.bash file is mentioned in  ~/.bash_profile, add it:
BASHFILE=~/.bash_profile

# Check if file is present: ~/.bash_profile
if [ ! -f "$BASHFILE" ]; then #  NOT found:
   fancy_echo "Creating blank \"${BASHFILE}\" ..."
   touch $BASHFILE
fi

if grep -q "$FILEPATH" "$BASHFILE" ; then    
   fancy_echo "$FILEPATH already in $BASHFILE"
else
   fancy_echo "Adding code for $FILEPATH in $BASHFILE..."
   echo "# Added by mac-git-install.sh ::"
   echo "if [ -f $FILEPATH ]; then" >>$BASHFILE
   echo "   . $FILEPATH" >>$BASHFILE
   echo "fi" >>$BASHFILE
fi 

# If git-completion.bash file is mentioned in  ~/.bash_profile, add it:
if grep -q "$FILEPATH" "$BASHFILE" ; then    
   fancy_echo "$FILEPATH already in $BASHFILE"
else
   fancy_echo "Concatenating code for $FILEPATH in $BASHFILE..."
   cat $FILEPATH >>$BASHFILE
fi 

# If GPG suite is not used, add the GPG key to ~/.bash_profile:
if grep -q "GPG_TTY" "$BASHFILE" ; then    
   fancy_echo "GPG_TTY already in $BASHFILE."
else
   fancy_echo "Concatenating GPG_TTY export in $BASHFILE..."
   echo 'export GPG_TTY=$(tty)' >> $BASHFILE
      # echo $(tty) results in: -bash: /dev/ttys003: Permission denied
fi 


# Run .bash_profile to have changes take, run $FILEPATH:
   source $BASHFILE


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
#RANDOM=$((1 + RANDOM % 1000))  # 5 digit random number.
#FILE="$USER@$(uname -n)-$RANDOM"  # computer node name.
FILE="$USER@$(uname -n)"  # computer node name.
   fancy_echo "Diving into folder ~/.ssh ..."
   pushd ~/.ssh  # specification of folder didn't work.
FILEPATH="~/.ssh/$FILE"
if [ -f "$FILE" ]; then # found:
   fancy_echo "File \"${FILEPATH}\" already exists."
else
   fancy_echo "ssh-keygen creating \"${FILEPATH}\" instead of id_rsa ..."
   ssh-keygen -f "${FILE}" -t rsa -N ''
      # -Comment, -No passphrase or -P
fi

# NOTE: pbcopy is a Mac-only command:
pbcopy < "$FILE.pub"

   fancy_echo "Now copy contents of \"${FILEPATH}.pub\", "
   echo "and paste into GitHub/BitBucket..."

## TODO: Read the .secrets file for GitHub account and password.
## TODO: Add a token using GitHub API.

   fancy_echo "Pop up from folder ~/.ssh ..."
   popd

