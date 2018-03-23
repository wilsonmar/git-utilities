#!/bin/bash
# From mac-git-install.sh in https://github.com/wilsonmar/git-utilities

set -a

fancy_echo() {
  local fmt="$1"; shift
  # shellcheck disable=SC2059
  printf "\n>>> $fmt\n" "$@"
}

TIME_START="$(date -u +%s)"
fancy_echo "This is for Mac only! Starting elasped timer ..."

# Read first parameter from command line supplied at runtime to invoke:
MY_RUNTYPE=$1
#MY_RUNTYPE="ALL"
fancy_echo "MY_RUNTYPE=$MY_RUNTYPE"

fancy_echo "Configure OSX Finder to show hidden files too:"
defaults write com.apple.finder AppleShowAllFiles YES
# NOTE: Additional dotfiles for Mac
# NOTE: osx-init.sh in https://github.com/wilsonmar/DevSecOps/osx-init
#       installs other programs on Macs for developers.


# Ensure Apple's command line tools (such as cc) are installed:
if ! command -v cc >/dev/null; then
  fancy_echo "Installing Apple's xcode command line tools (this takes a while) ..."
  xcode-select --install 
else
  fancy_echo "Mac OSX Xcode already installed:"
fi
pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep version
#swift --version


######### Bash.profile configuration:

# If git-completion.bash file is mentioned in  ~/.bash_profile, add it:
BASHFILE=~/.bash_profile

# Check if file is present: ~/.bash_profile
if [ ! -f "$BASHFILE" ]; then #  NOT found:
   fancy_echo "Creating blank \"${BASHFILE}\" ..."
   touch $BASHFILE
   echo "PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" >>$BASHFILE
fi


###### Locale settings missing in OS X Lion+:
# See https://stackoverflow.com/questions/7165108/in-os-x-lion-lang-is-not-set-to-utf-8-how-to-fix-it
# https://unix.stackexchange.com/questions/87745/what-does-lc-all-c-do
# LC_ALL forces applications to use the default language for output, and forces sorting to be bytewise.
if grep -q "LC_ALL" "$BASHFILE" ; then    
   fancy_echo "LC_ALL Locale setting already in $BASHFILE"
else
   fancy_echo "Adding LC_ALL Locale in $BASHFILE..."
   echo "# Added by mac-git-install.sh ::" >>$BASHFILE
   echo "export LC_ALL=en_US.utf-8" >>$BASHFILE
   #export LANG="en_US.UTF-8"
   #export LC_CTYPE="en_US.UTF-8"
   
   # Run .bash_profile to have changes take, run $FILEPATH:
   source $BASHFILE
fi 
#locale
   # LANG="en_US.UTF-8"
   # LC_COLLATE="en_US.UTF-8"
   # LC_CTYPE="en_US.utf-8"
   # LC_MESSAGES="en_US.UTF-8"
   # LC_MONETARY="en_US.UTF-8"
   # LC_NUMERIC="en_US.UTF-8"
   # LC_TIME="en_US.UTF-8"
   # LC_ALL=

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
     # TODO: Upgrade if run-time attribute contains "upgrade":
fi
brew --version
   # Homebrew 1.5.12
   # Homebrew/homebrew-core (git revision 9a81e; last commit 2018-03-22)


if ! command -v git >/dev/null; then
    fancy_echo "Installing git using Homebrew ..."
    brew install git
else
    if [ "$MY_RUNTYPE" == "UPGRADE" ]; then 
       git --version
       fancy_echo "Git already installed: UPGRADE requested..."
       # To avoid response "Error: git not installed" to brew upgrade git
       brew uninstall git
       # NOTE: This does not remove .gitconfig file.
       brew install git
       # TODO: Configure more git settings using bash shell commands.
    else
       fancy_echo "Git already installed:"
    fi
fi
git --version
    # git version 2.14.3 (Apple Git-98)


######### Text editors:
if ! command -v code >/dev/null; then
    fancy_echo "Installing Visual Studio Code text editor using Homebrew ..."
    brew install visual-studio-code
else
    if [ "$MY_RUNTYPE" == "UPGRADE" ]; then 
       code --version
       fancy_echo "VS Code already installed: UPGRADE requested..."
       # To avoid response "Error: git not installed" to brew upgrade git
       brew uninstall visual-studio-code
       # NOTE: This does not remove .gitconfig file.
       brew install visual-studio-code
       # TODO: Configure visual-studio-code using bash shell commands.
    else
       fancy_echo "VS Code already installed:"
    fi
fi
code --version
   # 1.21.1
   # 79b44aa704ce542d8ca4a3cc44cfca566e7720f1
   # x64


if ! command -v subl >/dev/null; then
    fancy_echo "Installing Sublime Text text editor using Homebrew ..."
    brew tap caskroom/versions
    brew cask install sublime-text3
else
    if [ "$MY_RUNTYPE" == "UPGRADE" ]; then 
       subl --version
       fancy_echo "Sublime Text v3 already installed: UPGRADE requested..."
       # To avoid response "Error: git not installed" to brew upgrade git
       brew cask reinstall sublime-text3
    else
       fancy_echo "Sublime Text v3 already installed:"
    fi
fi
subl --version
   # Sublime Text Build 3143


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
# About http://notes.jerzygangi.com/the-best-pgp-tutorial-for-mac-os-x-ever/
# See http://blog.ghostinthemachines.com/2015/03/01/how-to-use-gpg-command-line/
   # from 2015 recommends gnupg instead
# Cheat sheet of commands at http://irtfweb.ifa.hawaii.edu/~lockhart/gpg/
# NOTE: gpg is the command even though the package is gpg2:
if ! command -v gpg >/dev/null; then
  fancy_echo "Installing GPG2 for commit signing..."
  brew install gpg2
  # See https://www.gnupg.org/faq/whats-new-in-2.1.html
else
    if [ "$MY_RUNTYPE" == "UPGRADE" ]; then 
       gpg --version  # outputs many lines!
       fancy_echo "GPG2 already installed: UPGRADE requested..."
       # To avoid response "Error: git not installed" to brew upgrade git
       brew uninstall GPG2 
       # NOTE: This does not remove .gitconfig file.
       brew install GPG2 
       # TODO: Configure sublime-text using bash shell commands.
    else
       fancy_echo "GPG2 already installed:"
    fi
     # TODO: Upgrade if run-time attribute contains "upgrade":
  #fancy_echo "GPG2 already installed, upgrading ..."
  # brew upgrade gpg2
fi
gpg --version 
   # gpg (GnuPG) 2.2.5 and many lines!
# NOTE: This creates folder ~/.gnupg


# Per https://gist.github.com/danieleggert/b029d44d4a54b328c0bac65d46ba4c65
git config --global gpg.program /usr/local/MacGPG2/bin/gpg2


# Like https://gpgtools.tenderapp.com/kb/how-to/first-steps-where-do-i-start-where-do-i-begin-setup-gpgtools-create-a-new-key-your-first-encrypted-mail
if ! command -v gpg-suite >/dev/null; then
  fancy_echo "Installing gpg-suite to store GPG keys ..."
  brew cask install gpg-suite  # See http://macappstore.org/gpgtools/
  # Renamed from gpgtools https://github.com/caskroom/homebrew-cask/issues/39862
  # See https://gpgtools.org/
else
    if [ "$MY_RUNTYPE" == "UPGRADE" ]; then 
       gpg --version  # outputs many lines!
       fancy_echo "gpg-suite already installed: UPGRADE requested..."
       brew cask reinstall gpg-suite 
    else
       fancy_echo "gpg-suite already installed:"
    fi
fi
gpgtools --version  # outputs many lines!


# Mac users can store GPG key passphrase in the Mac OS Keychain using the GPG Suite:
# https://gpgtools.org/
# See https://spin.atomicobject.com/2013/11/24/secure-gpg-keys-guide/


   fancy_echo "Looking in key chain for GIT_ID=$GIT_ID ..."
   str="$(gpg --list-secret-keys --keyid-format LONG )"
   # RESPONSE FIRST TIME: gpg: /Users/wilsonmar/.gnupg/trustdb.gpg: trustdb created
   echo "$str"
   # Using regex per http://tldp.org/LDP/abs/html/bashver3.html#REGEXMATCHREF
if [[ "$str" =~ "$GIT_ID" ]]; then 
   fancy_echo "A GPG key for $GIT_ID already generated:"
   echo "${#str} bytes in list of keys."  # TODO: Capture and display list of keys.

   # fancy_echo "Extract GPG list between \"rsa2048/\" and \" 2018\" onward:"
   str=$(echo $str | awk -v FS="(rsa2048/|2018*)" '{print $2}')
   # Remove trailing space:
   KEY="$(echo -e "${str}" | sed -e 's/[[:space:]]*$//')"
   echo "KEY=\"$KEY\""  # 16 chars. 
else  # generate:
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
     Passphrase: $GPG_PASSPHRASE
     # Do a commit here, so that we can later print "done" :-)
     %commit
     %echo done
EOF
  gpg --batch --gen-key foo
  rm foo  # temp intermediate work file.
# Sample output from above command:
#gpg: Generating a default key
#gpg: key AC3D4CED03B81E02 marked as ultimately trusted
#gpg: revocation certificate stored as '/Users/wilsonmar/.gnupg/openpgp-revocs.d/B66D9BD36CC672341E419283AC3D4CED03B81E02.rev'
#gpg: done

  fancy_echo "List GPG2 pairs just generated ..."
   str="$(gpg --list-secret-keys --keyid-format LONG )"
   # IF BLANK: gpg: checking the trustdb & gpg: no ultimately trusted keys found
   echo "$str"
   # RESPONSE AFTER a key is created:
# Sample output:
#sec   rsa2048/7FA75CBDD0C5721D 2018-03-22 [SC]
#      B66D9BD36CC672341E419283AC3D4CED03B81E02
#uid                 [ultimate] Wilson Mar (2 long enough passphrase) <WilsonMar+GitHub@gmail.com>
#ssb   rsa2048/31653F7418AEA6DD 2018-03-22 [E]

# To delete a key pair:
#gpg --delete-secret-key 7FA75CBDD0C5721D
    # Delete this key from the keyring? (y/N) y
    # This is a secret key! - really delete? (y/N) y
    # Click <delete key> in the GUI. Twice.
#gpg --delete-key 7FA75CBDD0C5721D
    # Delete this key from the keyring? (y/N) y

   # Extract GPG list between \"rsa2048/\" and \" 2018\" onward:"
   # Thanks to wisyhambolu@gmail.com for assistance on this:
   str=$(echo $str | awk -v FS="(rsa2048/|2018*)" '{print $2}')
   # Remove trailing space:
   KEY="$(echo -e "${str}" | sed -e 's/[[:space:]]*$//')"
   echo "KEY=\"$KEY\""  # 16 chars. 
fi

# TODO: Store your GPG key passphrase so you don't have to enter it every time you 
# sign a commit by using https://gpgtools.org/

# If key is not already set in .gitconfig, add it:
if grep -q "$KEY" "$GITCONFIG" ; then    
   fancy_echo "Signing Key \"$KEY\" already in $GITCONFIG"
else
   fancy_echo "Adding SigningKey=$KEY in $GITCONFIG..."
   git config --global user.signingkey "$KEY"

   # Auto-type "adduid":
   gpg --edit-key "$KEY" <"adduid"
   # NOTE: By using git config command, repeated invocation would not duplicate lines.
fi 


# See https://help.github.com/articles/signing-commits-using-gpg/
# Configure Git client to sign commits by default for a local repository,
# in ANY/ALL repositories on your computer, run:
git config commit.gpgsign | grep 'true' &> /dev/null
if [ $? == 0 ]; then
   fancy_echo "git config commit.gpgsign already true (on)."
else # false or blank response:
   fancy_echo "Setting git config commit.gpgsign true (on)..."
   git config --global commit.gpgsign true
   # NOTE: This updates the "[commit]" section within ~/.gitconfig
   echo "Turn signing off with command:"
   echo "git config --global commit.gpgsign false"
fi
exit

######### TODO: Insert GPG in GitHub:
# https://help.github.com/articles/telling-git-about-your-gpg-key/
# From https://gist.github.com/danieleggert/b029d44d4a54b328c0bac65d46ba4c65
# Add public GPG key to GitHub
# open https://github.com/settings/keys
# keybase pgp export -q $KEY | pbcopy

# https://help.github.com/articles/adding-a-new-gpg-key-to-your-github-account/

######### Git command coloring in .gitconfig:
# If git config color.ui returns true, skip:
git config color.ui | grep 'true' &> /dev/null
if [ $? == 0 ]; then
   fancy_echo "git config --global color.ui already true (on)."
else # false or blank response:
   fancy_echo "Setting git config --global color.ui true (on)..."
   git config --global color.ui true
fi

cat $GITCONFIG  # List contents of ~/.gitconfig



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
   echo "and paste into GitHub/GitLab/BitBucket..."

## TODO: Add a token using GitHub API from credentials in .secrets.sh 


   fancy_echo "Pop up from folder ~/.ssh ..."
   popd

TIME_END=$(date -u +%s);
DIFF=$((TIME_END-TIME_START))
fancy_echo "End of script after $((DIFF/60))m $((DIFF%60))s seconds elapsed."
