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

fancy_echo "Configure OSX Finder to show hidden files too:"
defaults write com.apple.finder AppleShowAllFiles YES
# NOTE: There are other dotfiles.


# Ensure Apple's command line tools (such as cc) are installed:
if ! command -v cc >/dev/null; then
  fancy_echo "Installing Apple's xcode command line tools (this takes a while) ..."
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
   # Homebrew 1.5.12
   # Homebrew/homebrew-core (git revision 9a81e; last commit 2018-03-22)


if ! command -v git >/dev/null; then
    fancy_echo "Installing git using Homebrew ..."
    brew install git
else
     fancy_echo "Git already installed:"
#    fancy_echo "Git already installed, upgrading ..."
#    # To avoid response "Error: git not installed" to brew upgrade git
#    brew uninstall git
    # NOTE: This does not remove .gitconfig file.
#    brew install git
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


######### Read and use .secrets.sh file:
echo "Readig .secrets.sh file:"
#chmod +x ./.secrets.sh
. .secrets.sh  # >/dev/null
echo "GIT_NAME=$GIT_NAME"
echo "GIT_ID=$GIT_ID"
echo "GIT_EMAIL=$GIT_EMAIL"
# DO NOT echo $GITHUB_PASSWORD

GITCONFIG=~/.gitconfig
if [ ! -f "$GITCONFIG" ]; then 
   fancy_echo "Git is not configured with $GITCONFIG!"
else
   fancy_echo "Git is configured with $GITCONFIG "
   fancy_echo "Deleting $GITCONFIG file:"
   rm $GITCONFIG
fi

# ~/.gitconfig file contain this examples:
#[user]
#	name = Wilson Mar
#	id = WilsonMar+GitHub@gmail.com
#	email = wilsonmar+github@gmail.com
#[color]
#	ui = true


   fancy_echo "Adding [user] info in in $GITCONFIG ..."
   git config --global user.name  $GIT_NAME
   git config --global user.email $GIT_EMAIL
   git config --global user.id    $GIT_ID
cat $GITCONFIG


######### Git Signing:
# See http://blog.ghostinthemachines.com/2015/03/01/how-to-use-gpg-command-line/
   # from 2015 recommends gnupg instead
# Cheat sheet of commands at http://irtfweb.ifa.hawaii.edu/~lockhart/gpg/
# NOTE: gpg is the command even though the package is gpg2:
if ! command -v gpg >/dev/null; then
  fancy_echo "Installing GPG2 for commit signing..."
  brew install gpg2
  # See https://www.gnupg.org/faq/whats-new-in-2.1.html
else
  fancy_echo "GPG2 already installed:"
  #fancy_echo "GPG2 already installed, upgrading ..."
  # brew upgrade gpg2
fi
gpg --version  # outputs many lines!

# Mac users can store GPG key passphrase in the Mac OS Keychain using the GPG Suite:
# https://gpgtools.org/
# See https://spin.atomicobject.com/2013/11/24/secure-gpg-keys-guide/


   fancy_echo "Looking in key chain for GIT_ID=$GIT_ID ..."
   str="$(gpg --list-secret-keys --keyid-format LONG )"
   echo "$str"
# Use regular expression per http://tldp.org/LDP/abs/html/bashver3.html#REGEXMATCHREF
if [[ "$str" =~ "$GIT_ID" ]]; then 
   fancy_echo "A GPG key for $GIT_ID has already been generated:"
   echo "${#str} bytes in output."

   fancy_echo "Extract GPG list between \"rsa2048/\" and \" 2018\" onward:"
   str=${str#*rsa2048/}
   str=${str%2018*}  # TODO: This does not eliminate the rest of the data.
   echo "KEY=$str"
else
   # See https://help.github.com/articles/generating-a-new-gpg-key/
  fancy_echo "Generate a GPG2 pair for $GIT_ID in batch mode ..."
  # Instead of manual: gpg --gen-key  or --full-generate-key
  # See https://superuser.com/questions/1003403/how-to-use-gpg-gen-key-in-a-script
  # And https://gist.github.com/woods/8970150
  # And http://www.gnupg.org/documentation/manuals/gnupg-devel/Unattended-GPG-key-generation.html
cat >foo <<EOF
     %echo Generating a default key
     Key-Type: default
     Subkey-Type: default
     Name-Real: $GIT_NAME
     Name-Comment: 2 long enough passphrase
     Name-Email: $GIT_ID
     Expire-Date: 0
     Passphrase: abc
     # Do a commit here, so that we can later print "done" :-)
     %commit
     %echo done
EOF
  gpg --batch --gen-key foo
  rm foo
# Sample output from above command:
#gpg: Generating a default key
#gpg: key AC3D4CED03B81E02 marked as ultimately trusted
#gpg: revocation certificate stored as '/Users/wilsonmar/.gnupg/openpgp-revocs.d/B66D9BD36CC672341E419283AC3D4CED03B81E02.rev'
#gpg: done

  fancy_echo "List GPG2 pairs generated ..."
  GPG_OUTPUT="$(gpg --list-secret-keys --keyid-format LONG )"
  echo "GPG_OUTPUT=$GPG_OUTPUT"
   # RESPONSE FIRST TIME: gpg: /Users/wilsonmar/.gnupg/trustdb.gpg: trustdb created
   # IF BLANK: gpg: checking the trustdb & gpg: no ultimately trusted keys found
   # RESPONSE AFTER a key is created:
# Sample output:
#sec   rsa2048/AC3D4CED03B81E02 2018-03-22 [SC]
#      B66D9BD36CC672341E419283AC3D4CED03B81E02
#uid                 [ultimate] Wilson Mar (2 long enough passphrase) <WilsonMar+GitHub@gmail.com>
#ssb   rsa2048/31653F7418AEA6DD 2018-03-22 [E]

   echo "sec   rsa2048/7FA75CBDD0C5721D 2018-03-22 [SC]" | awk -v FS="(rsa2048/| )" '{print $2}'
   fancy_echo "TODO: Capture \"7FA75CBDD0C5721D\" between / and space char from:"
   KEY=`echo | awk -r=$GPG_OUTPUT FS="(rsa2048/| )" `

   KEY="7FA75CBDD0C5721D"  # TODO: Remove forced
   echo "KEY=$KEY"
fi

# Check if key was already set in .gitconfig:
if grep -q "$KEY" "$GITCONFIG" ; then    
   fancy_echo "Signing Key $KEY already in $GITCONFIG"
else
   fancy_echo "Adding Signing Key $KEY in $GITCONFIG..."
   fancy_echo "Sign key $KEY:"
   #git config --global user.signingkey "$KEY"
fi 


#gpg --delete-secret-key 964C1A25C738751E
    # Delete this key from the keyring? (y/N) y
    # This is a secret key! - really delete? (y/N) y
#gpg --delete-key 964C1A25C738751E
    # Delete this key from the keyring? (y/N) y

# https://help.github.com/articles/telling-git-about-your-gpg-key/


# See https://help.github.com/articles/signing-commits-using-gpg/
# Configure Git client to sign commits by default for a local repository,
# in ANY/ALL repositories on your computer, run:
git config commit.gpgsign | grep 'true' &> /dev/null
if [ $? == 0 ]; then
   fancy_echo "git config commit.gpgsign already true (on)."
else # false or blank response:
   fancy_echo "Setting git config commit.gpgsign true (on)..."
   git config --global commit.gpgsign true
fi
cat $GITCONFIG


######### Git command coloring in .gitconfig:

# If git config color.ui returns true, skip:
git config color.ui | grep 'true' &> /dev/null
if [ $? == 0 ]; then
   fancy_echo "git config --global color.ui already true (on)."
else # false or blank response:
   fancy_echo "Setting git config --global color.ui true (on)..."
   git config --global color.ui true
fi


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

