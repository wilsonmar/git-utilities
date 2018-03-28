#!/usr/local/bin/bash

# mac-git-install.sh in https://github.com/wilsonmar/git-utilities
# This establishes all the utilities related to use of Git,
# customized based on specification in file .secrets.sh within the same repo.
# See https://github.com/wilsonmar/git-utilities/blob/master/README.md
# NOTE: This was run through https://www.shellcheck.net/
# Based on https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup
# and https://git-scm.com/docs/git-config
# and https://medium.com/my-name-is-midori/how-to-prepare-your-fresh-mac-for-software-development-b841c05db18

# TOC: Functions > Secrets > OSX > XCode/Ruby > bash.profile > Brew > gitconfig > Git web browsers > Git clients > git users > Editors > git [core] > coloring > rerere > diff/merge > prompts > bash command completion > git command completion > Git alias keys > Git repos > git flow > code review > git hooks > git signing > cloud CLI/SDK > GitHub > SSH KeyGen > SSH Config > Paste SSH Keys in GitHub.

set -a


######### Bash function definitions:


fancy_echo() {
  local fmt="$1"; shift
  # shellcheck disable=SC2059
  printf "\\n>>> $fmt\\n" "$@"
}

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

PYTHON_INSTALL(){
   # Python2 is a pre-requisite for git-cola & GCP installed below.
   # Python3 is a pre-requisite for aws.
   # Because there are two active versions of Pythong (2.7.4 and 3.6 now)...
     # See https://docs.brew.sh/Homebrew-and-Python
   # See https://docs.python-guide.org/en/latest/starting/install3/osx/
   
   if ! command -v python >/dev/null; then
      # No upgrade option.
      fancy_echo "Installing Python, a pre-requisite for git-cola & GCP ..."
      brew install python

      # pip comes with brew install python
      pip --version

      fancy_echo "Installing virtualenv to manage multiple Python versions ..."
      pip install virtualenv
      pip install virtualenvwrapper
      source /usr/local/bin/virtualenvwrapper.sh

      #brew install freetype  # http://www.freetype.org to render fonts
      #fancy_echo "Installing other popular Python helper modules ..."
      # anaconda?
      #pip install numpy
      #pip install scipy
      #pip install matplotlib
      #pip install ipython[all]
   else
      fancy_echo "$(python --version) already installed:"
   fi
   command -v python
   ls -al "$(command -v python)" # /usr/local/bin/python

   #python --version
      # Python 2.7.14

   # Define command python as going to version 2.7:
      if grep -q "alias python=" "$BASHFILE" ; then    
         fancy_echo "Python 2.7 alias already in $BASHFILE"
      else
         fancy_echo "Adding Python 2.7 alias in $BASHFILE ..."
         echo "export alias python=/usr/local/bin/python2.7" >>"$BASHFILE"
      fi
   
   # To prevent the older MacOS default python being seen first in PATH ...
      if grep -q "/usr/local/opt/python/libexec/bin" "$BASHFILE" ; then    
         fancy_echo "Python PATH already in $BASHFILE"
      else
         fancy_echo "Adding Python PATH in $BASHFILE..."
         echo "export PATH=\"/usr/local/opt/python/libexec/bin:$PATH\"" >>"$BASHFILE"
      fi

         # Run .bash_profile to have changes take, run $FILEPATH:
         source "$BASHFILE"
         echo "$PATH"

   # There is also a Enthought Python Distribution -- www.enthought.com
}

PYTHON3_INSTALL(){
   fancy_echo "Installing Python3 is a pre-requisite for AWS-CLI"
   # Python3 is a pre-requisite for aws.
   # Because there are two active versions of Python (2.7.4 and 3.6 now)...
     # See https://docs.brew.sh/Homebrew-and-Python
   # See https://docs.python-guide.org/en/latest/starting/install3/osx/
   
   if ! command -v python3 >/dev/null; then
      # No upgrade option.
      fancy_echo "Installing Python3, a pre-requisite for awscli and azure ..."
      brew install python3

      # pip comes with brew install python
      pip3 --version

      fancy_echo "Installing virtualenv to manage multiple Python versions ..."
      pip3 install virtualenv
      pip3 install virtualenvwrapper
      source /usr/local/bin/virtualenvwrapper.sh
	  
   else
      fancy_echo "$(python3 --version) already installed:"
   fi
   command -v python3
   ls -al "$(command -v python3)" # /usr/local/bin/python

   python3 --version
      # Python 3.6.4

   # NOTE: To make "python" command reach Python3 instead of 2.7, per docs.python-guide.org/en/latest/starting/install3/osx/
   # Put in PATH Python 3.6 bits at /usr/local/bin/ before Python 2.7 bits at /usr/bin/
}


######### Starting:


TIME_START="$(date -u +%s)"
fancy_echo "This is for Mac only! Starting elapsed timer ..."
# For Git on Windows, see http://www.rolandfg.net/2014/05/04/intellij-idea-and-git-on-windows/


######### Read and use .secrets.sh file:


# If the file still contains defaults, it should not be used:
SECRETSFILE=".secrets.sh"
if grep -q "wilsonmar@gmail.com" "$SECRETSFILE" ; then    
   fancy_echo "Please edit file $SECRETSFILE with your own credentials. Aborting this run..."
   exit  # so script ends now
else
   fancy_echo "Reading from $SECRETSFILE ..."
   #chmod +x $SECRETSFILE
   source "$SECRETSFILE"
   echo "GIT_NAME=$GIT_NAME"
   echo "GIT_ID=$GIT_ID"
   echo "GIT_EMAIL=$GIT_EMAIL"
   echo "GIT_USERNAME=$GIT_USERNAME"
   echo "GITHUB_ACCOUNT=$GITHUB_ACCOUNT"
   # DO NOT echo $GITHUB_PASSWORD
#   echo "CLOUD=$CLOUD"
#   echo "GIT_CLIENT=$GIT_CLIENT"
#   echo "GIT_EDITOR=$GIT_EDITOR"
fi 


# Read first parameter from command line supplied at runtime to invoke:
MY_RUNTYPE=$1
fancy_echo "MY_RUNTYPE=$MY_RUNTYPE"
if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then # variable made lower case.
   echo "All packages here will be upgraded ..."
fi


######### OSX configuration:


fancy_echo "Configure OSX Finder to show hidden files too:"
defaults write com.apple.finder AppleShowAllFiles YES
# NOTE: Additional config dotfiles for Mac?
# NOTE: See osx-init.sh in https://github.com/wilsonmar/DevSecOps/osx-init
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
   # Tools_Executables | grep version
   # version: 9.2.0.0.1.1510905681


######### bash.profile configuration:


BASHFILE=$HOME/.bash_profile

# if ~/.bash_profile has not been defined, create it:
if [ ! -f "$BASHFILE" ]; then #  NOT found:
   fancy_echo "Creating blank \"${BASHFILE}\" ..."
   touch "$BASHFILE"
   echo "PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" >>"$BASHFILE"
   # El Capitan no longer allows modifications to /usr/bin, and /usr/local/bin is preferred over /usr/bin, by default.
else
   LINES=$(wc -l < "${BASHFILE}")
   fancy_echo "\"${BASHFILE}\" already created with $LINES lines."

   fancy_echo "Backing up file $BASHFILE to $BASHFILE-$RANDOM.bak ..."
   RANDOM=$((1 + RANDOM % 1000));  # 5 digit randome number.
   cp "$BASHFILE" "$BASHFILE-$RANDOM.backup"
fi


###### bash.profile locale settings missing in OS X Lion+:


# See https://stackoverflow.com/questions/7165108/in-os-x-lion-lang-is-not-set-to-utf-8-how-to-fix-it
# https://unix.stackexchange.com/questions/87745/what-does-lc-all-c-do
# LC_ALL forces applications to use the default language for output, and forces sorting to be bytewise.
if grep -q "LC_ALL" "$BASHFILE" ; then    
   fancy_echo "LC_ALL Locale setting already in $BASHFILE"
else
   fancy_echo "Adding LC_ALL Locale in $BASHFILE..."
   echo "# Added by mac-git-install.sh ::" >>"$BASHFILE"
   echo "export LC_ALL=en_US.utf-8" >>"$BASHFILE"
   #export LANG="en_US.UTF-8"
   #export LC_CTYPE="en_US.UTF-8"
   
   # Run .bash_profile to have changes take, run $FILEPATH:
   source "$BASHFILE"
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
    # Upgrade if run-time attribute contains "upgrade":
    if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
       brew --version
       fancy_echo "Brew already installed: UPGRADE requested..."
       brew upgrade
    else
       fancy_echo "Bres already installed:"
    fi
fi
brew --version
   # Homebrew 1.5.12
   # Homebrew/homebrew-core (git revision 9a81e; last commit 2018-03-22)

#brew tap caskroom/cask
# brew cask installs GUI apps (see https://caskroom.github.io/)
export HOMEBREW_CASK_OPTS="--appdir=/Applications"


######### ~/.gitconfig initial settings:


GITCONFIG=$HOME/.gitconfig

if [ ! -f "$GITCONFIG" ]; then 
   fancy_echo "$GITCONFIG! file not found."
else
   fancy_echo "Git is configured in new $GITCONFIG "
   fancy_echo "Backing up $GITCONFIG file to $GITCONFIG-$RANDOM.bak ..."
   RANDOM=$((1 + RANDOM % 1000));  # 5 digit randome number.
   cp "$GITCONFIG" "$GITCONFIG-$RANDOM.backup"
   fancy_echo "git config command creates new $GITCONFIG file..."
fi


######### Git web browser setting:


# TODO: New .secrets.sh variable BROWSER=google-chrome, etc.
# TODO: Install browser as needed using Homebrew.

# See Complications at
# https://stackoverflow.com/questions/19907152/how-to-set-google-chrome-as-git-default-browser
# [web]
# browser = google-chrome
#[browser "chrome"]
#    cmd = C:/Program Files (x86)/Google/Chrome/Application/chrome.exe
#    path = C:/Program Files (x86)/Google/Chrome/Application/

if grep -q "browser = " "$GITCONFIG" ; then    
   fancy_echo "git config --global web.browser already defined:"
   git config --global web.browser 
else 
   fancy_echo "git config --global web.browser google-chrome ..."
   git config --global web.browser google-chrome

   # google-chrome is the most tested and popular.
   # Check to see if google-chrome is installed and if not:
   # brew cask install google-chrome

   # Alternatives listed at https://git-scm.com/docs/git-web--browse.html
   # The command line web browser:
   # brew install links

   #git config --global web.browser cygstart
   #git config --global browser.cygstart.cmd cygstart
fi


######### Git clients:


fancy_echo "GIT_CLIENT=$GIT_CLIENT..."
echo "The last one installed is set as the Git editor."
# See https://www.slant.co/topics/465/~best-git-clients-for-macos
          # git, cola, github, gitkraken, smartgit, sourcetree, tower, magit, gitup. 
          # See https://git-scm.com/download/gui/linux
          # https://www.slant.co/topics/465/~best-git-clients-for-macos


if ! command -v git >/dev/null; then
    fancy_echo "Installing git using Homebrew ..."
    brew install git
else
    if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
       git --version
       fancy_echo "Git already installed: UPGRADE requested..."
       # To avoid response "Error: git not installed" to brew upgrade git
       brew uninstall git
       # QUESTION: This removes .gitconfig file?
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
#[push]
#  default = matching

#[diff]
#  tool = vimdiff
#[difftool]
#  prompt = false

if [[ "$GIT_CLIENT" == *"cola"* ]]; then
   # https://git-cola.github.io/  (written in Python)
   # https://medium.com/@hamen/installing-git-cola-on-osx-eaa9368b4ee
   if ! command -v git-cola >/dev/null; then  # not recognized:
      PYTHON_INSTALL  # function defined at top of this file.
      fancy_echo "Installing GIT_CLIENT=\"cola\" using Homebrew ..."
      brew install git-cola
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "Upgrading GIT_CLIENT=\"cola\" using Homebrew ..."
         brew upgrade git-cola
      else
         fancy_echo "GIT_CLIENT=\"cola\" already installed"
      fi
   fi
   git-cola --version
      # cola version 3.0

   fancy_echo "Starting git-cola in background ..."
   git-cola &
fi


# GitHub Desktop is written by GitHub, Inc. 
# open sourced at https://github.com/desktop/desktop
# so people can just click a button on GitHub to download a repo from an internet browser.
if [[ "$GIT_CLIENT" == *"github"* ]]; then
    # https://desktop.github.com/
    if [ ! -d "/Applications/GitHub Desktop.app" ]; then 
        fancy_echo "Installing GIT_CLIENT=\"github\" using Homebrew ..."
        brew cask install --appdir="/Applications" github
    else
        if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
           fancy_echo "Upgrading GIT_CLIENT=\"github\" using Homebrew ..."
           brew cask upgrade github
        else
           fancy_echo "GIT_CLIENT=\"github\" already installed"
        fi
    fi
   fancy_echo "Opening GitHub Desktop ..."
   open "/Applications/GitHub Desktop.app"
fi



if [[ "$GIT_CLIENT" == *"gitkraken"* ]]; then
    # GitKraken from https://www.gitkraken.com/ and https://blog.axosoft.com/gitflow/
    if [ ! -d "/Applications/GitKraken.app" ]; then 
        fancy_echo "Installing GIT_CLIENT=\"gitkraken\" using Homebrew ..."
        brew cask install --appdir="/Applications" gitkraken
    else
        if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
           fancy_echo "Upgrading GIT_CLIENT=\"gitkraken\" using Homebrew ..."
           brew cask upgrade gitkraken
        else
           fancy_echo "GIT_CLIENT=\"gitkraken\" already installed"
        fi
    fi
   fancy_echo "Opening GitKraken ..."
   open "/Applications/GitKraken.app"
fi


if [[ "$GIT_CLIENT" == *"sourcetree"* ]]; then
    # See https://www.sourcetreeapp.com/
    if [ ! -d "/Applications/Sourcetree.app" ]; then 
        fancy_echo "Installing GIT_CLIENT=\"sourcetree\" using Homebrew ..."
        brew cask install --appdir="/Applications" sourcetree
    else
        if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
           fancy_echo "Upgrading GIT_CLIENT=\"sourcetree\" using Homebrew ..."
           brew cask upgrade sourcetree
           # WARNING: This requires your MacOS password.
        else
           fancy_echo "GIT_CLIENT=\"sourcetree\" already installed:"
        fi
    fi
   fancy_echo "Opening Sourcetree ..."
   open "/Applications/Sourcetree.app"
fi


if [[ "$GIT_CLIENT" == *"smartgit"* ]]; then
    # SmartGit from https://syntevo.com/smartgit
    if [ ! -d "/Applications/SmartGit.app" ]; then 
        fancy_echo "Installing GIT_CLIENT=\"smartgit\" using Homebrew ..."
        brew cask install --appdir="/Applications" smartgit
    else
        if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
           fancy_echo "Upgrading GIT_CLIENT=\"smartgit\" using Homebrew ..."
           brew cask upgrade smartgit
        else
           fancy_echo "GIT_CLIENT=\"smartgit\" already installed:"
        fi
    fi
   fancy_echo "Opening SmartGit ..."
   open "/Applications/SmartGit.app"
fi


if [[ "$GIT_CLIENT" == *"tower"* ]]; then
    # Tower from https://www.git-tower.com/learn/git/ebook/en/desktop-gui/advanced-topics/git-flow
    if [ ! -d "$HOME/Applications/Tower.app" ]; then 
        fancy_echo "Installing GIT_CLIENT=\"tower\" using Homebrew ..."
        brew cask install --appdir="/Applications" tower
    else
        if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
           fancy_echo "Upgrading GIT_CLIENT=\"tower\" using Homebrew ..."
           brew cask upgrade tower
        else
           fancy_echo "GIT_CLIENT=\"tower\" already installed"
        fi
    fi

   fancy_echo "Opening Tower ..."
   open "/Applications/Tower.app"
fi


if [[ "$GIT_CLIENT" == *"magit"* ]]; then
    # See https://www.slant.co/topics/465/viewpoints/18/~best-git-clients-for-macos~macvim
    #     "Useful only for people who use Emacs text editor."
    # https://magit.vc/manual/magit/
    if ! command -v magit >/dev/null; then
        fancy_echo "Installing GIT_CLIENT=\"magit\" using Homebrew ..."
         brew tap dunn/emacs
         brew install magit
    else
        if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
           fancy_echo "Upgrading GIT_CLIENT=\"magit\" using Homebrew ..."
           brew upgrade magit
        else
           fancy_echo "GIT_CLIENT=\"magit\" already installed:"
        fi
    fi

   # TODO: magit -v
   fancy_echo "Opening macvim ..."
   open "/Applications/MacVim.app"
fi


if [[ "$GIT_CLIENT" == *"gitup"* ]]; then
   # http://gitup.co/
   # https://github.com/git-up/GitUp
   # https://gitup.vc/manual/gitup/
   if ! command -v gitup >/dev/null; then
      fancy_echo "Installing GIT_CLIENT=\"gitup\" using Homebrew ..."
      # https://s3-us-west-2.amazonaws.com/gitup-builds/stable/GitUp.zip
      brew cask install --appdir="/Applications" gitup
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "Upgrading GIT_CLIENT=\"gitup\" using Homebrew ..."
         brew upgrade gitup
      else
         fancy_echo "GIT_CLIENT=\"gitup\" already installed:"
      fi
   fi
   # gitup -v

   fancy_echo "Starting GitUp in background ..."
   gitup &
fi


######### Text editors:

# Specified in .secrets.sh
          # nano, pico, vim, sublime, code, atom, macvim, textmate, emacs, intellij, sts, eclipse.
          # NOTE: nano and vim are built into MacOS, so no install.
fancy_echo "GIT_EDITOR=$GIT_EDITOR..."
      echo "The last one installed is the Git default."

# INFO: https://danlimerick.wordpress.com/2011/06/12/git-for-windows-tip-setting-an-editor/
# https://insights.stackoverflow.com/survey/2018/#development-environments-and-tools
#    Says vim is the most popular among Sysadmins. 

if [[ "$GIT_CLIENT" == *"nano"* ]]; then
   git config --global core.editor nano
fi

if [[ "$GIT_CLIENT" == *"vim"* ]]; then
   git config --global core.editor vim
fi

if [[ "$GIT_CLIENT" == *"pico"* ]]; then
   git config --global core.editor pico
fi

if [[ "$GIT_EDITOR" == *"sublime"* ]]; then
   # /usr/local/bin/subl
   if [ ! -f "/Applications/Sublime Text.app" ]; then 
      fancy_echo "Installing Sublime Text text editor using Homebrew ..."
      brew cask install --appdir="/Applications" sublime-text
 
      if grep -q "/usr/local/bin/subl" "$BASHFILE" ; then    
         fancy_echo "PATH to Sublime already in $BASHFILE"
      else
         fancy_echo "Adding PATH to SublimeText in $BASHFILE..."
         echo "" >>"$BASHFILE"
         echo "export PATH=\"\$PATH:/usr/local/bin/subl\"" >>"$BASHFILE"
         source "$BASHFILE"
      fi 
 
      if grep -q "alias subl=" "$BASHFILE" ; then
         fancy_echo "PATH to Sublime already in $BASHFILE"
      else
         echo "" >>"$BASHFILE"
         echo "alias subl='open -a \"/Applications/Sublime Text.app\"'" >>"$BASHFILE"
         source "$BASHFILE"
      fi 
      # Only install the following during initial install:
      # TODO: Configure Sublime for spell checker, etc.
      # install Package Control see https://gist.github.com/patriciogonzalezvivo/77da993b14a48753efda
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
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

   fancy_echo "Opening Sublime Text app in background ..."
   subl &
fi


if [[ "$GIT_EDITOR" == *"code"* ]]; then
    if ! command -v code >/dev/null; then
        fancy_echo "Installing Visual Studio Code text editor using Homebrew ..."
        brew install visual-studio-code
    else
       if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          code --version
          fancy_echo "VS Code already installed: UPGRADE requested..."
          # To avoid response "Error: git not installed" to brew upgrade git
          brew uninstall visual-studio-code
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

   #fancy_echo "Opening Visual Studio Code ..."
   #open "/Applications/Visual Studio Code.app"
   fancy_echo "Starting code in background ..."
   code &
fi


if [[ "$GIT_EDITOR" == *"atom"* ]]; then
   if ! command -v atom >/dev/null; then
      fancy_echo "Installing GIT_EDITOR=\"atom\" text editor using Homebrew ..."
      brew cask install --appdir="/Applications" atom
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
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

   # Configure plug-ins:
   #apm install linter-shellcheck

   atom --version
      # Atom    : 1.20.1
      # Electron: 1.6.9
      # Chrome  : 56.0.2924.87
      # Node    : 7.4.0
      # Wilsons-MacBook-Pro

   fancy_echo "Starting atom in background ..."
   atom &
fi


if [[ "$GIT_EDITOR" == *"macvim"* ]]; then
    if [ ! -d "/Applications/MacVim.app" ]; then
        fancy_echo "Installing GIT_EDITOR=\"macvim\" text editor using Homebrew ..."
        brew cask install --appdir="/Applications" macvim
    else
       if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          # TODO: macvim --version
             # 
          fancy_echo "GIT_EDITOR=\"macvim\" already installed: UPGRADE requested..."
          # To avoid response "==> No Casks to upgrade" on uprade:
          brew cask uninstall macvim
          brew cask install --appdir="/Applications" macvim
          # TODO: Configure macvim text editor using bash shell commands.
       else
          fancy_echo "GIT_EDITOR=\"macvim\" already installed:"
       fi
    fi
   # git config --global core.editor macvim
   # TODO: macvim --version
   #fancy_echo "Starting macvim in background ..."
   #macvim &
fi


if [[ "$GIT_EDITOR" == *"textmate"* ]]; then
    if [ ! -d "/Applications/textmate.app" ]; then 
        fancy_echo "Installing GIT_EDITOR=\"textmate\" text editor using Homebrew ..."
        brew cask install --appdir="/Applications" textmate
    else
       if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          mate -v
          fancy_echo "GIT_EDITOR=\"textmate\" already installed: UPGRADE requested..."
          brew cask uninstall textmate
          brew cask install --appdir="/Applications" textmate
          # TODO: Configure textmate text editor using bash shell commands.
       else
          fancy_echo "GIT_EDITOR=\"textmate\" already installed:"
       fi
   fi

        # Per https://stackoverflow.com/questions/4011707/how-to-start-textmate-in-command-line
        # Create a symboling link to bin folder
        ln -s /Applications/TextMate.app/Contents/Resources/mate $HOME/bin/mate

        if grep -q "export EDITOR=" "$BASHFILE" ; then    
           fancy_echo "export EDITOR= already in $BASHFILE."
        else
           fancy_echo "Concatenating \"export EDITOR=\" in $BASHFILE..."
           echo "export EDITOR=\"/usr/local/bin/mate -w\" " >>"$BASHFILE"
        fi 
   mate -v
      #mate 2.12 (2018-03-08) 
   git config --global core.editor textmate

   fancy_echo "Starting mate (textmate) in background ..."
   mate &
fi


if [[ "$GIT_EDITOR" == *"emacs"* ]]; then
    if ! command -v emacs >/dev/null; then
        fancy_echo "Installing emacs text editor using Homebrew ..."
        brew cask install --appdir="/Applications" emacs
    else
       if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          emacs --version
             # /usr/local/bin/emacs:41: warning: Insecure world writable dir /Users/wilsonmar/gits/wilsonmar in PATH, mode 040777
             # GNU Emacs 25.3.1
          fancy_echo "emacs already installed: UPGRADE requested..."
          brew cask upgrade emacs
          # TODO: Configure emacs using bash shell commands.
       else
          fancy_echo "emacs already installed:"
       fi
    fi
    git config --global core.editor emacs
    emacs --version

    # Evaluate https://github.com/git/git/tree/master/contrib/emacs

   fancy_echo "Opening emacs in background ..."
   emacs &
fi


if [[ "$GIT_EDITOR" == *"intellij"* ]]; then
    # See http://macappstore.org/intellij-idea-ce/
   if [ ! -d "/Applications/IntelliJ IDEA CE.app" ]; then 
       fancy_echo "Installing GIT_EDITOR=\"intellij\" text editor using Homebrew ..."
       brew cask install --appdir="/Applications" intellij-idea-ce 
       # alias idea='open -a "`ls -dt /Applications/IntelliJ\ IDEA*|head -1`"'
        # TODO: Configure intellij text editor using bash shell commands.
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         # TODO: idea  --version
            # 
         fancy_echo "GIT_EDITOR=\"intellij\" already installed: UPGRADE requested..."
         brew cask upgrade intellij-idea-ce 
      else
         fancy_echo "GIT_EDITOR=\"intellij\" already installed:"
      fi
    fi

    # See https://emmanuelbernard.com/blog/2017/02/27/start-intellij-idea-command-line/   
        if grep -q "alias idea=" "$BASHFILE" ; then    
           fancy_echo "alias idea= already in $BASHFILE."
        else
           fancy_echo "Concatenating \"alias idea=\" in $BASHFILE..."
           echo "alias idea='open -a \"`ls -dt /Applications/IntelliJ\ IDEA*|head -1`\"'" >>"$BASHFILE"
           source "$BASHFILE"
        fi 
    git config --global core.editor idea
    # TODO: idea --version

   #fancy_echo "Opening IntelliJ IDEA CE ..."
   #open "/Applications/IntelliJ IDEA CE.app"
   fancy_echo "Opening (Intellij) idea in background ..."
   idea &
fi
# See https://www.jetbrains.com/help/idea/using-git-integration.html

# https://gerrit-review.googlesource.com/Documentation/dev-intellij.html


if [[ "$GIT_EDITOR" == *"sts"* ]]; then
    # See http://macappstore.org/sts/
    if [ ! -d "/Applications/STS.app" ]; then 
        fancy_echo "Installing GIT_EDITOR=\"sts\" text editor using Homebrew ..."
        brew cask install --appdir="/Applications" sts
    else
       if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          # TODO: sts --version
             # 
          fancy_echo "GIT_EDITOR=\"sts\" already installed: UPGRADE requested..."
          brew cask uninstall sts
          brew cask install --appdir="/Applications" sts
          # TODO: Configure sts text editor using bash shell commands.
       else
          fancy_echo "GIT_EDITOR=\"sts\" already installed:"
       fi
    fi
    # Based on https://emmanuelbernard.com/blog/2017/02/27/start-intellij-idea-command-line/   
        if grep -q "alias sts=" "$BASHFILE" ; then    
           fancy_echo "alias sts= already in $BASHFILE."
        else
           fancy_echo "Concatenating \"export sts=\" in $BASHFILE..."
           echo " " >>"$BASHFILE"
           echo "alias sts='open -a \"/Applications/STS.app\"'" >>"$BASHFILE"
           source "$BASHFILE"
        fi 
    git config --global core.editor sts
    # TODO: sts --version

   #fancy_echo "Opening STS ..."
   #open "/Applications/STS.app"
   fancy_echo "Opening sts in background ..."
   sts &
fi


if [[ "$GIT_EDITOR" == *"eclipse"* ]]; then
    # See http://macappstore.org/eclipse-ide/
    if [ ! -d "/Applications/Eclipse.app" ]; then 
        fancy_echo "Installing GIT_EDITOR=\"eclipse\" text editor using Homebrew ..."
        brew cask install --appdir="/Applications" eclipse-ide
    else
       if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          # TODO: eclipse-ide --version
             # 
          fancy_echo "GIT_EDITOR=\"eclipse\" already installed: UPGRADE requested..."
          brew cask uninstall eclipse-ide
          brew cask install --appdir="/Applications" eclipse-ide
          # TODO: Configure eclipse text editor using bash shell commands.
       else
          fancy_echo "GIT_EDITOR=\"eclipse\" already installed:"
       fi
    fi

   if grep -q "alias eclipse=" "$BASHFILE" ; then    
       fancy_echo "alias eclipse= already in $BASHFILE."
   else
       fancy_echo "Concatenating \"alias eclipse=\" in $BASHFILE..."
       echo "alias eclipse='open \"/Applications/Eclipse.app\"'" >>"$BASHFILE"
       source "$BASHFILE"
   fi 
   #git config --global core.editor eclipse

   # See http://www.codeaffine.com/gonsole/ = Git Console for the Eclipse IDE (plug-in)
   # https://rherrmann.github.io/gonsole/repository/
   # The plug-in uses JGit, a pure Java implementation of Git, to interact with the repository.
   #git config --global core.editor eclipse
   # TODO: eclipse-ide --version

   fancy_echo "Opening eclipse in background ..."
   eclipse &
   # See https://www.cs.colostate.edu/helpdocs/eclipseCommLineArgs.html
fi


######### Eclipse settings:

# Add the "clean-sheet" Ergonomic Eclipse Theme for Windows 10 and Mac OS X.
# http://www.codeaffine.com/2015/11/04/clean-sheet-an-ergonomic-eclipse-theme-for-windows-10/


######### ~/.gitconfig [user] and [core] settings:


# ~/.gitconfig file contain this examples:
#[user]
#	name = Wilson Mar
#	id = WilsonMar+GitHub@gmail.com
#	email = wilsonmar+github@gmail.com

   fancy_echo "Adding [user] info in in $GITCONFIG ..."
   git config --global user.name     "$GIT_NAME"
   git config --global user.email    "$GIT_EMAIL"
   git config --global user.id       "$GIT_ID"
   git config --global user.username "$GIT_USERNAME"

#[core]
#	# Use custom `.gitignore`
#	excludesfile = ~/.gitignore
#   hitespace = space-before-tab,indent-with-non-tab,trailing-space

#fancy_echo "Configuring core git settings ..."
   # Use custom `.gitignore`
   git config --global core.excludesfile "~/.gitignore"
   # Treat spaces before tabs, lines that are indented with 8 or more spaces, and all kinds of trailing whitespace as an error
   git config --global core.hitespace "space-before-tab,indent-with-non-tab,trailing-space"


######### Gitconfig command coloring in .gitconfig:


# If git config color.ui returns true, skip:
git config color.ui | grep 'true' &> /dev/null
if [ $? == 0 ]; then
   fancy_echo "git config --global color.ui already true (on)."
else # false or blank response:
   fancy_echo "Setting git config --global color.ui true (on)..."
   git config --global color.ui true
fi

#[color]
#	ui = true

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


######### Reuse Recorded Resolution of conflicted merges


# See https://git-scm.com/docs/git-rerere
# and https://git-scm.com/book/en/v2/Git-Tools-Rerere

#[rerere]
#  enabled = 1
#  autoupdate = 1
   git config --global rerere.enabled  "1"
   git config --global rerere.autoupdate  "1"


######### Diff/merge tools:


# Based on https://gist.github.com/tony4d/3454372 
fancy_echo "Configuring to enable git mergetool..."
if [[ $GITCONFIG = *"[difftool]"* ]]; then  # contains text.
   fancy_echo "[difftool] p4merge already in $GITCONFIG"
else
   fancy_echo "Adding [difftool] p4merge in $GITCONFIG..."
   git config --global merge.tool p4mergetool
   git config --global mergetool.p4mergetool.cmd "/Applications/p4merge.app/Contents/Resources/launchp4merge \$PWD/\$BASE \$PWD/\$REMOTE \$PWD/\$LOCAL \$PWD/\$MERGED"
   # false = prompting:
   git config --global mergetool.p4mergetool.trustExitCode false
   git config --global mergetool.keepBackup true

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




######### ~/.bash_profile prompt settings:


# https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
# See http://maximomussini.com/posts/bash-git-prompt/

# BTW, for completion of bash commands on MacOS:
# brew install bash-completion
# Also see https://github.com/barryclark/bashstrap

if ! command -v brew >/dev/null; then
   fancy_echo "Installing bash-git-prompt using Homebrew ..."
   # From https://github.com/magicmonty/bash-git-prompt
   brew install bash-git-prompt

   if grep -q "gitprompt.sh" "$BASHFILE" ; then    
      fancy_echo "gitprompt.sh already in $BASHFILE"
   else
      fancy_echo "Adding gitprompt.sh in $BASHFILE..."
      echo "if [ -f \"/usr/local/opt/bash-git-prompt/share/gitprompt.sh\" ]; then" >>"$BASHFILE"
      echo "   __GIT_PROMPT_DIR=\"/usr/local/opt/bash-git-prompt/share\" " >>"$BASHFILE"
      echo "   source \"/usr/local/opt/bash-git-prompt/share/gitprompt.sh\" " >>"$BASHFILE"
      echo "fi" >>"$BASHFILE"
   fi
else
    if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
       # ?  --version
       fancy_echo "Brew already installed: UPGRADE requested..."
       brew upgrade bash-git-prompt
    else
       fancy_echo "brew bash-git-prompt already installed:"
    fi
fi
# ? --version


######### bash command completion 


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


######### Git alias keys


# If in verbose mode:
fancy_echo "$GITCONFIG:"
# cat $GITCONFIG  # List contents of ~/.gitconfig

fancy_echo "git config --list:"
git config --list

# If git-completion.bash file is not already in  ~/.bash_profile, add it:
if grep -q "$FILEPATH" "$BASHFILE" ; then    
   fancy_echo "$FILEPATH already in $BASHFILE"
else
   fancy_echo "Adding code for $FILEPATH in $BASHFILE..."
   echo "# Added by mac-git-install.sh ::" >>"$BASHFILE"
   echo "if [ -f $FILEPATH ]; then" >>"$BASHFILE"
   echo "   . $FILEPATH" >>"$BASHFILE"
   echo "fi" >>"$BASHFILE"
   cat $FILEPATH >>"$BASHFILE"
fi 


# If GPG suite is not used, add the GPG key to ~/.bash_profile:
if grep -q "GPG_TTY" "$BASHFILE" ; then    
   fancy_echo "GPG_TTY already in $BASHFILE."
else
   fancy_echo "Concatenating GPG_TTY export in $BASHFILE..."
   echo "export GPG_TTY=$(tty)" >> "$BASHFILE"
      # echo $(tty) results in: -bash: /dev/ttys003: Permission denied
fi 

# Run .bash_profile to have changes above take:
   source "$BASHFILE"


######### Difference engine p4merge:


# TODO: Different diff/merge engines

# See https://www.perforce.com/products/helix-core-apps/merge-diff-tool-p4merge
if [ ! -d "/Applications/p4merge.app" ]; then 
    fancy_echo "Installing p4merge diff engine app using Homebrew ..."
    brew cask install --appdir="/Applications" p4merge
    # TODO: Configure p4merge using shell commands.
else
    if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
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
   echo "alias p4merge='/Applications/p4merge.app/Contents/MacOS/p4merge'" >>"$BASHFILE"
fi 


######### Git Repository:

   git config --global github.user   "$GITHUB_ACCOUNT"
   git config --global github.token  token

# https://github.com/
# https://gitlab.com/
# https://bitbucket.org/
# https://travis-ci.org/


######### TODO: Git Flow helper:


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
   fancy_echo "git-flow already installed."
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



######### TODO: Code review:


# Prerequisite: Python
# sudo easy_install pip
# sudo pip install -U setuptools
# sudo pip install git-review


######### TODO: git local hooks 


# Based https://wilsonmar.github.io/git-hooks/
if [ ! -f ".git/hooks/git-commit" ]; then 
   fancy_echo "git-commit file not found in .git/hooks. Copying ..."
   cp hooks/* .git/hooks
   chmod +x .git/hooks
else
   fancy_echo "git-commit file found in .git/hooks. Skipping ..."
fi
exit

# For more, see https://github.com/git/git/tree/master/contrib/hooks


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
    if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
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
   brew cask install --appdir="/Applications" gpg-suite  # See http://macappstore.org/gpgtools/
   # Renamed from gpgtools https://github.com/caskroom/homebrew-cask/issues/39862
   # See https://gpgtools.org/
else
    if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
       fancy_echo "gpg-suite app already installed: UPGRADE requested..."
       brew cask reinstall gpg-suite 
    else
       fancy_echo "gpg-suite app already installed:"
    fi
fi
# TODO: How to gpg-suite --version


# Per https://gist.github.com/danieleggert/b029d44d4a54b328c0bac65d46ba4c65
# git config --global gpg.program /usr/local/MacGPG2/bin/gpg2


   fancy_echo "Looking in ${#str} byte key chain for GIT_ID=$GIT_ID ..."
   str="$(gpg --list-secret-keys --keyid-format LONG )"
   # RESPONSE FIRST TIME: gpg: /Users/wilsonmar/.gnupg/trustdb.gpg: trustdb created
   echo "$str"
   # Using regex per http://tldp.org/LDP/abs/html/bashver3.html#REGEXMATCHREF
if [[ "$str" =~ "$GIT_ID" ]]; then 
   fancy_echo "A GPG key for $GIT_ID already generated."
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

   fancy_echo "Retrieve from response Key for $GIT_ID ..."
   # Thanks to Wisdom Hambolu (wisyhambolu@gmail.com) for this:
   KEY=$(GPG_MAP_MAIL2KEY "$GIT_ID")  # 16 chars. 

# TODO: Store your GPG key passphrase so you don't have to enter it every time you 
#       sign a commit by using https://gpgtools.org/

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
# if coding suggested by https://github.com/koalaman/shellcheck/wiki/SC2181
if [ $? == 0 ]; then
   fancy_echo "git config commit.gpgsign already true (on)."
else # false or blank response:
   fancy_echo "Setting git config commit.gpgsign false (off)..."
   git config --global commit.gpgsign false
   fancy_echo "To activate: git config --global commit.gpgsign true"
fi


######### TODO: Insert GPG in GitHub:


# https://help.github.com/articles/telling-git-about-your-gpg-key/
# From https://gist.github.com/danieleggert/b029d44d4a54b328c0bac65d46ba4c65
# Add public GPG key to GitHub
# open https://github.com/settings/keys
# keybase pgp export -q $KEY | pbcopy

# https://help.github.com/articles/adding-a-new-gpg-key-to-your-github-account/


#########  brew cleanup


#brew cleanup --force
#rm -f -r /Library/Caches/Homebrew/*


######### Google Cloud CLI/SDK


# See https://cloud.google.com/sdk/docs/
echo "CLOUD=$CLOUD"

# See https://wilsonmar.github.io/gcp
if [[ $CLOUD == *"gcp"* ]]; then  # contains gcp.
   if [ ! -f "$(command -v gcloud) " ]; then  # /usr/local/bin/gcloud not installed
      fancy_echo "Installing CLOUD=$CLOUD = brew cask install google-cloud-sdk ..."
      PYTHON_INSTALL  # function defined at top of this file.
      brew tap caskroom/cask
      brew cask install google-cloud-sdk  # to ./google-cloud-sdk
      gcloud --version
         # Google Cloud SDK 194.0.0
         # bq 2.0.30
         # core 2018.03.16
         # gsutil 4.29
   else
      fancy_echo "CLOUD=$CLOUD = google-cloud-sdk already installed."
   fi
   # NOTE: gcloud command on its own results in an error.

   # Define alias:
      if grep -q "alias gcs=" "$BASHFILE" ; then    
         fancy_echo "alias gcs= already in $BASHFILE"
      else
         fancy_echo "Adding alias gcs in $BASHFILE ..."
         echo "alias gcs='cd ~/.google-cloud-sdk;ls'" >>"$BASHFILE"
      fi

   fancy_echo "Run \"gcloud init\" "
   # See https://cloud.google.com/appengine/docs/standard/python/tools/using-local-server
   # about creating the app.yaml configuration file and running dev_appserver.py  --port=8085
   fancy_echo "Run \"gcloud auth login\" for web page to authenticate login."
      # successful auth leads to https://cloud.google.com/sdk/auth_success
   fancy_echo "Run \"gcloud config set account your-account\""
      # Response is "Updated property [core/account]."
fi


if [[ $CLOUD == *"aws"* ]]; then  # contains aws.
   fancy_echo "awscli requires Python3."
   # See https://docs.aws.amazon.com/cli/latest/userguide/cli-install-macos.html#awscli-install-osx-pip
   PYTHON3_INSTALL  # function defined at top of this file.
   # :  # break out immediately. Not execute the rest of the if strucutre.

   if ! command -v aws >/dev/null; then
      fancy_echo "Installing awscli using PIP ..."
      pip3 install awscli --upgrade --user
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "awscli already installed: UPGRADE requested..."
         aws --version
            # aws-cli/1.11.160 Python/2.7.10 Darwin/17.4.0 botocore/1.7.18
         pip3 upgrade awscli --upgrade --user
      else
         fancy_echo "awscli already installed."
      fi
   fi
   aws --version
            # aws-cli/1.11.160 Python/2.7.10 Darwin/17.4.0 botocore/1.7.18
fi


if [[ $CLOUD == *"azure"* ]]; then  # contains azure.
   # See https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos?view=azure-cli-latest
   # Issues at https://github.com/Azure/azure-cli/issues

   # NOTE: The az CLI does not use a Python virtual environment. So ...
   PYTHON3_INSTALL  # function defined at top of this file.
   # Python location '/usr/local/opt/python/bin/python3.6'

   if ! command -v az >/dev/null; then  # not installed.
      fancy_echo "Installing azure using Homebrew ..."
      brew install azure-cli
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "azure-cli already installed: UPGRADE requested..."
         az --version | grep azure-cli
            # azure-cli (2.0.18)
            # ... and many other lines.
         brew upgrade azure-cli
      else
         fancy_echo "azure-cli already installed."
      fi
   fi
   az --version | grep azure-cli
      # azure-cli (2.0.30)
      # ... and many other lines.
fi


# IBM's Cloud CLI is installed on MacOS by package IBM_Cloud_CLI_0.6.6.pkg from
# page https://console.bluemix.net/docs/cli/reference/bluemix_cli/get_started.html#getting-started
# or curl -fsSL https://clis.ng.bluemix.net/install/osx | sh
# The command is "bx login".
# IBM's BlueMix cloud for AI has a pre-prequisite in NodeJs.
# npm install watson-visual-recognition-utils -g
* npm install watson-speech-to-text-utils -g
# See https://www.ibm.com/blogs/bluemix/2017/02/command-line-tools-watson-services/


######### SSH-KeyGen:


#RANDOM=$((1 + RANDOM % 1000))  # 5 digit random number.
#FILE="$USER@$(uname -n)-$RANDOM"  # computer node name.
FILE="$USER@$(uname -n)"  # computer node name.
fancy_echo "Diving into folder ~/.ssh ..."

if [ ! -d ".ssh" ]; then # found:
   fancy_echo "Making ~/.ssh folder ..."
   mkdir ~/.ssh
fi

pushd ~/.ssh  # specification of folder didn't work.
FILEPATH="$HOME/.ssh/$FILE"
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
cat "$SSHCONFIG"


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
   echo "and paste into GitHub, Settings, New SSH Key ..."
   open https://github.com/settings/keys
   ## TODO: Add a token using GitHub API from credentials in .secrets.sh 

   fancy_echo "Pop up from folder ~/.ssh ..."
   popd

TIME_END=$(date -u +%s);
DIFF=$((TIME_END-TIME_START))
fancy_echo "End of script after $((DIFF/60))m $((DIFF%60))s seconds elapsed."
