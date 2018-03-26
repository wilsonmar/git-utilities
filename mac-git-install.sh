#!/bin/bash
# mac-git-install.sh in https://github.com/wilsonmar/git-utilities
# This establishes all the utilities related to use of Git,
# customized based on specification in file .secrets.sh within the same repo.

# See https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup
# See https://git-scm.com/docs/git-config
# https://medium.com/my-name-is-midori/how-to-prepare-your-fresh-mac-for-software-development-b841c05db18

set -a

fancy_echo() {
  local fmt="$1"; shift
  # shellcheck disable=SC2059
  printf "\n>>> $fmt\n" "$@"
}

TIME_START="$(date -u +%s)"
fancy_echo "This is for Mac only! Starting elasped timer ..."
# For Git on Windows, see http://www.rolandfg.net/2014/05/04/intellij-idea-and-git-on-windows/


######### Function definitions:


# Add function to read in string and email, and return a KEY found for that email.
# GPG_MAP_MAIL2KEY associates the key and email in an array
GPG_MAP_MAIL2KEY(){
KEY_ARRAY=($(echo "$str" | awk -F'sec   rsa2048/|2018* [SC]' '{print $2}' | awk '{print $1}'))
# Remove trailing blank: KEY="$(echo -e "${str}" | sed -e 's/[[:space:]]*$//')"
MAIL_ARRAY=($(echo "$str" | awk -F'<|>' '{print $2}'))
#Test if the array count of the emails and the keys are the same to avoid conflicts
if [ ${#KEY_ARRAY[@]} == ${#MAIL_ARRAY[@]} ]; then
   declare -A KEY_MAIL_ARRAY=()
   for i in "${!KEY_ARRAY[@]}"
	 do
        KEY_MAIL_ARRAY[${MAIL_ARRAY[$i]}]=${KEY_ARRAY[$i]}
	 done
   #Return key matching email passed into function
	 echo "${KEY_MAIL_ARRAY[$1]}"
else
   #exit from script if array count of emails and keys are not the same
	 exit 1 && fancy_echo "Email count and Key count do not match"
fi
}


######### Read and use .secrets.sh file:


# If the file still contains defaults, it should not be used:
SECRETSFILE=".secrets.sh"
if grep -q "wilsonmar@gmail.com" "$SECRETSFILE" ; then    
   fancy_echo "Please edit file $SECRETSFILE with your own credentials. Aborting this run..."
   exit  # so script ends now
else
   fancy_echo "Reading from $SECRETSFILE ..."
   #chmod +x $SECRETSFILE
   . ./$SECRETSFILE
   echo "GIT_NAME=$GIT_NAME"
   echo "GIT_ID=$GIT_ID"
   echo "GIT_EMAIL=$GIT_EMAIL"
   echo "GIT_USERNAME=$GIT_USERNAME"
   echo "GITHUB_ACCOUNT=$GITHUB_ACCOUNT"
   # DO NOT echo $GITHUB_PASSWORD
#   echo "GIT_CLIENT=$GIT_CLIENT"
          # git, cola, github, gitkraken, smartgit, sourcetree, tower. 
          # See https://git-scm.com/download/gui/linux
#   echo "GIT_EDITOR=$GIT_EDITOR"
          # nano, pico, vim, sublime, code, atom, macvim, textmate, intellij, sts, eclipse.
          # NOTE: nano and vim are built into MacOS, so no install.
fi 


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
   # Xcode installs its git to /usr/bin/git; recent versions of OS X (Yosemite and later) ship with stubs in /usr/bin, which take precedence over this git. 
else
   fancy_echo "Mac OSX Xcode already installed:"
fi
pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep version
#swift --version


######### bash.profile configuration:


BASHFILE=~/.bash_profile

# if ~/.bash_profile has not been defined, create it:
if [ ! -f "$BASHFILE" ]; then #  NOT found:
   fancy_echo "Creating blank \"${BASHFILE}\" ..."
   touch $BASHFILE
   echo "PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" >>$BASHFILE
   # El Capitan no longer allows modifications to /usr/bin, and /usr/local/bin is preferred over /usr/bin, by default.
else
   LINES=$(wc -l < ${BASHFILE})
   fancy_echo "\"${BASHFILE}\" already created with $LINES lines."
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


###### Install homebrew using whatever Ruby is installed:


# Ruby comes with MacOS:
fancy_echo "Using whatever Ruby version comes with MacOS:"
ruby -v  # ruby 2.5.0p0 (2017-12-25 revision 61468) [x86_64-darwin16]


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

#brew tap caskroom/cask
# brew cask installs GUI apps (see https://caskroom.github.io/)
export HOMEBREW_CASK_OPTS="--appdir=/Applications"


######### Git clients:


fancy_echo "GIT_CLIENT=$GIT_CLIENT..."
echo "The last one installed is the Git default."

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
    else
       fancy_echo "Git already installed:"
    fi
fi
git --version
    # git version 2.14.3 (Apple Git-98)


#[core]
#  editor = vim
#  whitespace = fix,-indent-with-non-tab,trailing-space,cr-at-eol
#  excludesfile = ~/.gitignore
#[web]
#  browser = google-chrome
#[rerere]
#  enabled = 1
#  autoupdate = 1
#[push]
#  default = matching

#[diff]
#  tool = vimdiff
#[difftool]
#prompt = false

if [[ "$GIT_CLIENT" = *"cola"* ]]; then
   # https://git-cola.github.io/  (written in Python)
   # https://medium.com/@hamen/installing-git-cola-on-osx-eaa9368b4ee
   if [ ! -d "/Applications/git-cola.app" ]; then 
      fancy_echo "Installing GIT_CLIENT=\"cola\" using Homebrew ..."    
      brew install git-cola
   else
      if [ "$MY_RUNTYPE" == "UPGRADE" ]; then 
         fancy_echo "Upgrading GIT_CLIENT=\"cola\" using Homebrew ..."    
         brew upgrade git-cola
      else
         fancy_echo "GIT_CLIENT=\"cola\" already installed"
      fi
   fi
   git-cola --version
      # cola version 3.0
fi


# Error: Cask 'github-desktop' is unavailable: No Cask with this name exists. 
if [[ "$GIT_CLIENT" = *"github"* ]]; then
    # https://sourceforge.net/projects/git-osx-installer/files/latest/download
       # to git-2.15.0-intel-universal-mavericks.dmg
    # https://github.com/timcharper/git_osx_installer
    # github from https://www.git-github.com/learn/git/ebook/en/desktop-gui/advanced-topics/git-flow
    # https://desktop.github.com/
    # This was taken over by Atlanssian, which requires one of its accounts.
    if [ ! -d "/Applications/github.app" ]; then 
        fancy_echo "Installing GIT_CLIENT=\"github\" using Homebrew ..."    
        brew cask install github-desktop
    else
        if [ "$MY_RUNTYPE" == "UPGRADE" ]; then 
           fancy_echo "Upgrading GIT_CLIENT=\"github\" using Homebrew ..."    
           brew cask upgrade github-desktop
        else
           fancy_echo "GIT_CLIENT=\"github\" already installed"
        fi
    fi
fi



if [[ "$GIT_CLIENT" = *"gitkraken"* ]]; then
    # GitKraken from https://www.gitkraken.com/ and https://blog.axosoft.com/gitflow/
    if [ ! -d "/Applications/gitkraken.app" ]; then 
        fancy_echo "Installing GIT_CLIENT=\"gitkraken\" using Homebrew ..."    
        brew cask install gitkraken
    else
        if [ "$MY_RUNTYPE" == "UPGRADE" ]; then 
           fancy_echo "Upgrading GIT_CLIENT=\"gitkraken\" using Homebrew ..."    
           brew cask upgrade gitkraken
        else
           fancy_echo "GIT_CLIENT=\"gitkraken\" already installed"
        fi
    fi
fi


if [[ "$GIT_CLIENT" = *"sourcetree"* ]]; then
    # See https://www.sourcetreeapp.com/
    if ! command -v sourcetree >/dev/null; then
        fancy_echo "Installing GIT_CLIENT=\"sourcetree\" using Homebrew ..."    
        brew cask install sourcetree
    else
        if [ "$MY_RUNTYPE" == "UPGRADE" ]; then 
           fancy_echo "Upgrading GIT_CLIENT=\"sourcetree\" using Homebrew ..."    
           brew cask upgrade sourcetree
           # WARNING: This requires your MacOS password.
        else
           fancy_echo "GIT_CLIENT=\"sourcetree\" already installed:"
        fi
    fi
fi


if [[ "$GIT_CLIENT" = *"smartgit"* ]]; then
    # SmartGit from https://syntevo.com/smartgit
    if ! command -v smartgit >/dev/null; then
        fancy_echo "Installing GIT_CLIENT=\"smartgit\" using Homebrew ..."    
        brew cask install smartgit
    else
        if [ "$MY_RUNTYPE" == "UPGRADE" ]; then 
           fancy_echo "Upgrading GIT_CLIENT=\"smartgit\" using Homebrew ..."    
           brew cask upgrade smartgit
        else
           fancy_echo "GIT_CLIENT=\"smartgit\" already installed:"
        fi
    fi
fi


if [[ "$GIT_CLIENT" = *"tower"* ]]; then
    # Tower from https://www.git-tower.com/learn/git/ebook/en/desktop-gui/advanced-topics/git-flow
    if [ ! -d "~/Applications/Tower.app" ]; then 
        fancy_echo "Installing GIT_CLIENT=\"tower\" using Homebrew ..."    
        brew cask install tower
    else
        if [ "$MY_RUNTYPE" == "UPGRADE" ]; then 
           fancy_echo "Upgrading GIT_CLIENT=\"tower\" using Homebrew ..."    
           brew cask upgrade tower
        else
           fancy_echo "GIT_CLIENT=\"tower\" already installed"
        fi
    fi
fi


######### Text editors:


fancy_echo "GIT_EDITOR=$GIT_EDITOR..."
echo "The last one installed is the Git default."

# https://danlimerick.wordpress.com/2011/06/12/git-for-windows-tip-setting-an-editor/

if [[ "$GIT_EDITOR" = *"sublime"* ]]; then
   # /usr/local/bin/subl
   if [ ! -d "~/Applications/Sublime Text.app" ]; then 
   #if ! command -v subl >/dev/null; then
      fancy_echo "Installing Sublime Text text editor using Homebrew ..."
      brew cask install sublime-text
      # TODO: Configure Sublime for spell checker, etc. using shell commands.

      if grep -q "/usr/local/bin/subl" "$BASHFILE" ; then    
         fancy_echo "PATH to Sublime already in $BASHFILE"
      else
         fancy_echo "Adding PATH to SublimeText in $BASHFILE..."
         echo "export PATH=\"$PATH:/usr/local/bin/subl\"" >>$BASHFILE
         # Run .bash_profile to have changes take, run $FILEPATH:
         source $BASHFILE
         echo $PATH
      fi 
   else
      if [ "$MY_RUNTYPE" == "UPGRADE" ]; then 
         subl --version
            # Sublime Text Build 3143
         fancy_echo "Sublime Text already installed: UPGRADE requested..."
            # To avoid response "Error: git not installed" to brew upgrade git
         brew cask reinstall sublime-text
      else
         fancy_echo "Sublime Text already installed:"
      fi
   fi
   git config --global core.editor code
   subl --version
      # Sublime Text Build 3143
fi


if [[ "$GIT_EDITOR" = *"code"* ]]; then
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
    git config --global core.editor code
   code --version
      # 1.21.1
      # 79b44aa704ce542d8ca4a3cc44cfca566e7720f1
      # x64
fi


if [[ "$GIT_EDITOR" = *"atom"* ]]; then
    if ! command -v atom >/dev/null; then
        fancy_echo "Installing GIT_EDITOR=\"atom\" text editor using Homebrew ..."
        brew cask install --appdir="/Applications" atom
    else
       if [ "$MY_RUNTYPE" == "UPGRADE" ]; then 
          atom --version
             # 
          fancy_echo "GIT_EDITOR=\"atom\" already installed: UPGRADE requested..."
          # To avoid response "Error: No available formula with the name "atom"
          brew uninstall atom
          brew install atom
          # TODO: Configure atom text editor using bash shell commands.
       else
          fancy_echo "GIT_EDITOR=\"atom\" already installed:"
       fi
    fi
    git config --global core.editor atom
   atom --version
      # Atom    : 1.20.1
      # Electron: 1.6.9
      # Chrome  : 56.0.2924.87
      # Node    : 7.4.0
      # Wilsons-MacBook-Pro
fi


if [[ "$GIT_EDITOR" = *"macvim"* ]]; then
    if [ ! -d "/Applications/MacVim.app" ]; then 
        fancy_echo "Installing GIT_EDITOR=\"macvim\" text editor using Homebrew ..."
        brew cask install macvim
    else
       if [ "$MY_RUNTYPE" == "UPGRADE" ]; then 
          # TODO: macvim --version
             # 
          fancy_echo "GIT_EDITOR=\"macvim\" already installed: UPGRADE requested..."
          # To avoid response "==> No Casks to upgrade" on uprade:
          brew cask uninstall macvim
          brew cask install macvim
          # TODO: Configure macvim text editor using bash shell commands.
       else
          fancy_echo "GIT_EDITOR=\"macvim\" already installed:"
       fi
    fi
    git config --global core.editor macvim
fi
# TODO: macvim --version


if [[ "$GIT_EDITOR" = *"textmate"* ]]; then
    if [ ! -d "/Applications/textmate.app" ]; then 
        fancy_echo "Installing GIT_EDITOR=\"textmate\" text editor using Homebrew ..."
        brew cask install textmate
    else
       if [ "$MY_RUNTYPE" == "UPGRADE" ]; then 
          # TODO: textmate --version
             # 
          fancy_echo "GIT_EDITOR=\"textmate\" already installed: UPGRADE requested..."
          brew cask uninstall textmate
          brew cask install textmate
          # TODO: Configure textmate text editor using bash shell commands.
       else
          fancy_echo "GIT_EDITOR=\"textmate\" already installed:"
       fi
    fi
    git config --global core.editor textmate
fi
# TODO: textmate --version


if [[ "$GIT_EDITOR" = *"intellij"* ]]; then
    # See http://macappstore.org/intellij-idea-ce/
    if [ ! -d "/Applications/IntelliJ IDEA CE.app" ]; then 
        fancy_echo "Installing GIT_EDITOR=\"intellij\" text editor using Homebrew ..."
        brew cask install intellij-idea-ce 
        # alias idea='open -a "`ls -dt /Applications/IntelliJ\ IDEA*|head -1`"'
    else
       if [ "$MY_RUNTYPE" == "UPGRADE" ]; then 
          # TODO: intellij-idea-ce  --version
             # 
          fancy_echo "GIT_EDITOR=\"intellij\" already installed: UPGRADE requested..."
          # brew upgrade: No formula, so:
          brew cask uninstall intellij-idea-ce 
          brew cask install intellij-idea-ce 
          # TODO: Configure intellij text editor using bash shell commands.
       else
          fancy_echo "GIT_EDITOR=\"intellij\" already installed:"
       fi
    fi
    git config --global core.editor intellij
fi
# TODO: intellij-idea-ce --version
# See https://www.jetbrains.com/help/idea/using-git-integration.html

# https://gerrit-review.googlesource.com/Documentation/dev-intellij.html


if [[ "$GIT_EDITOR" = *"sts"* ]]; then
    # See http://macappstore.org/sts/
    if [ ! -d "/Applications/STS.app" ]; then 
        fancy_echo "Installing GIT_EDITOR=\"sts\" text editor using Homebrew ..."
        brew cask install sts
    else
       if [ "$MY_RUNTYPE" == "UPGRADE" ]; then 
          # TODO: sts --version
             # 
          fancy_echo "GIT_EDITOR=\"sts\" already installed: UPGRADE requested..."
          brew cask uninstall sts
          brew cask install sts
          # TODO: Configure sts text editor using bash shell commands.
       else
          fancy_echo "GIT_EDITOR=\"sts\" already installed:"
       fi
    fi
    git config --global core.editor sts
fi
# TODO: sts --version


if [[ "$GIT_EDITOR" = *"eclipse"* ]]; then
    # See http://macappstore.org/eclipse-ide/
    if [ ! -d "/Applications/Eclipse.app" ]; then 
        fancy_echo "Installing GIT_EDITOR=\"eclipse\" text editor using Homebrew ..."
        brew cask install eclipse-ide
    else
       if [ "$MY_RUNTYPE" == "UPGRADE" ]; then 
          # TODO: eclipse-ide --version
             # 
          fancy_echo "GIT_EDITOR=\"eclipse\" already installed: UPGRADE requested..."
          brew cask uninstall eclipse-ide
          brew cask install eclipse-ide
          # TODO: Configure eclipse text editor using bash shell commands.
       else
          fancy_echo "GIT_EDITOR=\"eclipse\" already installed:"
       fi
    fi
    git config --global core.editor eclipse
fi
# TODO: eclipse-ide --version


######### Difference engine p4merge:


# See https://www.perforce.com/products/helix-core-apps/merge-diff-tool-p4merge
if [ ! -d "/Applications/p4merge.app" ]; then 
    fancy_echo "Installing p4merge diff engine app using Homebrew ..."
    brew cask install p4merge
    # TODO: Configure p4merge using shell commands.
else
    if [ "$MY_RUNTYPE" == "UPGRADE" ]; then 
       # p4merge --version
       fancy_echo "p4merge diff engine app already installed: UPGRADE requested..."
       # To avoid response "Error: git not installed" to brew upgrade git
       brew cask reinstall p4merge
    else
       fancy_echo "p4merge diff engine app already installed:"
    fi
fi
# TODO: p4merge --version
   # ?

if grep -q "alias p4merge=" "$BASHFILE" ; then    
   fancy_echo "p4merge alias already in $BASHFILE"
else
   fancy_echo "Adding p4merge alias in $BASHFILE..."
   echo "alias p4merge='/Applications/p4merge.app/Contents/MacOS/p4merge'" >>$BASHFILE
fi 


# Based on https://gist.github.com/tony4d/3454372 
fancy_echo "Configuring to enable git mergetool..."
if grep -q "[difftool]" "$GITCONFIG" ; then    
   fancy_echo "[difftool] p4merge already in $GITCONFIG"
else
   fancy_echo "Adding [difftool] p4merge in $GITCONFIG..."
   git config --global merge.tool p4mergetool
   git config --global mergetool.p4mergetool.cmd "/Applications/p4merge.app/Contents/Resources/launchp4merge \$PWD/\$BASE \$PWD/\$REMOTE \$PWD/\$LOCAL \$PWD/\$MERGED"
   # false = prompting:
   git config --global mergetool.p4mergetool.trustExitCode false
   git config --global mergetool.keepBackup false

   git config --global diff.tool p4mergetool
   git config --global difftool.prompt false
   git config --global difftool.p4mergetool.cmd "/Applications/p4merge.app/Contents/Resources/launchp4merge \$LOCAL \$REMOTE"

   # Auto-type in "adduid":
   # gpg --edit-key "$KEY" answer adduid"
   # NOTE: By using git config command, repeated invocation would not duplicate lines.

   # git mergetool
   # You will be prompted to run "p4mergetool", hit enter and the visual merge editor will launch.

   # See https://danlimerick.wordpress.com/2011/06/19/git-for-window-tip-use-p4merge-as-mergetool/
   # git difftool

fi 



######### Git command completion in ~/.bash_profile:


# So you can type "git st" and press Tab to complete as "git status".
# See video on this: https://www.youtube.com/watch?v=VI07ouVS5FE
# If git-completion.bash file is already in home folder, download it:
FILE=.git-completion.bash
FILEPATH=~/.git-completion.bash
# If git-completion.bash file is mentioned in  ~/.bash_profile, add it:
if [ -f $FILEPATH ]; then 
   fancy_echo "List file to confirm size:"
   ls -al $FILEPATH
      # -rw-r--r--  1 wilsonmar  staff  68619 Mar 21 10:31 /Users/wilsonmar/.git-completion.bash
#   rm -rf $FILE
else
   fancy_echo "Download in home directory the file maintained by git people:"
   curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o $FILEPATH
   # alt # cp $FILE  ~/$FILEPATH
fi

# if internet download fails, use saved copy in GitHub repo:
if [ ! -f $FILEPATH ]; then 
   fancy_echo "Copy file saved in GitHub repo:"
   cp $FILE  $FILEPATH
fi

# show first line of file:
# line=$(read -r FIRSTLINE < ~/.git-completion.bash )


GITCONFIG=~/.gitconfig
if [ ! -f "$GITCONFIG" ]; then 
   fancy_echo "$GITCONFIG! file not found."
else
   fancy_echo "Git is configured in $GITCONFIG "
   fancy_echo "Deleting $GITCONFIG file..."
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
   git config --global user.name     "$GIT_NAME"
   git config --global user.email    "$GIT_EMAIL"
   git config --global user.id       "$GIT_ID"
   git config --global user.username "$GIT_USERNAME"

   git config --global github.user   "$GITHUB_ACCOUNT"
   git config --global github.token  token
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
    else
       fancy_echo "GPG2 already installed:"
    fi
fi
gpg --version 
   # gpg (GnuPG) 2.2.5 and many lines!
# NOTE: This creates folder ~/.gnupg


# Mac users can store GPG key passphrase in the Mac OS Keychain using the GPG Suite:
# https://gpgtools.org/
# See https://spin.atomicobject.com/2013/11/24/secure-gpg-keys-guide/

# Like https://gpgtools.tenderapp.com/kb/how-to/first-steps-where-do-i-start-where-do-i-begin-setup-gpgtools-create-a-new-key-your-first-encrypted-mail
if [ ! -d "/Applications/GPG Keychain.app" ]; then 
   fancy_echo "Installing gpg-suite app to store GPG keys ..."
   brew cask install gpg-suite  # See http://macappstore.org/gpgtools/
   # Renamed from gpgtools https://github.com/caskroom/homebrew-cask/issues/39862
   # See https://gpgtools.org/
else
    if [ "$MY_RUNTYPE" == "UPGRADE" ]; then 
       fancy_echo "gpg-suite app already installed: UPGRADE requested..."
       brew cask reinstall gpg-suite 
    else
       fancy_echo "gpg-suite app already installed:"
    fi
fi
# TODO: How to gpg-suite --version


# Per https://gist.github.com/danieleggert/b029d44d4a54b328c0bac65d46ba4c65
# git config --global gpg.program /usr/local/MacGPG2/bin/gpg2


   fancy_echo "Looking in key chain for GIT_ID=$GIT_ID ..."
   str="$(gpg --list-secret-keys --keyid-format LONG )"
   # RESPONSE FIRST TIME: gpg: /Users/wilsonmar/.gnupg/trustdb.gpg: trustdb created
   echo "$str"
   # Using regex per http://tldp.org/LDP/abs/html/bashver3.html#REGEXMATCHREF
if [[ "$str" =~ "$GIT_ID" ]]; then 
   fancy_echo "A GPG key for $GIT_ID already generated:"
   echo "${#str} bytes in list of keys."  # TODO: Capture and display list of keys.
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

fi

   fancy_echo "Retrive from response Key for "$GIT_ID" ..."
   # Thanks to Wisdom Hambolu (wisyhambolu@gmail.com) for assistance on this:
   # Extract GPG list between \"rsa2048/\" and \" 2018\" onward:"
   #str=$(echo $str | awk -v FS="(rsa2048/|2018*)" '{print $2}')
   # Remove trailing space:
   #KEY="$(echo -e "${str}" | sed -e 's/[[:space:]]*$//')"
   #echo "KEY=\"$KEY\""  # 16 chars. 
   # GPG_MAP_MAIL2KEY() here to make $KEY
   KEY="E3ABC07AF72BD084"  # forced static value for DEBUGGING.

# TODO: Store your GPG key passphrase so you don't have to enter it every time you 
# sign a commit by using https://gpgtools.org/

# If key is not already set in .gitconfig, add it:
if grep -q "$KEY" "$GITCONFIG" ; then    
   fancy_echo "Signing Key \"$KEY\" already in $GITCONFIG"
else
   fancy_echo "Adding SigningKey=$KEY in $GITCONFIG..."
   git config --global user.signingkey "$KEY"

   # Auto-type in "adduid":
   # gpg --edit-key "$KEY" <"adduid"
   # NOTE: By using git config command, repeated invocation would not duplicate lines.
fi 


# See https://help.github.com/articles/signing-commits-using-gpg/
# Configure Git client to sign commits by default for a local repository,
# in ANY/ALL repositories on your computer, run:
   # NOTE: This updates the "[commit]" section within ~/.gitconfig
git config commit.gpgsign | grep 'true' &> /dev/null
if [ $? == 0 ]; then
   fancy_echo "git config commit.gpgsign already true (on)."
else # false or blank response:
   fancy_echo "Setting git config commit.gpgsign false (on)..."
   git config --global commit.gpgsign false
fi


######### TODO: Insert GPG in GitHub:


# https://help.github.com/articles/telling-git-about-your-gpg-key/
# From https://gist.github.com/danieleggert/b029d44d4a54b328c0bac65d46ba4c65
# Add public GPG key to GitHub
# open https://github.com/settings/keys
# keybase pgp export -q $KEY | pbcopy

# https://help.github.com/articles/adding-a-new-gpg-key-to-your-github-account/


######### Repository:


# https://github.com/
# https://gitlab.com/
# https://bitbucket.org/
# https://travis-ci.org/


#########  brew cleanup


brew cleanup --force
rm -f -r /Library/Caches/Homebrew/*


######### Git code review:


# Prerequisite: Python
# sudo easy_install pip
# sudo pip install -U setuptools
# sudo pip install git-review


######### Git command coloring in .gitconfig:


# If git config color.ui returns true, skip:
git config color.ui | grep 'true' &> /dev/null
if [ $? == 0 ]; then
   fancy_echo "git config --global color.ui already true (on)."
else # false or blank response:
   fancy_echo "Setting git config --global color.ui true (on)..."
   git config --global color.ui true
fi


if grep -q "color.status=auto" "$GITCONFIG" ; then    
   fancy_echo "color.status=auto already in $GITCONFIG"
else
   fancy_echo "Adding color.status=auto in $GITCONFIG..."
   git config --global color.status auto
   git config --global color.branch auto
   git config --global color.interactive auto
   git config --global color.diff auto
   git config --global color.pager true

   # normal, black, red, green, yellow, blue, magenta, cyan, white
   # Attributes: bold, dim, ul, blink, reverse, italic, strike
   git config --global color.status.added     "green   normal bold"
   git config --global color.status.changed   "blue    normal bold"
   git config --global color.status.header    "white   normal dim"
   git config --global color.status.untracked "cyan    normal bold"

   git config --global color.branch.current   "yellow  reverse"
   git config --global color.branch.local     "yellow  normal bold"
   git config --global color.branch.remote    "cyan    normal dim"

   git config --global color.diff.meta        "yellow  normal bold"
   git config --global color.diff.frag        "magenta normal bold"
   git config --global color.diff.old         "blue    normal strike"
   git config --global color.diff.new         "green   normal bold"
   git config --global color.diff.whitespace  "red     normal bold"
fi


#[rerere]
#  enabled = 1
#  autoupdate = 1
   git config --global rerere.enabled  "1"
   git config --global rerere.autoupdate  "1"


######### Git Flow helper:


# GitFlow is a branching model for scaling collaboration using Git, created by Vincent Driessen. 
# See https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow
# See https://datasift.github.io/gitflow/IntroducingGitFlow.html
# https://danielkummer.github.io/git-flow-cheatsheet/
# https://github.com/nvie/gitflow
# https://vimeo.com/16018419
# https://buildamodule.com/video/change-management-and-version-control-deploying-releases-features-and-fixes-with-git-how-to-use-a-scalable-git-branching-model-called-gitflow

# Per https://github.com/nvie/gitflow/wiki/Mac-OS-X
if ! command -v git-flow >/dev/null; then
  fancy_echo "Installing git-flow ..."
  brew install git-flow
else
  fancy_echo "git-flow already installed:"
fi

#[gitflow "prefix"]
#  feature = feature-
#  release = release-
#  hotfix = hotfix-
#  support = support-
#  versiontag = v

#git clone --recursive git@github.com:<username>/gitflow.git
#cd gitflow
#git branch master origin/master
#git flow init -d
#git flow feature start <your feature>


fancy_echo "$GITCONFIG:"
cat $GITCONFIG  # List contents of ~/.gitconfig

fancy_echo "git config --list:"
git config --list


# If git-completion.bash file is mentioned in  ~/.bash_profile, add it:
if grep -q "$FILEPATH" "$BASHFILE" ; then    
   fancy_echo "$FILEPATH already in $BASHFILE"
else
   fancy_echo "Adding code for $FILEPATH in $BASHFILE..."
   echo "# Added by mac-git-install.sh ::" >>$BASHFILE
   echo "if [ -f $FILEPATH ]; then" >>$BASHFILE
   echo "   . $FILEPATH" >>$BASHFILE
   echo "fi" >>$BASHFILE
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


# Run .bash_profile to have changes above take:
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


######### ~/.ssh/config file of users:


SSHCONFIG=~/.ssh/config
if [ ! -f "$SSHCONFIG" ]; then 
   fancy_echo "$SSHCONFIG file not found. Creating..."
   touch $SSHCONFIG
else
   OCCURENCES=$(echo ${SSHCONFIG} | grep -o '\<HostName\>')
   fancy_echo "$SSHCONFIG file already created with $OCCURENCES entries."
   # Do not delete $SSHCONFIG file!
fi
cat $SSHCONFIG


# See https://www.saltycrane.com/blog/2008/11/creating-remote-server-nicknames-sshconfig/
if grep -q "$FILEPATH" "$SSHCONFIG" ; then    
   fancy_echo "SSH \"$FILEPATH\" to \"$GITHUB_ACCOUNT\" already in $SSHCONFIG"
else
   # Do not delete $SSHCONFIG

   # Check if GITHUB_ACCOUNT has content:
   if [ ! -f "$GITHUB_ACCOUNT" ]; then 
   fancy_echo "Adding SSH $FILEPATH to \"$GITHUB_ACCOUNT\" in $SSHCONFIG..."
   echo "# For: git clone git@github.com:${GITHUB_ACCOUNT}/some-repo.git from $GIT_ID" >> $SSHCONFIG
   echo "Host github.com" >> $SSHCONFIG
   echo "    Hostname github.com" >> $SSHCONFIG
   echo "    User git" >> $SSHCONFIG
   echo "    IdentityFile $FILEPATH" >> $SSHCONFIG
   echo "Host gist.github.com" >> $SSHCONFIG
   echo "    Hostname github.com" >> $SSHCONFIG
   echo "    User git" >> $SSHCONFIG
   echo "    IdentityFile $FILEPATH" >> $SSHCONFIG
   fi
fi

# NOTE: pbcopy is a Mac-only command:
pbcopy < "$FILE.pub"

   fancy_echo "Now you copy contents of \"${FILEPATH}.pub\", "
   echo "and paste into GitHub/GitLab/BitBucket..."

## TODO: Add a token using GitHub API from credentials in .secrets.sh 


   fancy_echo "Pop up from folder ~/.ssh ..."
   popd

TIME_END=$(date -u +%s);
DIFF=$((TIME_END-TIME_START))
fancy_echo "End of script after $((DIFF/60))m $((DIFF%60))s seconds elapsed."
