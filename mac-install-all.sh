#!/usr/local/bin/bash

# mac-install-all.sh in https://github.com/wilsonmar/DevSecOps
# This downloads and installs all the utilities related to use of Git,
# customized based on specification in file secrets.sh within the same repo.
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/???/master/macos-install-all.sh)"

# See https://github.com/wilsonmar/git-utilities/blob/master/README.md
# Based on https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup
# and https://git-scm.com/docs/git-config
# and https://medium.com/my-name-is-midori/how-to-prepare-your-fresh-mac-for-software-development-b841c05db18
# https://www.bonusbits.com/wiki/Reference:Mac_OS_DevOps_Workstation_Setup_Check_List

# TOC: Functions (GPG_MAP_MAIL2KEY, Python, Python3, Java, Node, Go, Docker) > 
# Starting: Secrets > XCode > XCode/Ruby > bash.profile > Brew > gitconfig > gitignore > Git web browsers > p4merge > linters > Git clients > git users > git tig > BFG > gitattributes > Text Editors > git [core] > git coloring > rerere > prompts > bash command completion > git command completion > Git alias keys > Git repos > git flow > git hooks > Large File Storage > gcviewer, jmeter, jprofiler > code review > git signing > Cloud CLI/SDK > Selenium > SSH KeyGen > SSH Config > Paste SSH Keys in GitHub > GitHub Hub > dump contents > disk space > show log

# set -o nounset -o pipefail -o errexit  # "strict mode"
# set -u  # -uninitialised variable exits script.
# set -e  # -exit the script if any statement returns a non-true return value.
# set -a  # Mark variables which are modified or created for export. Each variable or function that is created or modified is given the export attribute and marked for export to the environment of subsequent commands. 
# set -v  # -verbose Prints shell input lines as they are read.
#bar=${MY_RUNTYPE:-none} # :- sets undefine value. See http://redsymbol.net/articles/unofficial-bash-strict-mode/
IFS=$'\n\t'  # Internal Field Separator for word splitting is line or tab, not spaces.
#trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT
trap cleanup EXIT
trap sig_cleanup INT QUIT TERM


function fancy_echo() {
  local fmt="$1"; shift
  printf "\\n>>> $fmt\\n" "$@"
}
# From https://gist.github.com/somebox/6b00f47451956c1af6b4
function echo_ok { echo -e '\033[1;32m'"$1"'\033[0m'; }
function echo_warn { echo -e '\033[1;33m'"$1"'\033[0m'; }
function echo_error  { echo -e '\033[1;31mERROR: '"$1"'\033[0m'; }


######### Starting time stamp, OS versions, command attributes:


# For Git on Windows, see http://www.rolandfg.net/2014/05/04/intellij-idea-and-git-on-windows/
TIME_START="$(date -u +%s)"
FREE_DISKBLOCKS_START="$(df | sed -n -e '2{p;q}' | cut -d' ' -f 6)"

# ISO-8601 plus RANDOM=$((1 + RANDOM % 1000))  # 3 digit random number.
LOG_PREFIX=$(date +%Y-%m-%dT%H:%M:%S%z)-$((1 + RANDOM % 1000))
LOGFILE="$0.$LOG_PREFIX.log"
if [ ! -z $1 ]; then  # not empty
   echo "$0 $1 starting with logging to file:" >$LOGFILE  # new file
else
   echo "$0 starting with logging to file:" >$LOGFILE  # new file
fi
echo "$LOGFILE ..."      >>$LOGFILE
fancy_echo "sw_vers ::"     >>$LOGFILE
 echo -e "$(sw_vers)"       >>$LOGFILE
fancy_echo "uname -a ::"    >>$LOGFILE
 echo -e "$(uname -a)"      >>$LOGFILE


######### Bash utility functions:


function cleanup() {
    err=$?
    echo "At cleanup() LOGFILE=$LOGFILE"
    open -a "TextEdit" $LOGFILE
    #nano $LOGFILE
    trap '' EXIT INT TERM
    exit $err 
}

cleanup2() {
    err=$?
    echo "At cleanup() LOGFILE=$LOGFILE"
    # pico $LOGFILE
    trap '' EXIT INT TERM
    exit $err 
}
sig_cleanup() {
    trap '' EXIT # some shells will call EXIT after the INT handler
    false # sets $?
    cleanup
}


# Read first parameter from command line supplied at runtime to invoke:
MY_RUNTYPE="$1"
if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then # variable made lower case.
   echo "MY_RUNTYPE=\"$MY_RUNTYPE\" means all packages here will be upgraded ..." >>$LOGFILE
fi


######### Git functions:


# Based on https://gist.github.com/dciccale/5560837
# Usage: GIT_BRANCH=$(parse_git_branch)$(parse_git_hash) && echo ${GIT_BRANCH}
# Check if branch has something pending:
function git_parse_dirty() {
   git diff --quiet --ignore-submodules HEAD 2>/dev/null; [ $? -eq 1 ] && echo "*"
}
# Get the current git branch (using git_parse_dirty):
function git_parse_branch() {
   git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(git_parse_dirty)/"
}
# Get last commit hash prepended with @ (i.e. @8a323d0):
function git_parse_hash() {
   git rev-parse --short HEAD 2> /dev/null | sed "s/\(.*\)/@\1/"
}


######### Bash function definitions:


# Add function to read in string and email, and return a KEY found for that email.
# GPG_MAP_MAIL2KEY associates the key and email in an array
function GPG_MAP_MAIL2KEY(){
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

function VIRTUALBOX_INSTALL(){
   if [ ! -d "/Applications/VirtualBox.app" ]; then 
   #if ! command -v virtualbox >/dev/null; then  # /usr/local/bin/virtualbox
      fancy_echo "Installing virtualbox ..."
      brew cask install --appdir="/Applications" virtualbox
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "virtualbox upgrading ..."
         # virtualbox --version
         brew cask upgrade virtualbox
      else
         fancy_echo "virtualbox already installed." >>$LOGFILE
      fi
   fi
   #echo -e "\n$(virtualbox --version)" >>$LOGFILE

   if [ ! -d "/Applications/Vagrant Manager.app" ]; then 
      fancy_echo "Installing vagrant-manager ..."
      brew cask install --appdir="/Applications" vagrant-manager
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "vagrant-manager upgrading ..."
         brew cask upgrade vagrant-manager
      else
         fancy_echo "vagrant-manager already installed." >>$LOGFILE
      fi
   fi
}

function PYTHON_INSTALL(){
   # Python2 is a pre-requisite for git-cola & GCP installed below.
   # Python3 is a pre-requisite for aws.
   # Because there are two active versions of Pythong (2.7.4 and 3.6 now)...
     # See https://docs.brew.sh/Homebrew-and-Python
   # See https://docs.python-guide.org/en/latest/starting/install3/osx/
   
   if ! command -v python >/dev/null; then
      # No upgrade option.
      fancy_echo "Installing Python, a pre-requisite for git-cola & GCP ..."
      brew install python
      # Not brew install pyenv  # Python environment manager.

	  #brew linkapps python

      # pip comes with brew install Python 2 >=2.7.9 or Python 3 >=3.4
      pip --version

   else
      fancy_echo -e "\n$(python --version) already installed:" >>$LOGFILE
   fi
   command -v python
   ls -al "$(command -v python)" # /usr/local/bin/python

   echo -e "\n$(python --version)"            >>$LOGFILE
         # Python 2.7.14
   echo -e "\n$(pip --version)"            >>$LOGFILE
         # pip 9.0.3 from /usr/local/lib/python2.7/site-packages (python 2.7)

   # Define command python as going to version 2.7:
      if grep -q "alias python=" "$BASHFILE" ; then    
         fancy_echo "Python 2.7 alias already in $BASHFILE" >>$LOGFILE
      else
         fancy_echo "Adding Python 2.7 alias in $BASHFILE ..."
         echo "export alias python=/usr/local/bin/python2.7" >>"$BASHFILE"
      fi
   
      # To prevent the older MacOS default python being seen first in PATH ...
      if grep -q "/usr/local/opt/python/libexec/bin" "$BASHFILE" ; then    
         fancy_echo "Python PATH already in $BASHFILE" >>$LOGFILE
      else
         fancy_echo "Adding Python PATH in $BASHFILE..."
         echo "export PATH=\"/usr/local/opt/python/libexec/bin:$PATH\"" >>"$BASHFILE"
      fi

         # Run .bash_profile to have changes take, run $FILEPATH:
         source "$BASHFILE"
         #echo "$PATH"

      # TODO: Python add-ons
      #brew install freetype  # http://www.freetype.org to render fonts
      #brew install openexr
      #brew install freeimage
      #brew install gmp
      #fancy_echo "Installing other popular Python helper modules ..."
      #pip install jupyter
      #pip install numpy
      #pip install scipy
      #pip install matplotlib
      #pip install ipython[all]	  
  
   # There is also a Enthought Python Distribution -- www.enthought.com
}

function PYTHON3_INSTALL(){
   fancy_echo "Installing Python3 is a pre-requisite for AWS-CLI"
   # Because there are two active versions of Python (2.7.4 and 3.6 now)...
     # See https://docs.brew.sh/Homebrew-and-Python
   # See https://docs.python-guide.org/en/latest/starting/install3/osx/
   
   if ! command -v python3 >/dev/null; then
      # No upgrade option.
      fancy_echo "Installing Python3, a pre-requisite for awscli and azure ..."
      brew install python3

      # 
      # To use anaconda, add the /usr/local/anaconda3/bin directory to your PATH environment 
      # variable, eg (for bash shell):
      # export PATH=/usr/local/anaconda3/bin:"$PATH"
      #brew doctor fails run here due to /usr/local/anaconda3/bin/curl-config, etc.
      #Cask anaconda installs files under "/usr/local". The presence of such
      #files can cause warnings when running "brew doctor", which is considered
      #to be a bug in Homebrew-Cask.
   fi
   command -v python3 >>$LOGFILE
   ls -al "$(command -v python3)" # /usr/local/bin/python

   echo -e "\n$(python3 --version)"            >>$LOGFILE
      # Python 3.6.4
   echo -e "\n$(pip3 --version)"            >>$LOGFILE
      # pip 9.0.3 from /usr/local/lib/python3.6/site-packages (python 3.6)

   # NOTE: To make "python" command reach Python3 instead of 2.7, per docs.python-guide.org/en/latest/starting/install3/osx/
   # Put in PATH Python 3.6 bits at /usr/local/bin/ before Python 2.7 bits at /usr/bin/

   if [[ "$PYTHON_TOOLS" == *"anaconda"* ]]; then
      if [ ! -d "/Applications/Google Chrome.app" ]; then 
      # if ! command -v anaconda >/dev/null; then  # /usr/bin/anacondadriver
         fancy_echo "Installing PYTHON_TOOLS=\"anaconda\" for libraries ..."
         brew cask install --appdir="/Applications" anaconda
      else
         if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
            fancy_echo "PYTHON_TOOLS=\"anaconda upgrading ..."
            anaconda --version  # anaconda 5.1.0
            brew cask upgrade anaconda
         fi
      fi
      #fancy_echo "Opening PYTHON_TOOLS=\" ..."
      #anaconda
      echo -e "\n  anaconda" >>$LOGFILE
      echo -e "$(anaconda --version)" >>$LOGFILE
      echo -e "$(conda list)" >>$LOGFILE

      if grep -q "/usr/local/anaconda3/bin" "$BASHFILE" ; then    
         fancy_echo "anaconda3 PATH already in $BASHFILE"
      else
         fancy_echo "Adding anaconda3 PATH in $BASHFILE..."
         echo "export PATH=\"/usr/local/anaconda3/bin:$PATH\"" >>"$BASHFILE"
      fi

   # QUESTION: What is the MacOS equivalent to pipe every .py file to anaconda's python:
   # assoc .py=Python.File
   # ftype Python.File=C:\path\to\Anaconda\python.exe "%1" %*

   fi

}

function JAVA_INSTALL(){
   # See https://wilsonmar.github.io/java-on-apple-mac-osx/
   # and http://sourabhbajaj.com/mac-setup/Java/
   if ! command -v java >/dev/null; then
      # /usr/bin/java
      fancy_echo "Installing Java, a pre-requisite for Selenium, JMeter, etc. ..."
      # Don't rely on Oracle to install Java properly on your Mac.
      brew tap caskroom/versions
      brew cask install --appdir="/Applications" java8
      # CAUTION: A specific version of JVM needs to be specified because code that use it need to be upgraded.
   fi

   TEMP=$(java -version | grep "java version") # | cut -d'=' -f 2 ) # | awk -F= '{ print $2 }'
   JAVA_VERSION=${TEMP#*=};
   echo "JAVA_VERSION=$JAVA_VERSION"
   export JAVA_VERSION=$(java -version)
   echo -e "\n$(java -version)" >>$LOGFILE
      # java version "1.8.0_144"
      # Java(TM) SE Runtime Environment (build 1.8.0_144-b01)
      # Java HotSpot(TM) 64-Bit Server VM (build 25.144-b01, mixed mode)
   echo -e "$($JAVA_HOME)" >>$LOGFILE
      # /Library/Java/JavaVirtualMachines/jdk1.8.0_162.jdk/Contents/Home is a directory

   # https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
   if [ ! -z ${JAVA_HOME+x} ]; then  # variable has NOT been defined already.
      echo "$JAVA_HOME=$JAVA_HOME"
   else 
      echo "JAVA_HOME being set ..." # per http://sourabhbajaj.com/mac-setup/Java/
      echo "export JAVA_HOME=$(/usr/libexec/java_home -v $JAVA_VERSION)" >>$BASHFILE
      #echo "export JAVA_HOME=$(/usr/libexec/java_home -v 9)" >>$BASHFILE
   fi
   # /Library/Java/JavaVirtualMachines/jdk1.8.0_121.jdk/Contents/Home
   #   echo "export IDEA_JDK=$(/usr/libexec/java_home -v $JAVA_VERSION)" >>$BASHFILE
   #   echo "export RUBYMINE_JDK=$(/usr/libexec/java_home -v $JAVA_VERSION)" >>$BASHFILE
      source $BASHFILE

   # TODO: https://github.com/alexkaratarakis/gitattributes/blob/master/Java.gitattributes
}

function NODE_INSTALL(){
   fancy_echo "In function NODE_INSTALL ..."
   # See https://wilsonmar.github.io/node-starter/

   # We begin with NVM to install Node versions: https://www.airpair.com/javascript/node-js-tutorial
   # in order to have several diffent versions of node installed simultaneously.
   # See https://github.com/creationix/nvm
   if [ ! -d "$HOME/.nvm" ]; then
      fancy_echo "Making $HOME/.nvm folder ..."
      mkdir $HOME/.nvm
   fi

   if grep -q "export NVM_DIR=" "$BASHFILE" ; then    
      fancy_echo "export NVM_DIR= already in $BASHFILE"
   else
      fancy_echo "Adding export NVM_DIR= in $BASHFILE..."
      echo "export NVM_DIR=\"$HOME/.nvm\"" >>$BASHFILE
      source $BASHFILE
   fi

   if ! command -v nvm >/dev/null; then  # /usr/local/bin/node
      fancy_echo "Installing nvm (to manage node versions)"
      brew install nvm  # curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
         # 0.33.8 
      # TODO: How to tell if nvm.sh has run?
      fancy_echo "Running /usr/local/opt/nvm/nvm.sh ..."
      source "/usr/local/opt/nvm/nvm.sh"  # nothing returned.
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "nvm upgrading ..."
         brew upgrade nvm
      fi
   fi
   nvm --version  #0.33.8
   
   if ! command -v node >/dev/null; then  # /usr/local/bin/node
      fancy_echo "Installing node using nvm"
      nvm install node  # use nvm to install the latest version of node.
         # v9.10.1...
      nvm install --lts # lastest Long Term Support version  # v8.11.1...
      # nvm install 8.9.4  # install a specific version
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "node upgrading ..."
         # nvm i nvm  # instead of brew upgrade node
      fi
   fi
   node --version

   # $NVM_HOME
   # $NODE_ENV 
}


function GO_INSTALL(){
   if ! command -v go >/dev/null; then  # /usr/local/bin/go
      fancy_echo "Installing go ..."
      brew install go
   else
      # specific to each MacOS version
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "go upgrading ..."
         go version   # upgrading from.
         brew upgrade go
      fi
   fi
   go version  # go version go1.10.1 darwin/amd64

      if grep -q "export GOPATH=" "$BASHFILE" ; then    
         fancy_echo "GOPATH already in $BASHFILE"
      else
         fancy_echo "Adding GOPATH in $BASHFILE..."
         echo "export GOPATH=$HOME/golang" >>"$BASHFILE"
      fi
   
   # export GOROOT=$HOME/go
   # export PATH=$PATH:$GOROOT/bin
}


######### OSX configuration:


fancy_echo "Configure OSX Finder to show hidden files too:" >>$LOGFILE
defaults write com.apple.finder AppleShowAllFiles YES
# NOTE: Additional config dotfiles for Mac?
# NOTE: See osx-init.sh in https://github.com/wilsonmar/DevSecOps/osx-init
#       installs other programs on Macs for developers.


# Ensure Apple's command line tools (such as cc) are installed by node:
if ! command -v cc >/dev/null; then
   fancy_echo "Installing Apple's xcode command line tools (this takes a while) ..."
   xcode-select --install 
   # Xcode installs its git to /usr/bin/git; recent versions of OS X (Yosemite and later) ship with stubs in /usr/bin, which take precedence over this git. 
fi
pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep version
   # Tools_Executables | grep version
   # version: 9.2.0.0.1.1510905681


######### bash completion:

echo -e "$(bash --version | grep 'bash')" >>$LOGFILE

# BREW_VERSION="$(brew --version)"
# TODO: Completion of bash commands on MacOS:
# See https://kubernetes.io/docs/tasks/tools/install-kubectl/#on-macos-using-bash
# Also see https://github.com/barryclark/bashstrap

# TODO: Extract 4 from $BASH_VERSION
      # GNU bash, version 4.4.19(1)-release (x86_64-apple-darwin17.3.0)

## or, if running Bash 4.1+
#brew install bash-completion@2
## If running Bash 3.2 included with macOS
#brew install bash-completion


######### bash.profile configuration:


BASHFILE=$HOME/.bash_profile  # on Macs

# if ~/.bash_profile has not been defined, create it:
if [ ! -f "$BASHFILE" ]; then #  NOT found:
   fancy_echo "Creating blank \"${BASHFILE}\" ..." >>$LOGFILE
   touch "$BASHFILE"
   echo "PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" >>"$BASHFILE"
   # El Capitan no longer allows modifications to /usr/bin, and /usr/local/bin is preferred over /usr/bin, by default.
else
   LINES=$(wc -l < "${BASHFILE}")
   fancy_echo "\"${BASHFILE}\" already created with $LINES lines." >>$LOGFILE
   fancy_echo "Backing up file $BASHFILE to $BASHFILE-$LOG_PREFIX.bak ..."  >>$LOGFILE
   cp "$BASHFILE" "$BASHFILE-$LOG_PREFIX.bak"
fi


###### bash.profile locale settings missing in OS X Lion+:


# See https://stackoverflow.com/questions/7165108/in-os-x-lion-lang-is-not-set-to-utf-8-how-to-fix-it
# https://unix.stackexchange.com/questions/87745/what-does-lc-all-c-do
# LC_ALL forces applications to use the default language for output, and forces sorting to be bytewise.
if grep -q "LC_ALL" "$BASHFILE" ; then    
   fancy_echo "LC_ALL Locale setting already in $BASHFILE" >>$LOGFILE
else
   fancy_echo "Adding LC_ALL Locale in $BASHFILE..." >>$LOGFILE
   echo "# Added by $0 ::" >>"$BASHFILE"
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


if grep -q "export ARCHFLAGS=" "$BASHFILE" ; then    
   fancy_echo "ARCHFLAGS setting already in $BASHFILE" >>$LOGFILE
else
   fancy_echo "Adding ARCHFLAGS in $BASHFILE..." >>$LOGFILE
   echo "export ARCHFLAGS=\"-arch x86_64\"" >>"$BASHFILE"
   source "$BASHFILE"
fi 


###### Install homebrew using whatever Ruby is installed:


# Ruby comes with MacOS:
fancy_echo "Using whatever Ruby version comes with MacOS:" >>$LOGFILE
echo -e "$(ruby -v)"      >>$LOGFILE
   # ruby 2.5.0p0 (2017-12-25 revision 61468) [x86_64-darwin16]

# Set the permissions that Brew expects	
# sudo chflags norestricted /usr/local && sudo chown $(whoami):admin /usr/local && sudo chown -R $(whoami):admin /usr/local

if ! command -v brew >/dev/null; then
    fancy_echo "Installing homebrew using Ruby..."   >>$LOGFILE
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew tap caskroom/cask
else
    # Upgrade if run-time attribute contains "upgrade":
    if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
       fancy_echo "Brew upgrading ..." >>$LOGFILE
       brew --version
       brew upgrade
    fi
fi
#brew --version
echo -e "\n$(brew --version)"  >>$LOGFILE
   # Homebrew 1.5.12
   # Homebrew/homebrew-core (git revision 9a81e; last commit 2018-03-22)


#brew tap caskroom/cask
# Casks are GUI program installers defined in https://github.com/caskroom/homebrew-cask/tree/master/Casks
# brew cask installs GUI apps (see https://caskroom.github.io/)
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

brew analytics off  # see https://github.com/Homebrew/brew/blob/master/docs/Analytics.md


######### Mac tools:


if [[ "$MAC_TOOLS" == *"mas"* ]]; then
   # To manage apps purchased & installed using App Store on MacOS:
   if ! command -v mas >/dev/null; then  # /usr/local/bin/mas
      fancy_echo "Installing MAC_TOOLS mas ..."
      brew install mas
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "Upgrading MAC_TOOLS mas ..."
         mas version  # before upgrade
         brew upgrade mas
      fi
   fi
   echo -e "$(mas version)" >>$LOGFILE  # mas 1.4.1
fi

if [[ "$MAC_TOOLS" == *"ansible"* ]]; then
   # To install programs. See http://wilsonmar.github.io/ansible/
   if ! command -v ansible >/dev/null; then  # /usr/local/bin/ansible
      fancy_echo "Installing MAC_TOOLS ansible ..."
      brew install ansible
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "Upgrading MAC_TOOLS ansible ..."
         ansible --version  # before upgrade
         brew upgrade ansible
      fi
   fi
   echo -e "$(ansible -v)" >>$LOGFILE  # ansible 2.5.0
fi

if [[ "$MAC_TOOLS" == *"1Password"* ]]; then
   # See https://1password.com/ to store secrets on laptops securely.
   if [ ! -d "/Applications/1Password 6.app" ]; then 
   #if ! command -v 1Password >/dev/null; then  # /usr/local/bin/1Password
      fancy_echo "Installing MAC_TOOLS 1Password - password needed ..."
      brew cask install --appdir="/Applications" 1Password
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         # 1Password -v
         fancy_echo "Upgrading MAC_TOOLS 1Password ..."
         brew cask upgrade 1Password
      fi
   fi
   #echo -e "$(1Password -v)" >>$LOGFILE  # 1Password v6.0.0-beta.7
fi

if [[ "$MAC_TOOLS" == *"PowerShell"* ]]; then
    # https://docs.microsoft.com/en-us/powershell/scripting/powershell-scripting?view=powershell-6
   if [ ! -d "/Applications/PowerShell.app" ]; then 
   #if ! command -v PowerShell >/dev/null; then  # /usr/local/bin/PowerShell
      fancy_echo "Installing MAC_TOOLS PowerShell - password needed ..."
      brew cask install --appdir="/Applications" PowerShell
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         # PowerShell -v
         fancy_echo "Upgrading MAC_TOOLS PowerShell ..."
         brew cask upgrade PowerShell
      fi
      if grep -q "alias PowerShell=" "$BASHFILE" ; then
         fancy_echo "PATH to PowerShell.app already in $BASHFILE" >>$LOGFILE
      else
         fancy_echo "Adding PATH to PowerShell.app in $BASHFILE..."
         echo "alias PowerShell='open -a \"/Applications/PowerShell.app\"'" >>"$BASHFILE"
      fi
   fi
   #echo -e "$(PowerShell -v)" >>$LOGFILE  # powershell v6.0.0-beta.7
fi

if [[ "$MAC_TOOLS" == *"kindle"* ]]; then
   # 
   if [ ! -d "/Applications/Kindle.app" ]; then 
      fancy_echo "Installing MAC_TOOLS Kindle - password needed ..."
      brew cask install --appdir="/Applications" kindle
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "Upgrading MAC_TOOLS Kindle ..."
         # kindle -v
         brew cask upgrade kindle
      fi
   fi

      if grep -q "alias kindle=" "$BASHFILE" ; then    
         fancy_echo "PATH to Kindle.app already in $BASHFILE" >>$LOGFILE
      else
         fancy_echo "Adding PATH to Kindle.app in $BASHFILE..."
         echo "alias kindle='open -a \"/Applications/Kindle.app\"'" >>"$BASHFILE"
      fi
   #echo -e "$(Kindle -v)" >>$LOGFILE  # Kindle v6.0.0-beta.7
fi


if [[ "$MAC_TOOLS" == *"mariadb"* ]]; then
   # See https://wilsonmar.github.io/mysql-setup/
   # See https://mariadb.com/kb/en/library/installing-mariadb-on-macos-using-homebrew/
   # A "/etc/my.cnf" from another install may interfere with a Homebrew-built server starting up correctly.
   if [ ! -d "/Applications/mariadb.app" ]; then 
      fancy_echo "Installing MAC_TOOLS mariadb - password needed ..."
      brew install mariadb
      # There is also mariadb@10.0, mariadb@10.1, mariadb-connector-odbc 
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "Upgrading MAC_TOOLS mariadb ..."
         mysql --version
         brew upgrade mariadb
      fi
   fi
   echo -e "$(mysql --version)" >>$LOGFILE 
      # mysql  Ver 15.1 Distrib 10.2.14-MariaDB, for osx10.13 (x86_64) using readline 5.1

   # To avoid problems:
   if [ ! -f "/usr/local/etc/my.cnf.d " ]; then #  NOT found:
      mkdir /usr/local/etc/my.cnf.d 
   fi
   if [[ $TRYOUT == *"mariadb"* ]]; then
      fancy_echo "Starting mariadb ..."
   fi
fi

if [[ "$MAC_TOOLS" == *"others"* ]]; then
      echo "Installing MAC_TOOLS=others ..."; 
#      brew cask install vmware-fusion  # run Windows
#      brew install google-drive
#      brew install dropbox
#      brew install box
#      brew install amazon
#      brew cask install charles  # proxy
#   brew cask install xtrafinder
#   brew cask install sizeup
#   brew cask install bartender   # manage icons at top launch bar
#   brew cask install duet
#   brew cask install logitech-harmony
#   brew cask install cheatsheet
#   brew cask install steam
#   brew cask install fritzing   
#   brew cask install nosleep
#   brew cask install balsamiq-mockups
#   brew cask install brackets
#   brew cask install smartsynchronize
#   brew cask install toggldesktop
#   brew cask install xmind
#   brew cask install webstorm
#   brew install jsdoc3
#   brew cask install appcleaner
#   brew cask install qlcolorcode
#   brew cask install qlstephen
#   brew cask install qlmarkdown
#   brew cask install quicklook-json
#   brew cask install quicklook-csv
#   brew cask install betterzipql
#   brew cask install asepsis
#   brew cask install cheatsheet
fi


######### Install git client to download the rest:


if ! command -v git >/dev/null; then
    fancy_echo "Installing git using Homebrew ..."
    brew install git
else
    if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
       fancy_echo "Git upgrading ..." >>$LOGFILE
       git --version
       # To avoid response "Error: git not installed" to brew upgrade git
       brew uninstall git
       # QUESTION: This removes .gitconfig file?
       brew install git
    fi
fi
echo -e "\n$(git --version)"            >>$LOGFILE
    # git version 2.14.3 (Apple Git-98)


######### Download/clone GITHUB_REPO_URL repo:


# When running from sh -c "$(curl -fsSL 
UTIL_REPO="DevSecOps"
if [ ! -d "$HOME/$UTIL_REPO" ]; then
   GITHUB_REPO_URL="https://github.com/wilsonmar/$UTIL_REPO.git"
   fancy_echo "Cloning in $GITHUB_REPO_URL ..."
   git clone "$GITHUB_REPO_URL" --depth=1  # only master branche, no history
   # List branch and latest commit SHA:
   GIT_BRANCH="branch $(git_parse_branch) commit $(git_parse_hash)" 
   fancy_echo "$GIT_BRANCH"
else
   fancy_echo "$UTIL_REPO found ..."
fi

if [ ! -d "$HOME/$UTIL_REPO" ]; then
   fancy_echo "Directory $HOME/$UTIL_REPO missing despite cloning ..."
else
   cd $HOME/$UTIL_REPO
fi
      # see video: https://asciinema.org/a/41811?autoplay=1
pwd  >>$LOGFILE

exit # DEBUGGING


######### Read and use secrets.sh file:


# If the file still contains defaults, it should not be used:
SECRETSFILE="secrets.sh"
if [ ! -f "$SECRETSFILE" ]; then #  NOT found:
   fancy_echo "$SECRETSFILE not found. Aborting run ..."
   exit
fi

if grep -q "wilsonmar@gmail.com" "$SECRETSFILE" ; then  # not customized:
   fancy_echo "Please edit file $SECRETSFILE with your own credentials. Aborting this run..."
   exit  # so script ends now
else
   fancy_echo "Reading from $SECRETSFILE ..."
   #chmod +x $SECRETSFILE
   source "$SECRETSFILE"

   echo -e "\n   git ls-files -v|grep '^h' ::" >>$LOGFILE
   git update-index --skip-worktree $SECRETSFILE
   echo "$(git ls-files -v|grep '^S')" >>$LOGFILE

   echo -e "\n   $SECRETSFILE ::" >>$LOGFILE
   echo "GIT_NAME=$GIT_NAME">>$LOGFILE
   echo "GIT_ID=$GIT_ID" >>$LOGFILE
   echo "GIT_EMAIL=$GIT_EMAIL" >>$LOGFILE
   echo "GIT_USERNAME=$GIT_USERNAME" >>$LOGFILE
   echo "GITS_PATH=$GITS_PATH" >>$LOGFILE
   echo "GITHUB_ACCOUNT=$GITHUB_ACCOUNT" >>$LOGFILE
   echo "GITHUB_REPO=$GITHUB_REPO" >>$LOGFILE
   # DO NOT echo $GITHUB_PASSWORD. Do not cat $SECRETFILE because it contains secrets.
   echo "GIT_CLIENT=$GIT_CLIENT" >>$LOGFILE
   echo "GIT_EDITOR=$GIT_EDITOR" >>$LOGFILE
   echo "WORK_REPO=$WORK_REPO" >>$LOGFILE # i.e. git://example.com/some-big-repo.git"
   echo "GIT_BROWSER=$GIT_BROWSER" >>$LOGFILE
   echo "GIT_TOOLS=$GIT_TOOLS" >>$LOGFILE
   echo "GIT_LANG=$GUI_LANG" >>$LOGFILE
   echo "TEST_TOOLS=$TEST_TOOLS" >>$LOGFILE
   echo "JAVA_TOOLS=$JAVA_TOOLS" >>$LOGFILE
   echo "PYTHON_TOOLS=$PYTHON_TOOLS" >>$LOGFILE
   echo "CLOUD=$CLOUD" >>$LOGFILE
   echo "TRYOUT=$TRYOUT" >>$LOGFILE
   NGINX_PORT="8087"   # from default 8080
   TOMCAT_PORT="8089"  # from default 8080
fi 



######### ~/.gitconfig initial settings:


GITCONFIG=$HOME/.gitconfig  # file

if [ ! -f "$GITCONFIG" ]; then 
   fancy_echo "$GITCONFIG! file not found."
else
   fancy_echo "Backing up $GITCONFIG-$LOG_PREFIX.bak ..." >>$LOGFILE
   cp "$GITCONFIG" "$GITCONFIG-$LOG_PREFIX.bak"
fi


######### Git web browser setting:


# Install browser using Homebrew to display GitHub to paste SSH key at the end.
fancy_echo "GIT_BROWSER=$GIT_BROWSER in secrets.sh ..."
      echo "The last one installed is set as the Git browser." >>$LOGFILE

if [[ "$GIT_BROWSER" == *"safari"* ]]; then
   if ! command -v safari >/dev/null; then
      fancy_echo "No install needed on MacOS for GIT_BROWSER=\"safari\"."
      # /usr/bin/safaridriver
   else
      fancy_echo "No upgrade on MacOS for GIT_BROWSER=\"safari\"."
   fi
   git config --global web.browser safari

   #fancy_echo "Opening safari ..."
   #safari
fi


# See Complications at
# https://stackoverflow.com/questions/19907152/how-to-set-google-chrome-as-git-default-browser

# [web]
# browser = google-chrome
#[browser "chrome"]
#    cmd = C:/Program Files (x86)/Google/Chrome/Application/chrome.exe
#    path = C:/Program Files (x86)/Google/Chrome/Application/

if [[ "$GIT_BROWSER" == *"chrome"* ]]; then
   # google-chrome is the most tested and popular.
   if [ ! -d "/Applications/Google Chrome.app" ]; then 
      fancy_echo "Installing GIT_BROWSER=\"google-chrome\" using Homebrew ..."
      brew cask uninstall google-chrome
      brew cask install --appdir="/Applications" google-chrome
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "Upgrading GIT_BROWSER=\"google-chrome\" using Homebrew ..."
         brew cask upgrade google-chrome
      else
         fancy_echo "GIT_BROWSER=\"google-chrome\" already installed." >>$LOGFILE
      fi
   fi
   git config --global web.browser google-chrome

   # fancy_echo "Opening Google Chrome ..."
   # open "/Applications/Google Chrome.app"
fi


if [[ "$GIT_BROWSER" == *"firefox"* ]]; then
   # firefox is more respectful of user data.
   if [ ! -d "/Applications/Firefox.app" ]; then 
      fancy_echo "Installing GIT_BROWSER=\"firefox\" using Homebrew ..."
      brew cask uninstall firefox
      brew cask install --appdir="/Applications" firefox
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "Upgrading GIT_BROWSER=\"firefox\" using Homebrew ..."
         brew cask upgrade firefox
      else
   fi
   git config --global web.browser firefox

   #fancy_echo "Opening firefox ..."
   #open "/Applications/Firefox.app"
fi


if [[ "$GIT_BROWSER" == *"brave"* ]]; then
   # brave is more respectful of user data.
   if [ ! -d "/Applications/Brave.app" ]; then 
      fancy_echo "Installing GIT_BROWSER=\"brave\" using Homebrew ..."
      brew cask uninstall brave
      brew cask install --appdir="/Applications" brave
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "Upgrading GIT_BROWSER=\"brave\" using Homebrew ..."
         brew cask upgrade brave
      fi
   fi
   git config --global web.browser brave

   # fancy_echo "Opening brave ..."
   # open "/Applications/brave.app"
fi

# Other alternatives listed at https://git-scm.com/docs/git-web--browse.html

   # brew install links

   #git config --global web.browser cygstart
   #git config --global browser.cygstart.cmd cygstart


######### Diff/merge tools:


# Based on https://gist.github.com/tony4d/3454372 
fancy_echo "Configuring to enable git mergetool..."
if [[ $GITCONFIG = *"[difftool]"* ]]; then  # contains text.
   fancy_echo "[difftool] p4merge already in $GITCONFIG" >>$LOGFILE
else
   fancy_echo "Adding [difftool] p4merge in $GITCONFIG..." >>$LOGFILE
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


######### Local Linter services:


# This Bash file was run through online at https://www.shellcheck.net/
# See https://github.com/koalaman/shellcheck#user-content-in-your-editor

# To ignore/override an error identified:
# shellcheck disable=SC1091

#brew install shellcheck

# This enables Git hooks to run on pre-commit to check Bash scripts being committed.


######### Git clients:


fancy_echo "GIT_CLIENT=$GIT_CLIENT in secrets.sh ..."
echo "The last one installed is set as the Git client."
# See https://www.slant.co/topics/465/~best-git-clients-for-macos
          # git, cola, github, gitkraken, smartgit, sourcetree, tower, magit, gitup. 
          # See https://git-scm.com/download/gui/linux
          # https://www.slant.co/topics/465/~best-git-clients-for-macos

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
      fi
   fi
   git-cola --version
      # cola version 3.0
   if [[ $TRYOUT == *"cola"* ]]; then
      fancy_echo "Starting git-cola in background ..."
      git-cola &
   fi
fi


# GitHub Desktop is written by GitHub, Inc.,
# open sourced at https://github.com/desktop/desktop
# so people can just click a button on GitHub to download a repo from an internet browser.
if [[ "$GIT_CLIENT" == *"github"* ]]; then
    # https://desktop.github.com/
    if [ ! -d "/Applications/GitHub Desktop.app" ]; then 
        fancy_echo "Installing GIT_CLIENT=\"github\" using Homebrew ..."
        brew cask uninstall github
        brew cask install --appdir="/Applications" github
    else
        if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
           fancy_echo "Upgrading GIT_CLIENT=\"github\" using Homebrew ..."
           brew cask upgrade github
        else
           fancy_echo "GIT_CLIENT=\"github\" already installed" >>$LOGFILE
        fi
    fi
   if [[ $TRYOUT == *"github"* ]]; then
      fancy_echo "Opening GitHub Desktop GUI ..." 
      open "/Applications/GitHub Desktop.app"
   fi
fi


if [[ "$GIT_CLIENT" == *"gitkraken"* ]]; then
   # GitKraken from https://www.gitkraken.com/ and https://blog.axosoft.com/gitflow/
   if [ ! -d "/Applications/GitKraken.app" ]; then 
       fancy_echo "Installing GIT_CLIENT=\"gitkraken\" using Homebrew ..."
       brew cask uninstall gitkraken
       brew cask install --appdir="/Applications" gitkraken
   else
       if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          fancy_echo "Upgrading GIT_CLIENT=\"gitkraken\" using Homebrew ..."
          brew cask upgrade gitkraken
       else
          fancy_echo "GIT_CLIENT=\"gitkraken\" already installed" >>$LOGFILE
       fi
   fi

   if grep -q "/Applications/GitKraken.app" "$BASHFILE" ; then    
       fancy_echo "PATH to gitkraken already in $BASHFILE" >>$LOGFILE
   else
       fancy_echo "Adding PATH to gitkraken in $BASHFILE..."
       echo "" >>"$BASHFILE"
       echo "export gitkraken='/Applications/GitKraken.app'" >>"$BASHFILE"
       source "$BASHFILE"
   fi 
   gitkraken -v
   if [[ $TRYOUT == *"gitkraken"* ]]; then
      fancy_echo "Opening GitKraken ..."
      open "/Applications/GitKraken.app"
   fi
fi


if [[ "$GIT_CLIENT" == *"sourcetree"* ]]; then
    # See https://www.sourcetreeapp.com/
    if [ ! -d "/Applications/Sourcetree.app" ]; then 
        fancy_echo "Installing GIT_CLIENT=\"sourcetree\" using Homebrew ..."
        brew cask uninstall sourcetree
        brew cask install --appdir="/Applications" sourcetree
    else
        if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
           fancy_echo "Upgrading GIT_CLIENT=\"sourcetree\" using Homebrew ..."
           brew cask upgrade sourcetree
           # WARNING: This requires your MacOS password.
        else
           fancy_echo "GIT_CLIENT=\"sourcetree\" already installed:" >>$LOGFILE
        fi
    fi
   if [[ $TRYOUT == *"sourcetree"* ]]; then
      fancy_echo "Opening Sourcetree ..."
      open "/Applications/Sourcetree.app"
   fi
fi


if [[ "$GIT_CLIENT" == *"smartgit"* ]]; then
    # SmartGit from https://syntevo.com/smartgit
    if [ ! -d "/Applications/SmartGit.app" ]; then 
        fancy_echo "Installing GIT_CLIENT=\"smartgit\" using Homebrew ..."
        brew cask uninstall smartgit
        brew cask install --appdir="/Applications" smartgit
    else
        if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
           fancy_echo "Upgrading GIT_CLIENT=\"smartgit\" using Homebrew ..."
           brew cask upgrade smartgit
        else
           fancy_echo "GIT_CLIENT=\"smartgit\" already installed:"
        fi
    fi
   if [[ $TRYOUT == *"smartgit"* ]]; then
      fancy_echo "Opening SmartGit ..."
      open "/Applications/SmartGit.app"
   fi
fi


if [[ "$GIT_CLIENT" == *"tower"* ]]; then
    # Tower from https://www.git-tower.com/learn/git/ebook/en/desktop-gui/advanced-topics/git-flow
    if [ ! -d "/Applications/Tower.app" ]; then 
        fancy_echo "Installing GIT_CLIENT=\"tower\" using Homebrew ..."
        brew cask uninstall tower
        brew cask install --appdir="/Applications" tower
    else
        if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
           fancy_echo "Upgrading GIT_CLIENT=\"tower\" using Homebrew ..."
           # current version?
           brew cask upgrade tower
        else
           fancy_echo "GIT_CLIENT=\"tower\" already installed" >>$LOGFILE
        fi
    fi
    # version?
   if [[ $TRYOUT == *"tower"* ]]; then
      fancy_echo "Opening Tower ..."
      open "/Applications/Tower.app"
   fi
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
           fancy_echo "GIT_CLIENT=\"magit\" already installed:" >>$LOGFILE
        fi
    fi
   # TODO: magit -v
   if [[ $TRYOUT == *"magit"* ]]; then
      fancy_echo "Cannot Start magit in background ..." >>$LOGFILE
      #magit & 
   fi
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
         fancy_echo "GIT_CLIENT=\"gitup\" already installed:" >>$LOGFILE
      fi
   fi
   # gitup -v does not work
   if [[ $TRYOUT == *"gitup"* ]]; then
      fancy_echo "Starting GitUp in background ..." >>$LOGFILE
      gitup &
   fi
fi


######### Git tig repo viewer:


if [[ "$GIT_TOOLS" == *"tig"* ]]; then
   if ! command -v tig >/dev/null; then  # in /usr/local/bin/tig
      fancy_echo "Installing tig for formatting git logs ..."
      brew install tig
      # See https://jonas.github.io/tig/
      # A sample of the default configuration has been installed to:
      #   /usr/local/opt/tig/share/tig/examples/tigrc
      # to override the system-wide default configuration, copy the sample to:
      #   /usr/local/etc/tigrc
      # Bash completion has been installed to:
      #   /usr/local/etc/bash_completion.d
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         tig version | grep tig  
          # git version 2.16.3
          # tig version 2.2.9
         fancy_echo "tig upgrading ..."
         brew upgrade tig 
      fi
  fi
  echo -e "\n   tig --version:" >>$LOGFILE
  echo -e "$(tig --version)" >>$LOGFILE
   # tig version 2.3.3
fi


######### BFG to identify and remove passwords and large or troublesome blobs.


# See https://rtyley.github.io/bfg-repo-cleaner/ 

# Install sub-folder under git-utilities:
# git clone https://github.com/rtyley/bfg-repo-cleaner --depth=0

#git clone --mirror $WORK_REPO  # = git://example.com/some-big-repo.git

#JAVA_INSTALL

#java -jar bfg.jar --replace-text banned.txt \
#    --strip-blobs-bigger-than 100M \
#    $SECRETSFILE


######### Git Large File Storage:


# Git Large File Storage (LFS) replaces large files such as audio samples, videos, datasets, and graphics with text pointers inside Git, while storing the file contents on a remote server like GitHub.com or GitHub Enterprise. During install .gitattributes are defined.
# See https://git-lfs.github.com/
# See https://help.github.com/articles/collaboration-with-git-large-file-storage/
# https://www.atlassian.com/git/tutorials/git-lfs
# https://www.youtube.com/watch?v=p3Pse1UkEhI

if [[ "$GIT_TOOLS" == *"lfs"* ]]; then
   if ! command -v git-lfs >/dev/null; then  # in /usr/local/bin/git-lfs
      fancy_echo "Installing git-lfs for managing large files in git ..."
      brew install git-lfs
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "git-lfs upgrading ..."
         git-lfs version # git-lfs/2.4.0 (GitHub; darwin amd64; go 1.10)
         brew upgrade git-lfs 
      fi
   fi
   echo -e "\n   git-lfs version:" >>$LOGFILE
   echo -e "$(git-lfs version)" >>$LOGFILE
   # git-lfs/2.4.0 (GitHub; darwin amd64; go 1.10)

   # Update global git config (creates hooks pre-push, post-checkout, post-commit, post-merge)
   #  git lfs install

   # Update system git config:
   #  git lfs install --system

   # See https://help.github.com/articles/configuring-git-large-file-storage/
   # Set LFS to kick into action based on file name extensions such as *.psd by
   # running command:  (See https://git-scm.com/docs/gitattributes)
   # git lfs track "*.psd"
   #    The command appends to the repository's .gitattributes file:
   # *.psd filter=lfs diff=lfs merge=lfs -text

   #  git lfs track "*.mp4"
   #  git lfs track "*.mp3"
   #  git lfs track "*.jpeg"
   #  git lfs track "*.jpg"
   #  git lfs track "*.png"
   #  git lfs track "*.ogg"
   # CAUTION: Quotes are important in the entries above.
   # CAUTION: Git clients need to be LFS-aware.

   # Based on https://github.com/git-lfs/git-lfs/issues/1720
   git config lfs.transfer.maxretries 10

   # Define alias to stop lfs
   #git config --global alias.plfs "\!git -c filter.lfs.smudge= -c filter.lfs.required=false pull && git lfs pull"
   #$ git plfs
fi

######### TODO: .gitattributes


# See https://github.com/alexkaratarakis/gitattributes for templates
# Make sure .gitattributes is tracked
# git add .gitattributes
# TODO: https://github.com/alexkaratarakis/gitattributes/blob/master/Common.gitattributes


######### Text editors:


# Specified in secrets.sh
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
   if [ ! -d "/Applications/Sublime Text.app" ]; then 
      fancy_echo "Installing Sublime Text text editor using Homebrew ..."
      brew cask uninstall sublime-text
      brew cask install --appdir="/Applications" sublime-text
 
      if grep -q "/usr/local/bin/subl" "$BASHFILE" ; then    
         fancy_echo "PATH to Sublime already in $BASHFILE" >>$LOGFILE
      else
         fancy_echo "Adding PATH to SublimeText in $BASHFILE..."
         echo "" >>"$BASHFILE"
         echo "export PATH=\"\$PATH:/usr/local/bin/subl\"" >>"$BASHFILE"
         source "$BASHFILE"
      fi 
 
      if grep -q "alias subl=" "$BASHFILE" ; then
         fancy_echo "PATH to Sublime already in $BASHFILE" >>$LOGFILE
      else
         echo "" >>"$BASHFILE"
         echo "alias subl='open -a \"/Applications/Sublime Text.app\"'" >>"$BASHFILE"
         source "$BASHFILE"
      fi 
      # Only install the following during initial install:
      # TODO: Configure Sublime for spell checker, etc. https://github.com/SublimeLinter/SublimeLinter-shellcheck
      # install Package Control see https://gist.github.com/patriciogonzalezvivo/77da993b14a48753efda
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "Sublime Text upgrading ..."
         subl --version  # Sublime Text Build 3143
            # To avoid response "Error: git not installed" to brew upgrade git
         brew cask reinstall sublime-text
      fi
   fi
   git config --global core.editor code
   echo -e "\n$(subl --version)" >>$LOGFILE
   #subl --version
      # Sublime Text Build 3143

   #fancy_echo "Opening Sublime Text app in background ..."
   #subl &
fi


if [[ "$GIT_CLIENT" == *"textedit"* ]]; then 
   # TextEdit comes with MacOS:
      if grep -q "alias textedit=" "$BASHFILE" ; then    
         fancy_echo "PATH to TextEdit.app already in $BASHFILE" >>$LOGFILE
      else
         fancy_echo "Adding PATH to TextEdit.app in $BASHFILE..."
         echo "alias textedit='open -a \"/Applications/TextEdit.app\"'" >>"$BASHFILE"
      fi 
   git config --global core.editor textedit
fi


if [[ "$GIT_EDITOR" == *"code"* ]]; then
    if ! command -v code >/dev/null; then
        fancy_echo "Installing Visual Studio Code text editor using Homebrew ..."
        brew install visual-studio-code
    else
       if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          fancy_echo "VS Code upgrading ..."
          code --version
          # No upgrade - "Error: No available formula with the name "visual-studio-code" 
          brew uninstall visual-studio-code
          brew install visual-studio-code
       else
          fancy_echo "VS Code already installed:" >>$LOGFILE
       fi
    fi
    git config --global core.editor code
    echo "Visual Studio Code: $(code --version)" >>$LOGFILE
    # code --version
      # 1.21.1
      # 79b44aa704ce542d8ca4a3cc44cfca566e7720f1
      # x64

   # https://github.com/timonwong/vscode-shellcheck
   fancy_echo "Installing Visual Studio Code Shellcheck extension"
   code --install-extension timonwong.shellcheck
   #fancy_echo "Opening Visual Studio Code ..."
   #open "/Applications/Visual Studio Code.app"
   #fancy_echo "Starting code in background ..."
   #code &
fi


if [[ "$GIT_EDITOR" == *"atom"* ]]; then
   if ! command -v atom >/dev/null; then
      fancy_echo "Installing GIT_EDITOR=\"atom\" text editor using Homebrew ..."
      brew cask install --appdir="/Applications" atom
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          fancy_echo "GIT_EDITOR=\"atom\" upgrading ..."
          atom --version  # from
          # To avoid response "Error: No available formula with the name "atom"
          brew uninstall atom
          brew install atom
       else
          fancy_echo "GIT_EDITOR=\"atom\" already installed:" >>$LOGFILE
       fi
    fi
    git config --global core.editor atom

    # TODO: Add plug-in https://github.com/AtomLinter/linter-shellcheck

   # Configure plug-ins:
   #apm install linter-shellcheck

   echo -e "\n$(atom --version)"            >>$LOGFILE
   #atom --version
      # Atom    : 1.20.1
      # Electron: 1.6.9
      # Chrome  : 56.0.2924.87
      # Node    : 7.4.0
      # Wilsons-MacBook-Pro

   #fancy_echo "Starting atom in background ..."
   #atom &
fi


if [[ "$GIT_EDITOR" == *"macvim"* ]]; then
    if [ ! -d "/Applications/MacVim.app" ]; then
        fancy_echo "Installing GIT_EDITOR=\"macvim\" text editor using Homebrew ..."
        brew cask uninstall macvim
        brew cask install --appdir="/Applications" macvim
    else
       if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          fancy_echo "GIT_EDITOR=\"macvim\" upgrading ..."
          # To avoid response "==> No Casks to upgrade" on uprade:
          brew cask uninstall macvim
          brew cask install --appdir="/Applications" macvim
          # TODO: Configure macvim text editor using bash shell commands.
       else
          fancy_echo "GIT_EDITOR=\"macvim\" already installed:" >>$LOGFILE
       fi
    fi
 
    if grep -q "alias macvim=" "$BASHFILE" ; then
       fancy_echo "PATH to MacVim already in $BASHFILE" >>$LOGFILE
    else
       echo "alias macvim='open -a \"/Applications/MacVim.app\"'" >>"$BASHFILE"
       source "$BASHFILE"
    fi 

   # git config --global core.editor macvim
   # TODO: macvim --version
   #fancy_echo "Starting macvim in background ..."
   #macvim &
fi


if [[ "$GIT_EDITOR" == *"textmate"* ]]; then
    if [ ! -d "/Applications/textmate.app" ]; then 
        fancy_echo "Installing GIT_EDITOR=\"textmate\" text editor using Homebrew ..."
        brew cask uninstall textmate
        brew cask install --appdir="/Applications" textmate
    else
       if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          fancy_echo "GIT_EDITOR=\"textmate\" upgrading ..."
          mate -v
          brew cask uninstall textmate
          brew cask install --appdir="/Applications" textmate
          # TODO: Configure textmate text editor using bash shell commands.
       fi
       mate -v
   fi
        # Per https://stackoverflow.com/questions/4011707/how-to-start-textmate-in-command-line
        # Create a symboling link to bin folder
        ln -s /Applications/TextMate.app/Contents/Resources/mate "$HOME/bin/mate"

        if grep -q "export EDITOR=" "$BASHFILE" ; then    
           fancy_echo "export EDITOR= already in $BASHFILE." >>$LOGFILE
        else
           fancy_echo "Concatenating \"export EDITOR=\" in $BASHFILE..."
           echo "export EDITOR=\"/usr/local/bin/mate -w\" " >>"$BASHFILE"
        fi

   echo -e "\n$(mate -v)" >>$LOGFILE
   #mate -v
      #mate 2.12 (2018-03-08) 
   git config --global core.editor textmate

   #fancy_echo "Starting mate (textmate) in background ..."
   #mate &
fi

if [[ "$GIT_EDITOR" == *"textwrangler"* ]]; then
   fancy_echo "NOTE: textwrangler not found in brew search ..."
   fancy_echo "Install textwrangler text editor from MacOS App Store ..."
fi



if [[ "$GIT_EDITOR" == *"emacs"* ]]; then
    if ! command -v emacs >/dev/null; then
        fancy_echo "Installing emacs text editor using Homebrew ..."
        brew cask install --appdir="/Applications" emacs
    else
       if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          fancy_echo "emacs upgrading ..."
          emacs --version
             # /usr/local/bin/emacs:41: warning: Insecure world writable dir /Users/wilsonmar/gits/wilsonmar in PATH, mode 040777
             # GNU Emacs 25.3.1
          brew cask upgrade emacs
          # TODO: Configure emacs using bash shell commands.
       fi
    fi
    git config --global core.editor emacs
    echo -e "\n$(emacs --version)" >>$LOGFILE
    #emacs --version

    # Evaluate https://github.com/git/git/tree/master/contrib/emacs

   #fancy_echo "Opening emacs in background ..."
   #emacs &
fi


if [[ "$GIT_EDITOR" == *"intellij"* ]]; then
    # See http://macappstore.org/intellij-idea-ce/
   if [ ! -d "/Applications/IntelliJ IDEA CE.app" ]; then 
       fancy_echo "Installing GIT_EDITOR=\"intellij\" text editor using Homebrew ..."
       brew cask uninstall intellij-idea-ce
       brew cask install --appdir="/Applications" intellij-idea-ce 
       # alias idea='open -a "`ls -dt /Applications/IntelliJ\ IDEA*|head -1`"'
        # TODO: Configure intellij text editor using bash shell commands.
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "GIT_EDITOR=\"intellij\" upgrading ..."
         # TODO: idea  --version
         brew cask upgrade intellij-idea-ce 
      else
         fancy_echo "GIT_EDITOR=\"intellij\" already installed:" >>$LOGFILE
      fi
    fi

    # See https://emmanuelbernard.com/blog/2017/02/27/start-intellij-idea-command-line/   
        if grep -q "alias idea=" "$BASHFILE" ; then    
           fancy_echo "alias idea= already in $BASHFILE." >>$LOGFILE
        else
           fancy_echo "Concatenating \"alias idea=\" in $BASHFILE..."
           echo "alias idea='open -a \"$(ls -dt /Applications/IntelliJ\ IDEA*|head -1)\"'" >>"$BASHFILE"
           source "$BASHFILE"
        fi 
    git config --global core.editor idea
    # TODO: idea --version

   #fancy_echo "Opening IntelliJ IDEA CE ..."
   #open "/Applications/IntelliJ IDEA CE.app"
   #fancy_echo "Opening (Intellij) idea in background ..."
   #idea &
fi
# See https://www.jetbrains.com/help/idea/using-git-integration.html

# https://gerrit-review.googlesource.com/Documentation/dev-intellij.html


if [[ "$GIT_EDITOR" == *"sts"* ]]; then
    # See http://macappstore.org/sts/
    if [ ! -d "/Applications/STS.app" ]; then 
        fancy_echo "Installing GIT_EDITOR=\"sts\" text editor using Homebrew ..."
        brew cask uninstall sts
        brew cask install --appdir="/Applications" sts
    else
       if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          fancy_echo "GIT_EDITOR=\"sts\" upgrading ..."
          # TODO: sts --version
          brew cask uninstall sts
          brew cask install --appdir="/Applications" sts
          # TODO: Configure sts text editor using bash shell commands.
       else
          fancy_echo "GIT_EDITOR=\"sts\" already installed:" >>$LOGFILE
       fi
    fi
    # Based on https://emmanuelbernard.com/blog/2017/02/27/start-intellij-idea-command-line/   
        if grep -q "alias sts=" "$BASHFILE" ; then    
           fancy_echo "alias sts= already in $BASHFILE." >>$LOGFILE
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
   #fancy_echo "Opening sts in background ..."
   #sts &
fi


if [[ "$GIT_EDITOR" == *"eclipse"* ]]; then
    # See http://macappstore.org/eclipse-ide/
    if [ ! -d "/Applications/Eclipse.app" ]; then 
        fancy_echo "Installing GIT_EDITOR=\"eclipse\" text editor using Homebrew ..."
        brew cask uninstall eclipse-ide
        brew cask install --appdir="/Applications" eclipse-ide
    else
       if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          fancy_echo "GIT_EDITOR=\"eclipse\" upgrading ..."
          # TODO: eclipse-ide --version
          brew cask uninstall eclipse-ide
          brew cask install --appdir="/Applications" eclipse-ide
          # TODO: Configure eclipse text editor using bash shell commands.
       else
          fancy_echo "GIT_EDITOR=\"eclipse\" already installed:"
       fi
    fi

   if grep -q "alias eclipse=" "$BASHFILE" ; then    
       fancy_echo "alias eclipse= already in $BASHFILE." >>$LOGFILE
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

   #fancy_echo "Opening eclipse in background ..."
   #eclipse &
   # See https://www.cs.colostate.edu/helpdocs/eclipseCommLineArgs.html

   # TODO: http://www.baeldung.com/jacoco for code coverage calculations within Eclipse
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



######### ~/.gitignore settings:


#[core]
#	# Use custom `.gitignore`
#	excludesfile = ~/.gitignore
#   hitespace = space-before-tab,indent-with-non-tab,trailing-space

GITIGNORE_PATH="$HOME/.gitignore_global"
if [ ! -f $GITIGNORE_PATH ]; then 
   fancy_echo "Copy to $GITIGNORE_PATH."
   cp ".gitignore_global" $GITIGNORE_PATH

   git config --global core.excludesfile "$GITIGNORE_PATH"
   # Treat spaces before tabs, lines that are indented with 8 or more spaces, and all kinds of trailing whitespace as an error
   git config --global core.hitespace "space-before-tab,indent-with-non-tab,trailing-space"
fi



######### Git coloring in .gitconfig:


# If git config color.ui returns true, skip:
git config color.ui | grep 'true' &> /dev/null
if [ $? == 0 ]; then
   fancy_echo "git config --global color.ui already true (on)." >>$LOGFILE
else # false or blank response:
   fancy_echo "Setting git config --global color.ui true (on)..."
   git config --global color.ui true
fi

#[color]
#	ui = true

if grep -q "color.status=auto" "$GITCONFIG" ; then    
   fancy_echo "color.status=auto already in $GITCONFIG" >>$LOGFILE
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
   git config --global color.diff.whitespace  "red     normal reverse"
fi


######### diff-so-fancy color:


if [[ "$GIT_TOOLS" == *"diff-so-fancy"* ]]; then
   if ! command -v diff-so-fancy >/dev/null; then
      fancy_echo "Installing GIT_TOOLS=\"diff-so-fancy\" using Homebrew ..."
      brew install diff-so-fancy
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "GIT_EDITOR=\"diff-so-fancy\" upgrading ..."
         brew cask upgrade diff-so-fancy
      else
         fancy_echo "GIT_EDITOR=\"diff-so-fancy\" already installed:" >>$LOGFILE
      fi
   fi
   # Configuring based on https://github.com/so-fancy/diff-so-fancy
   git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"

   # Default Git colors are not optimal. We suggest the following colors instead.
   git config --global color.diff-highlight.oldNormal    "red bold"
   git config --global color.diff-highlight.oldHighlight "red bold 52"
   git config --global color.diff-highlight.newNormal    "green bold"
   git config --global color.diff-highlight.newHighlight "green bold 22"

   git config --global color.diff.meta       "yellow"
   git config --global color.diff.frag       "magenta bold"
   git config --global color.diff.commit     "yellow bold"
   git config --global color.diff.old        "red bold"
   git config --global color.diff.new        "green bold"
   git config --global color.diff.whitespace "red reverse"

   # Should the first block of an empty line be colored. (Default: true)
   git config --bool --global diff-so-fancy.markEmptyLines false

   # Simplify git header chunks to a more human readable format. (Default: true)
   git config --bool --global diff-so-fancy.changeHunkIndicators false

   # stripLeadingSymbols - Should the pesky + or - at line-start be removed. (Default: true)
   git config --bool --global diff-so-fancy.stripLeadingSymbols false

   # useUnicodeRuler By default the separator for the file header uses Unicode line drawing characters. If this is causing output errors on your terminal set this to false to use ASCII characters instead. (Default: true)
   git config --bool --global diff-so-fancy.useUnicodeRuler false

   # To bypass diff-so-fancy. Use --no-pager for that:
   #git --no-pager diff
fi



######### Reuse Recorded Resolution of conflicted merges


# See https://git-scm.com/docs/git-rerere
# and https://git-scm.com/book/en/v2/Git-Tools-Rerere

#[rerere]
#  enabled = 1
#  autoupdate = 1
   git config --global rerere.enabled  "1"
   git config --global rerere.autoupdate  "1"



######### ~/.bash_profile prompt settings:


# https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
# See http://maximomussini.com/posts/bash-git-prompt/

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
       fancy_echo "Brew upgrading ..."
       # ?  --version
       brew upgrade bash-git-prompt
    else
       fancy_echo "brew bash-git-prompt already installed:" >>$LOGFILE
    fi
fi
# ? --version


######### bash colors:


   if grep -q "export CLICOLOR" "$BASHFILE" ; then    
      fancy_echo "export CLICOLOR already in $BASHFILE" >>$LOGFILE
   else
      fancy_echo "Adding export CLICOLOR in $BASHFILE..."
      echo "export CLICOLOR=1" >>"$BASHFILE"
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


# If git-completion.bash file is not already in  ~/.bash_profile, add it:
if grep -q "$FILEPATH" "$BASHFILE" ; then    
   fancy_echo "$FILEPATH already in $BASHFILE" >>$LOGFILE
else
   fancy_echo "Adding code for $FILEPATH in $BASHFILE..."
   echo "# Added by $0 ::" >>"$BASHFILE"
   echo "if [ -f $FILEPATH ]; then" >>"$BASHFILE"
   echo "   . $FILEPATH" >>"$BASHFILE"
   echo "fi" >>"$BASHFILE"
   cat $FILEPATH >>"$BASHFILE"
fi 

# Run .bash_profile to have changes above take:
   source "$BASHFILE"


######### Difference engine p4merge:


if [[ "$GIT_TOOLS" == *"p4merge"* ]]; then
   # See https://www.perforce.com/products/helix-core-apps/merge-diff-tool-p4merge
   if [ ! -d "/Applications/p4merge.app" ]; then 
      fancy_echo "Installing p4merge diff engine app using Homebrew ..."
      brew cask uninstall p4merge
      brew cask install --appdir="/Applications" p4merge
      # TODO: Configure p4merge using shell commands.
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "p4merge diff engine app upgrading ..."
         # p4merge --version
         # To avoid response "Error: git not installed" to brew upgrade git
         brew cask reinstall p4merge
      else
         fancy_echo "p4merge diff engine app already installed:" >>$LOGFILE
      fi
   fi
   # TODO: p4merge --version err in pop-up

   if grep -q "alias p4merge=" "$BASHFILE" ; then    
      fancy_echo "p4merge alias already in $BASHFILE" >>$LOGFILE
   else
      fancy_echo "Adding p4merge alias in $BASHFILE..."
      echo "alias p4merge='/Applications/p4merge.app/Contents/MacOS/p4merge'" >>"$BASHFILE"
   fi 
fi

# TODO: Different diff/merge engines


######### Git Repository:

   git config --global github.user   "$GITHUB_ACCOUNT"
   git config --global github.token  token

# https://github.com/
# https://gitlab.com/
# https://bitbucket.org/
# https://travis-ci.org/


######### TODO: Git Flow helper:


if [[ "$GIT_TOOLS" == *"git-flow"* ]]; then
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
      fancy_echo "git-flow already installed." >>$LOGFILE
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
fi


######### git local hooks 


if [[ "$GIT_TOOLS" == *"hooks"* ]]; then
   # # TODO: Install link per https://wilsonmar.github.io/git-hooks/
   if [ ! -f ".git/hooks/git-commit" ]; then 
      fancy_echo "git-commit file not found in .git/hooks. Copying hooks folder ..."
      rm .git/hooks/*.sample  # samples are not run
      cp hooks/* .git/hooks   # copy
      chmod +x .git/hooks/*   # make executable
   else
      fancy_echo "git-commit file found in .git/hooks. Skipping ..."
   fi

   if [[ $TRYOUT == *"hooks"* ]]; then
      if [[ $GIT_LANG == *"python"* ]]; then  # contains azure.
         PYTHON_PGM="hooks/basic-python2"
         if [[ $TRYOUT == *"cleanup"* ]]; then
            fancy_echo "$PYTHON_PGM TRYOUT == cleanup ..."
            python "hooks/$PYTHON_PGM"  # run
            rm -rf $PYTHON_PGM
         fi
      fi

      if [[ $GIT_LANG == *"python3"* ]]; then  # contains azure.
         PYTHON_PGM="hooks/basic-python3"
         if [[ $TRYOUT == *"cleanup"* ]]; then
            fancy_echo "$PYTHON_PGM TRYOUT == cleanup ..."
            python3 "hooks/$PYTHON_PGM"  # run
            rm -rf $PYTHON_PGM
         fi
      fi
   fi
else
   if [[ $TRYOUT == *"hooks"* ]]; then
      fancy_echo "ERROR: \"hooks\" needs to be in GIT_TOOLS for TRYOUT."
   fi
fi
# Thanks to ShingLyu.github.io for support on Python Selenium scripting.

######### Node language:


if [[ $GIT_LANG == *"node"* ]]; then
   NODE_INSTALL  # pre-requisite function.
   
     nvm --version
   # Run with latest Long Term Stable version:
      # nvm is not compatible with the npm config "prefix" option: currently set to "/usr/local/Cellar/nvm/0.33.8/versions/node/v9.10.1"
   # a) Run with older Long Term Stable version:
#      nvm run 8.11.1 --version
      nvm use --lts  # (npm v5.6.0) 
      RESPONSE=$(nvm use --delete-prefix v8.11.1)
   # b) Run with current newest version:
      #RESPONSE=$(nvm use --delete-prefix v9.10.1)

      fancy_echo "RESPONSE=$RESPONSE"
 #     node --version   # v8.11.1 or v9.10.1 
      npm --version

   # NOTE: NODE_TOOLS = npm (node package manager) installed within node.
   # https://colorlib.com/wp/npm-packages-node-js/
   # Task runners:
   if [[ "${NODE_TOOLS,,}" == *"bower"* ]]; then
      NPM_LIST=$(npm list -g bower | grep bower)
      if ! grep -q "bowser" "$NPM_LIST" ; then
         npm install -g bower  # like npm for GUI apps
      fi
   fi
   if [[ "${NODE_TOOLS,,}" == *"gulp-cli"* ]]; then
      npm install -g gulp-cli
   fi
   if [[ "${NODE_TOOLS,,}" == *"gulp"* ]]; then
      npm install -g gulp
   fi
   if [[ "${NODE_TOOLS,,}" == *"npm-check"* ]]; then
      npm install -g npm-check
   fi
   # Linters: less, UglifyJS2, eslint, jslint, cfn-lint
   if [[ "${NODE_TOOLS,,}" == *"less"* ]]; then
      npm install -g less
   fi
   if [[ "${NODE_TOOLS,,}" == *"jshint"* ]]; then
      npm install -g jshint  # linter
   fi
   if [[ "${NODE_TOOLS,,}" == *"eslint"* ]]; then
      npm install -g eslint  # linter for ES6 javascript, includes jscs
   fi

   if [[ "${NODE_TOOLS,,}" == *"webpack"* ]]; then
      npm install -g webpack  # consolidate several javascript files into one file.
   fi
   if [[ "${NODE_TOOLS,,}" == *"mocha"* ]]; then
      npm install -g mocha # testing framework
   fi
   if [[ "${NODE_TOOLS,,}" == *"chai"* ]]; then
      npm install -g chai # assertion library  "should", "expect", "assert" for BDD and TDD styles of programming 
   fi
   if [[ "${NODE_TOOLS,,}" == *"karma"* ]]; then
      npm install -g karma
   fi
   if [[ "${NODE_TOOLS,,}" == *"karma-cli"* ]]; then
      npm install -g karma-cli
   fi
   if [[ "${NODE_TOOLS,,}" == *"jest"* ]]; then
      npm install -g jest
   fi
   if [[ "${NODE_TOOLS,,}" == *"protractor"* ]]; then
      npm install -g protractor
   fi
   # testing: enzyme, jest, 
   # nodemon, node-inspector
   if [[ "${NODE_TOOLS,,}" == *"node-inspector"* ]]; then
      npm install -g node-inspector
   fi

   if [[ "${NODE_TOOLS,,}" == *"browserify"* ]]; then
      npm install -g browserify
   fi
   if [[ "${NODE_TOOLS,,}" == *"tsc"* ]]; then
      npm install -g tsc
   fi
   # web: express, hapi, 
   if [[ "${NODE_TOOLS,,}" == *"express"* ]]; then
      npm install -g express
   fi
   if [[ "${NODE_TOOLS,,}" == *"hapi"* ]]; then
      npm install -g hapi
   fi
   # front-end: angular, react, redux, Ember.js, Marionette.js
   if [[ "${NODE_TOOLS,,}" == *"angular"* ]]; then
      npm install -g angular
   fi
   if [[ "${NODE_TOOLS,,}" == *"react"* ]]; then
      npm install -g react  # Test using Jest https://medium.com/@mathieux51/jest-selenium-webdriver-e25604969c6
   fi
   if [[ "${NODE_TOOLS,,}" == *"redux"* ]]; then
      npm install -g redux
   fi
   
   # moment.js, graphicmagick, yeoman-generator
   if [[ "${NODE_TOOLS,,}" == *"graphicmagick"* ]]; then
      npm install -g graphicmagick
   fi

   # cloud: aws-sdk
   if [[ "${NODE_TOOLS,,}" == *"aws-sdk"* ]]; then
      npm install -g aws-sdk
   fi
   if [[ "${NODE_TOOLS,,}" == *"cfn-lint"* ]]; then
      npm install -g cfn-lint  # CloudFormation JSON and YAML Validator
   fi

   # database: mongodb, redis 
   if [[ "${NODE_TOOLS,,}" == *"mongodb"* ]]; then
      npm install -g mongodb
   fi
   if [[ "${NODE_TOOLS,,}" == *"postgresql"* ]]; then
      npm install -g postgresql
   fi
   if [[ "${NODE_TOOLS,,}" == *"redis"* ]]; then
      npm install -g redis
   fi
   # montebank security app

if [[ "$NODE_TOOLS" == *"others"* ]]; then
    echo "Installing NODE_TOOLS=others ..."; 
#   npm install -g express
#   npm install -g growl
#   npm install -g kudoexec
#   npm install -g node-inspector
#   npm install -g phantomjs
#   npm install -g superstatic
#   npm install -g tsd
#   npm install -g typescript
fi

   echo -e "\n  npm list -g --depth=1 --long" >>$LOGFILE
   echo -e "$(npm list -g --depth=1)" >>$LOGFILE
      # v8.11.1
      # v9.10.1
      # node -> stable (-> v9.10.1) (default)
      # stable -> 9.10 (-> v9.10.1) (default)
      # iojs -> N/A (default)
      # lts/* -> lts/carbon (-> v8.11.1)
      # lts/argon -> v4.9.1 (-> N/A)
      # lts/boron -> v6.14.1 (-> N/A)
      # lts/carbon -> v8.11.1

   # npm start
   # See https://github.com/creationix/howtonode.org by Tim Caswell
   # Look in folder node-test1
fi


######### JAVA_TOOLS:


if [[ "$JAVA_TOOLS" == *"maven"* ]]; then
    # Associated: Maven (mvn) in /usr/local/opt/maven/bin/mvn
   if ! command -v mvn >/dev/null; then
      fancy_echo "Installing Maven for Java ..."
      brew install maven
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "JAVA_TOOLS maven dupgrading ..."
         # mvn --version
         brew upgrade maven
      fi
   fi
   echo -e "$(mvn --version)" >>$LOGFILE  # Apache Maven 3.5.0 
fi


if [[ "$JAVA_TOOLS" == *"gradle"* ]]; then
    # no xml angle brackets! Uses Groovy DSL
    # See http://www.gradle.org/docs/1.6/userguide/userguide.html
   if ! command -v gradle >/dev/null; then
      fancy_echo "Installing JAVA_TOOLS gradle for Java ..."
      brew install gradle
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         # gradle -v
         fancy_echo "JAVA_TOOLS gradle upgrading ..."
         brew upgrade gradle
      fi
   fi
   echo -e "$(gradle -v)" >>$LOGFILE  # Gradle 4.6 between lines
   # http://www.gradle.org/docs/1.6/userguide/plugins.html
   # http://www.gradle.org/docs/1.6/userguide/gradle_command_line.html
   # gradle setupBuild  # reads build.gradle
   # gradle tasks
   # gradle test
fi


if [[ "$JAVA_TOOLS" == *"ant"* ]]; then
    # 
   if ! command -v ant >/dev/null; then
      fancy_echo "Installing JAVA_TOOLS ant for Java ..."
      brew install ant
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "JAVA_TOOLS ant upgrading ..."
         # ant -v
         brew upgrade ant
      else
         fancy_echo "JAVA_TOOLS ant already installed:" >>$LOGFILE
      fi
   fi
   # echo -e "$(ant -v)" >>$LOGFILE
   # Ant can pick up the Test.jmx file, execute it, and generate an easily-readable HTML report.
fi

if [[ "$JAVA_TOOLS" == *"yarn"* ]]; then
   # for code generation
   fancy_echo "There is no brew install yarn because it is installed by adding it within Maven or Gradle." 
   # 
fi

if [[ "$JAVA_TOOLS" == *"junit4"* ]]; then
   # junit5 reached 2nd GA February 18, 2018 https://junit.org/junit5/docs/current/user-guide/
   # http://junit.org/junit4/
   # https://github.com/junit-team/junit4/wiki/Download-and-Install
   # https://www.tutorialspoint.com/junit/junit_environment_setup.htm
   fancy_echo "There is no brew install junit because it is installed by adding it within Maven or Gradle." 
   # TODO: Insert java-junit4-maven.xml as a dependency to maven pom.xml
   # 
fi

if [[ "$JAVA_TOOLS" == *"junit5"* ]]; then
   # junit5 reached 2nd GA February 18, 2018 https://junit.org/junit5/docs/current/user-guide/
   # http://junit.org/junit4/
   # https://github.com/junit-team/junit4/wiki/Download-and-Install
   # https://www.tutorialspoint.com/junit/junit_environment_setup.htm
   fancy_echo "There is no brew install junit because it is installed by adding it within Maven or Gradle." 
   # TODO: Insert java-junit5-maven.xml as a dependency to maven pom.xml

   if [[ $TRYOUT == *"HelloJUnit5"* ]]; then
      fancy_echo "TRYOUT = HelloJUnit5 explained by @jstevenperry at https://ibm.co/2uWIwcp"
      git clone https://github.com/makotogo/HelloJUnit5.git --depth=1
      pushd HelloJUnit5
      chmod +x run-console-launcher.sh
      # doesn't matter if [[ $JAVA_TOOLS == *"maven"* ]]; then
      ./run-console-launcher.sh
      if [[ $JAVA_TOOLS == *"gradle"* ]]; then
         gradle test
      fi
      popd

      # Add folder in .gitignore:
      if [ ! -f "../.gitignore" ]; then
         echo "Adding osx-init/HelloJUnit5/ in ../.gitignore"
         echo "osx-init/HelloJUnit5/" >../.gitignore
         echo "osx-init/.gradle/"    >>../.gitignore
      else 
      	 if ! grep -q "HelloJUnit5" "../.gitignore"; then    
            echo "Adding osx-init/HelloJUnit5/ in ../.gitignore"
            echo "osx-init/HelloJUnit5/" >>../.gitignore
            echo "osx-init/.gradle/"     >>../.gitignore
         fi
      fi
      # Also see http://www.baeldung.com/junit-5-test-order
   fi
fi # See https://howtoprogram.xyz/2016/09/09/junit-5-maven-example/


# Also: https://github.com/google/guava  # Google Core Libraries for Java in maven/gradle


if [[ "$JAVA_TOOLS" == *"jmeter"* ]]; then
   if ! command -v jmeter >/dev/null; then
      fancy_echo "Installing latest version of JAVA_TOOLS=jmeter ..."
      # from https://jmeter.apache.org/download_jmeter.cgi
      brew install jmeter
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "JAVA_TOOLS=jmeter upgrading ..."
         jmeter -v | sed -n 5p | grep "\_\ "  # skip the ASCII art of APACHE.
         brew upgrade jmeter
      fi
   fi
   echo -e "\n$(jmeter --version)" >>$LOGFILE

   if grep -q "export JMETER_HOME=" "$BASHFILE" ; then    
      fancy_echo "JMETER_HOME alias already in $BASHFILE" >>$LOGFILE
   else
      fancy_echo "Adding JMETER_HOME in $BASHFILE..."
      echo "export JMETER_HOME='/usr/local/Cellar/jmeter/3.3'" >>"$BASHFILE"
      source $BASHFILE
   fi 

   # TODO: Paste the file to $JMETER_HOME/lib/ext = /usr/local/Cellar/jmeter/3.3/libexec

   FILE="jmeter-plugins-manager-0.5.jar"  # TODO: Check if version has changed since Jan 4, 2018.
   FILE_PATH="$JMETER_HOME/libexec/lib/ext/jmeter-plugins-manager.jar"
   if [ -f $FILE_PATH ]; then  # file exists within folder 
      fancy_echo "$FILE already installed. Skipping install." >>$LOGFILE
      ls -al             $FILE_PATH >>$LOGFILE
   else
      fancy_echo "Downloading $FILE to $FOLDER ..."
      # From https://jmeter-plugins.org/wiki/StandardSet/
      curl -O http://jmeter-plugins.org/downloads/file/$FILE 
      fancy_echo "Overwriting $FILE_PATH ..."
      yes | cp -rf $FILE  $FILE_PATH 
      ls -al             $FILE_PATH
   fi

   FILE="jmeter-plugins-standard-1.4.0.jar"  # TODO: Check if version has changed since Jan 4, 2018.
      # From https://jmeter-plugins.org/downloads/old/
      # From https://jmeter-plugins.org/downloads/file/JMeterPlugins-Standard-1.4.0.zip
   FILE_PATH="$JMETER_HOME/libexec/lib/ext/jmeter-plugins-standard.jar"
   if [ -f $FILE_PATH ]; then  # file exists within folder 
      fancy_echo "$FILE already installed. Skipping install." >>$LOGFILE
      ls -al             $FILE_PATH >>$LOGFILE
   else
      fancy_echo "Downloading $FILE_PATH ..."
      # See https://mvnrepository.com/artifact/kg.apc/jmeter-plugins-standard
      curl -O http://central.maven.org/maven2/kg/apc/jmeter-plugins-standard/1.4.0/jmeter-plugins-standard-1.4.0.jar
      # 400K received. 
      fancy_echo "Overwriting $FILE_PATH ..."
      yes | cp -rf $FILE $FILE_PATH
      ls -al             $FILE_PATH
   fi

   FILE="jmeter-plugins-extras-1.4.0.jar"  # TODO: Check if version has changed since Jan 4, 2018.
   # From https://jmeter-plugins.org/downloads/old/
   FILE_PATH="$JMETER_HOME/libexec/lib/ext/jmeter-plugins-extras.jar"
   if [ -f $FILE_PATH ]; then  # file exists within folder 
      fancy_echo "$FILE already installed. Skipping install." >>$LOGFILE
      ls -al             $FILE_PATH >>$LOGFILE
   else
      fancy_echo "Downloading $FILE_PATH ..."
      # See https://mvnrepository.com/artifact/kg.apc/jmeter-plugins-extras
      curl -O http://central.maven.org/maven2/kg/apc/jmeter-plugins-extras/1.4.0/jmeter-plugins-extras-1.4.0.jar
      # 400K received. 
      fancy_echo "Overwriting $FILE_PATH ..."
      yes | cp -rf $FILE $FILE_PATH
      ls -al             $FILE_PATH
   fi

   FILE="jmeter-plugins-extras-libs-1.4.0.jar"  # TODO: Check if version has changed since Jan 4, 2018.
      # From https://jmeter-plugins.org/downloads/old/
   FILE_PATH="$JMETER_HOME/libexec/lib/ext/jmeter-plugins-extras-libs.jar"
   if [ -f $FILE_PATH ]; then  # file exists within folder 
      fancy_echo "$FILE already installed. Skipping install."
      ls -al             $FILE_PATH
   else
      fancy_echo "Downloading $FILE_PATH ..."
      # See https://mvnrepository.com/artifact/kg.apc/jmeter-plugins-extras-libs
      curl -O http://central.maven.org/maven2/kg/apc/jmeter-plugins-extras-libs/1.4.0/jmeter-plugins-extras-libs-1.4.0.jar
      # 400K received. 
      fancy_echo "Overwriting $FILE_PATH ..."
      yes | cp -rf $FILE $FILE_PATH
      ls -al             $FILE_PATH
   fi

   mv jmeter*.jar $JMETER_HOME/lib/ext

   if [[ $TRYOUT == *"HelloJUnit5"* ]]; then
      fancy_echo "TRYOUT = HelloJUnit5 explained by @jstevenperry at https://ibm.co/2uWIwcp"
      git clone https://github.com/makotogo/HelloJUnit5.git --depth=1
      pushd HelloJUnit5
      chmod +x run-console-launcher.sh
      # doesn't matter if [[ $JAVA_TOOLS == *"maven"* ]]; then
      ./run-console-launcher.sh
      if [[ $JAVA_TOOLS == *"gradle"* ]]; then
         gradle test
      fi
      popd

      # Add folder in .gitignore:
      if [ ! -f "../.gitignore" ]; then
         echo "Adding osx-init/HelloJUnit5/ in ../.gitignore"
         echo "osx-init/HelloJUnit5/" >../.gitignore
         echo "osx-init/.gradle/"    >>../.gitignore
      else 
      	 if ! grep -q "HelloJUnit5" "../.gitignore"; then    
            echo "Adding osx-init/HelloJUnit5/ in ../.gitignore"
            echo "osx-init/HelloJUnit5/" >>../.gitignore
            echo "osx-init/.gradle/"     >>../.gitignore
         fi
      fi
   fi

   if [[ $TRYOUT == *"jmeter"* ]]; then
      jmeter &  # GUI
   fi

fi # JAVA_TOOLS" == *"jmeter


if [[ "$JAVA_TOOLS" == *"gcviewer"* ]]; then
   if ! command -v gcviewer >/dev/null; then
      fancy_echo "Installing JAVA_TOOLS=gcviewer ..."
      brew install gcviewer
      # creates gcviewer.properties in $HOME folder.
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "JAVA_TOOLS=gcviewer upgrading ..."
         # gcviewer --version
         brew upgrade gcviewer 
            # gcviewer 1.35 already installed
      else
         fancy_echo "gcviewer already installed:" >>$LOGFILE
      fi
      #echo -e "\n$(gcviewer --version)" >>$LOGFILE
   fi
   # .gcviewer.log
fi


if [[ "$JAVA_TOOLS" == *"jprofiler"* ]]; then
   if ! command -v jprofiler >/dev/null; then
      fancy_echo "Installing JAVA_TOOLS=jprofiler ..."
      brew cask install --appdir="/Applications" jprofiler
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "JAVA_TOOLS=jprofiler upgrading ..."
         jprofiler --version
         brew cask install --appdir="/Applications" jprofiler 
      fi
   fi
   echo -e "\n$(jprofiler --version)" >>$LOGFILE
fi

# https://www.bonusbits.com/wiki/HowTo:Setup_Charles_Proxy_on_Mac
# brew install nmap


######### Python modules:


# These may be inside virtualenv:

if [[ "$PYTHON_TOOLS" == *"robotframework"* ]]; then
   PYTHON_INSTALL  # Exit if Python install not successful.
   if ! python -c "import robotframework">/dev/null 2>&1 ; then   
      echo "Installing PYTHON_TOOLS=robotframework ..."; 
      pip install robotframework
      pip install docutils # docutils in ~/Library/Python/2.7/lib/python/site-packages
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "Upgrading PYTHON_TOOLS=robotframework ..."
         echo "$(pip freeze | grep robotframework)"
         pip install robotframework --upgrade
         pip install docutils --upgrade
      fi
   fi
   fancy_echo "$(pip freeze | grep robotframework)"  >>$LOGFILE
      # robotframework==3.0.3

   if [[ $TRYOUT == *"robotframework"* ]]; then
      fancy_echo "TODO: TRYOUT robotframework" 
   fi
fi

if [[ "$PYTHON_TOOLS" == *"others"* ]]; then
   PYTHON_INSTALL  # Exit if Python install not successful.

      echo "Installing PYTHON_TOOLS=others ..."; 
#      pip install git-review
#      pip install scikit-learn

   fancy_echo "pip freeze list of all Python modules installed ::"  >>$LOGFILE
   echo "$(pip freeze)"  >>$LOGFILE
fi


######### Git Signing:

if [[ "$GIT_TOOLS" == *"signing"* ]]; then

   # About http://notes.jerzygangi.com/the-best-pgp-tutorial-for-mac-os-x-ever/
   # See http://blog.ghostinthemachines.com/2015/03/01/how-to-use-gpg-command-line/
      # from 2015 recommends gnupg instead
   # Cheat sheet of commands at http://irtfweb.ifa.hawaii.edu/~lockhart/gpg/

   # If GPG suite is used, add the GPG key to ~/.bash_profile:
   if grep -q "GPG_TTY" "$BASHFILE" ; then    
      fancy_echo "GPG_TTY already in $BASHFILE." >>$LOGFILE
   else
      fancy_echo "Concatenating GPG_TTY export in $BASHFILE..."
      echo "export GPG_TTY=$(tty)" >> "$BASHFILE"
         # echo $(tty) results in: -bash: /dev/ttys003: Permission denied
   fi 

   # NOTE: gpg is the command even though the package is gpg2:
   if ! command -v gpg >/dev/null; then
      fancy_echo "Installing GPG2 for commit signing..."
      brew install gpg2
      # See https://www.gnupg.org/faq/whats-new-in-2.1.html
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "GPG2 upgrading ..."
         gpg --version  # outputs many lines!
         # To avoid response "Error: git not installed" to brew upgrade git
         brew uninstall GPG2 
         # NOTE: This does not remove .gitconfig file.
         brew install GPG2 
      fi
   fi
   echo -e "\n$(gpg --version | grep gpg)" >>$LOGFILE
   #gpg --version | grep gpg
      # gpg (GnuPG) 2.2.5 and many lines!
   # NOTE: This creates folder ~/.gnupg

   # Mac users can store GPG key passphrase in the Mac OS Keychain using the GPG Suite:
   # https://gpgtools.org/
   # See https://spin.atomicobject.com/2013/11/24/secure-gpg-keys-guide/

   # Like https://gpgtools.tenderapp.com/kb/how-to/first-steps-where-do-i-start-where-do-i-begin-setup-gpgtools-create-a-new-key-your-first-encrypted-mail
   if [ ! -d "/Applications/GPG Keychain.app" ]; then 
      fancy_echo "Installing gpg-suite app to store GPG keys ..."
      brew cask uninstall gpg-suite
      brew cask install --appdir="/Applications" gpg-suite  # See http://macappstore.org/gpgtools/
      # Renamed from gpgtools https://github.com/caskroom/homebrew-cask/issues/39862
      # See https://gpgtools.org/
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "gpg-suite app upgrading ..."
         brew cask reinstall gpg-suite 
      else
         fancy_echo "gpg-suite app already installed:" >>$LOGFILE
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
      fancy_echo "A GPG key for $GIT_ID already generated." >>$LOGFILE
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

   # PROTIP: Store your GPG key passphrase so you don't have to enter it every time you 
   #       sign a commit by using https://gpgtools.org/

   # If key is not already set in .gitconfig, add it:
   if grep -q "$KEY" "$GITCONFIG" ; then    
      fancy_echo "Signing Key \"$KEY\" already in $GITCONFIG" >>$LOGFILE
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
      fancy_echo "git config commit.gpgsign already true (on)." >>$LOGFILE
   else # false or blank response:
      fancy_echo "Setting git config commit.gpgsign false (off)..."
      git config --global commit.gpgsign false
      fancy_echo "To activate: git config --global commit.gpgsign true"
   fi
fi


######### TODO: Insert GPG in GitHub:


# TODO: https://help.github.com/articles/telling-git-about-your-gpg-key/
# From https://gist.github.com/danieleggert/b029d44d4a54b328c0bac65d46ba4c65
# Add public GPG key to GitHub
# open https://github.com/settings/keys
# keybase pgp export -q $KEY | pbcopy

# https://help.github.com/articles/adding-a-new-gpg-key-to-your-github-account/


######### WEB_TOOLS ::


if [[ "$WEB_TOOLS" == *"nginx"* ]]; then
   # See https://wilsonmar.github.io/nginx
   JAVA_INSTALL  # pre-requisite
   if ! command -v nginx >/dev/null; then  # in /usr/local/bin/nginx
      fancy_echo "Installing WEB_TOOLS=nginx ..."
      brew install nginx
      brew info nginx >>$LOGFILE
      brew list nginx >>$LOGFILE
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "Upgrading WEB_TOOLS=nginx ..."
         nginx -v  # nginx version: nginx/1.13.11
         brew upgrade nginx
      elif [[ "${MY_RUNTYPE,,}" == *"uninstall"* ]]; then
         fancy_echo "Uninstalling WEB_TOOLS=nginx ..."
         nginx -v  # nginx version: nginx/1.13.11
         brew uninstall nginx
      fi
   fi
   fancy_echo -e "WEB_TOOLS=nginx :: $(nginx -v)" >>$LOGFILE
   echo -e "openssl :: $(openssl version)" >>$LOGFILE

   # Docroot is:    /usr/local/var/www
   # Files load to: /usr/local/etc/nginx/servers/.
   # Default port   /usr/local/etc/nginx/nginx.conf to 8080 so nginx can run without sudo.
   if [[ $TRYOUT == *"nginx"* ]]; then
      PS_OUTPUT=$(ps -ef | grep nginx)
      if grep -q "nginx: master process" "$PS_OUTFILE" ; then 
         fancy_echo "WEB_TOOLS=nginx running on $PS_OUTPUT." >>$LOGFILE
      else
         # NGINX_PORT="8087"  # from default 8080
         fancy_echo "Configuring WEB_TOOLS /usr/local/etc/nginx/nginx.conf to port $NGINX_PORT ..."
         sed -i "s/8080/$NGINX_PORT/g" /usr/local/etc/nginx/nginx.conf

         fancy_echo "Starting WEB_TOOLS=nginx in background ..."
         nginx &
         
         fancy_echo "Opening localhost:$NGINX_PORT for WEB_TOOLS=nginx ..."
         open "http://localhost:$NGINX_PORT"  # to show default Welcome to Nginx
      fi 
   fi
fi

if [[ "$WEB_TOOLS" == *"tomcat"* ]]; then
   # See https://tomcat.apache.org/
   JAVA_INSTALL  # pre-requisite
   if ! command -v tomcat >/dev/null; then  # in /usr/local/bin/tomcat
      fancy_echo "Installing WEB_TOOLS=tomcat ..."
      brew install tomcat
      brew info tomcat >>$LOGFILE
      brew list tomcat >>$LOGFILE
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "Upgrading WEB_TOOLS=tomcat ..."
         tomcat -v  # 9.0.5
         brew upgrade tomcat
      elif [[ "${MY_RUNTYPE,,}" == *"uninstall"* ]]; then
         fancy_echo "Uninstalling WEB_TOOLS=tomcat ..."
         tomcat -v 
         brew uninstall tomcat
      fi
   fi
   fancy_echo -e "WEB_TOOLS=tomcat :: $(tomcat -v)" >>$LOGFILE
   if [[ $TRYOUT == *"tomcat"* ]]; then
      PS_OUTPUT=$(ps -ef | grep tomcat)
      if grep -q "/Library/java" "$PS_OUTFILE" ; then 
         fancy_echo "WEB_TOOLS=tomcat running on $PS_OUTPUT." >>$LOGFILE
      else
         # TOMCAT_PORT="8089"  # from default 8080
         # Using dynamic path /usr/local/opt/tomcat/
         fancy_echo "Configuring WEB_TOOLS /usr/local/opt/tomcat/libexec/conf/server.xml to port $TOMCAT_PORT ..."
         sed -i "s/8080/$TOMCAT_PORT/g" /usr/local/opt/tomcat/libexec/conf/server.xml
            #     <Connector port="8080" protocol="HTTP/1.1"
            #     <Connector executor="tomcatThreadPool"
            #               port="8089" protocol="HTTP/1.1"

         fancy_echo "Starting WEB_TOOLS=tomcat in background ..."
         catalina run &
         # brew services start tomcat  # To have launchd start tomcat now and restart at login

         fancy_echo "Opening localhost:$TOMCAT_PORT for WEB_TOOLS=tomcat ..."
         open "http://localhost:$TOMCAT_PORT"
         # See https://www.mkyong.com/tomcat/how-to-change-tomcat-default-port/

         catalina stop
      fi 
   fi
fi


######### Use git-secret to manage secrets in a git repository:


if [[ "$GIT_TOOLS" == *"secret"* ]]; then
   if ! command -v git-secret >/dev/null; then
      fancy_echo "Installing git-secret for managing secrets in a Git repo ..."
      brew install git-secret
      # See https://github.com/sobolevn/git-secret
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "git-secret upgrading ..."
         git-secret --version  # 0.2.2
         brew upgrade git-secret 
      fi
   fi
   echo -e "\n$(git-secret --version | grep gpg)" >>$LOGFILE
fi
   # QUESTION: Supply passphrase or create keys without passphrase


######### Cloud CLI/SDK:


# See https://cloud.google.com/sdk/docs/
echo "CLOUD=$CLOUD"

if [[ $CLOUD == *"vagrant"* ]]; then  # /usr/local/bin/vagrant
   VIRTUALBOX_INSTALL # pre-requisite
   if ! command -v vagrant >/dev/null; then
      fancy_echo "Installing vagrant ..."
      brew cask install --appdir="/Applications" vagrant
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "vagrant upgrading ..."
         vagrant --version
            # Vagrant 2.0.0
         brew cask upgrade vagrant
      fi
   fi
   echo -e "\n$(vagrant --version)" >>$LOGFILE


   if [[ $TRYOUT == *"hooks"* ]]; then
      if [[ $GIT_LANG == *"python"* ]]; then  # contains azure.
         PYTHON_PGM="hooks/basic-python2"

         if [[ $TRYOUT == *"cleanup"* ]]; then
            fancy_echo "$PYTHON_PGM TRYOUT == cleanup ..."
            rm -rf $PYTHON_PGM
         fi
      fi
      if [[ $GIT_LANG == *"python3"* ]]; then  # contains azure.
         PYTHON_PGM="hooks/basic-python3"
         if [[ $TRYOUT == *"cleanup"* ]]; then
            fancy_echo "$PYTHON_PGM TRYOUT == cleanup ..."
            rm -rf $PYTHON_PGM
         fi
      fi

   # Create a test directory and cd into the test directory.
   #vagrant init precise64  # http://files.vagrantup.com/precise64.box
   #vagrant up
   #vagrant ssh  # into machine
   #vagrant suspend
   #vagrant halt
   #vagrant destroy 
fi


# See https://wilsonmar.github.io/gcp
if [[ $CLOUD == *"gcp"* ]]; then  # contains gcp.
   if [ ! -f "$(command -v gcloud) " ]; then  # /usr/local/bin/gcloud not installed
      fancy_echo "Installing CLOUD=$CLOUD = brew cask install --appdir=\"/Applications\" google-cloud-sdk ..."
      PYTHON_INSTALL  # function defined at top of this file.
      brew tap caskroom/cask
      brew cask install --appdir="/Applications" google-cloud-sdk  # to ./google-cloud-sdk
      gcloud --version
         # Google Cloud SDK 194.0.0
         # bq 2.0.30
         # core 2018.03.16
         # gsutil 4.29
   else
      fancy_echo "CLOUD=$CLOUD = google-cloud-sdk already installed." >>$LOGFILE
   fi
   # NOTE: gcloud command on its own results in an error.

   # Define alias:
      if grep -q "alias gcs=" "$BASHFILE" ; then    
         fancy_echo "alias gcs= already in $BASHFILE" >>$LOGFILE
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
         fancy_echo "awscli upgrading ..."
         aws --version  # aws-cli/1.11.160 Python/2.7.10 Darwin/17.4.0 botocore/1.7.18
         pip3 upgrade awscli --upgrade --user
      fi
   fi
   echo -e "\n$(aws --version)" >>$LOGFILE  # aws-cli/1.11.160 Python/2.7.10 Darwin/17.4.0 botocore/1.7.18

   # TODO: https://github.com/bonusbits/devops_bash_config_examples/blob/master/shared/.bash_aws
   # For aws-cli commands, see http://docs.aws.amazon.com/cli/latest/userguide/ 
fi


if [[ $CLOUD == *"terraform"* ]]; then  # contains aws.
   if ! command -v terraform >/dev/null; then
      fancy_echo "Installing terraform ..."
      brew install terraform 
      # see https://www.terraform.io/
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "terraform upgrading ..."
         terraform --version
            # terraform-cli/1.11.160 Python/2.7.10 Darwin/17.4.0 botocore/1.7.18
         pip3 upgrade terraform 
      fi
   fi
   echo -e "\n$(terraform --version)" >>$LOGFILE
   # terraform --version
            # Terraform v0.11.5

      if grep -q "=\"terraform" "$BASHFILE" ; then    
         fancy_echo "Terraform already in $BASHFILE" >>$LOGFILE
      else
         fancy_echo "Adding Terraform aliases in $BASHFILE ..."
         echo "alias tf=\"terraform \$1\"" >>"$BASHFILE"
         echo "alias tfa=\"terraform apply\"" >>"$BASHFILE"
         echo "alias tfd=\"terraform destroy\"" >>"$BASHFILE"
         echo "alias tfs=\"terraform show\"" >>"$BASHFILE"
      fi
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
         fancy_echo "azure-cli upgrading ..."
         az --version | grep azure-cli
            # azure-cli (2.0.18)
            # ... and many other lines.
         brew upgrade azure-cli
      fi
   fi
   echo -e "\n$(az --version | grep azure-cli)" >>$LOGFILE
   # az --version | grep azure-cli
      # azure-cli (2.0.30)
      # ... and many other lines.
fi


if [[ $CLOUD == *"heroku"* ]]; then  # contains heroku.
   if ! command -v heroku >/dev/null; then  # not installed.
      # https://devcenter.heroku.com/articles/heroku-cli
      fancy_echo "Installing heroku using Homebrew ..."
      brew install heroku/brew/heroku
      # Cloning into '/usr/local/Homebrew/Library/Taps/heroku/homebrew-brew'...
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "Upgrading heroku ..."
         heroku -v
         brew upgrade heroku/brew/heroku
      fi
   fi
   echo -e "$(heroku -v)" >>$LOGFILE  
      # heroku-cli/6.16.8-ae149be (darwin-x64) node-v9.10.1
fi


if [[ $CLOUD == *"openstack"* ]]; then  # contains openstack.
   # See https://iujetstream.atlassian.net/wiki/spaces/JWT/pages/40796180/Installing+the+Openstack+clients+on+OS+X
   PYTHON_INSTALL  # function defined at top of this file.
   if ! command -v openstack >/dev/null; then  # not installed.
      fancy_echo "Installing openstack using Homebrew ..."
      brew install openstack
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "openstack upgrading ..."
         openstack --version | grep openstack
            # openstack (2.0.18)
            # ... and many other lines.
         brew upgrade openstack
      fi
   fi
   echo -e "\n$(openstack --version | grep openstack)" >>$LOGFILE
   # openstack --version | grep openstack
      # openstack (2.0.30)
      # ... and many other lines.

   if [[ $TRYOUT == *"openstack"* ]]; then  # contains openstack.
      OPENSTACK_PROJECT="openstack1"
      # Start the VirtualEnvironment software:
      virtualenv "$OPENSTACK_PROJECT"

      # Activate the VirtualEnvironment for the project:
      source "$OPENSTACK_PROJECT/bin/activate"

      # Install OpenStack clients:
      pip install python-keystoneclient python-novaclient python-heatclient python-swiftclient python-neutronclient python-cinderclient python-glanceclient python-openstackclient

      # Set up your OpenStack credentials: See Setting up openrc.sh for details.
      source .openrc

      # Test a non-destructive Open Stack command:
      openstack image list
   fi
else
   if [[ $TRYOUT == *"openstack"* ]]; then
      fancy_echo "ERROR: \"openstack\" needs to be in CLOUD for TRYOUT."
   fi
fi


if [[ $CLOUD == *"docker"* ]]; then  # contains gcp.
   # First remove boot2docker and Kitematic https://github.com/boot2docker/boot2docker/issues/437
   if ! command -v docker >/dev/null; then  # /usr/local/bin/docker
      fancy_echo "Installing docker ..."
      brew install docker  docker-compose  docker-machine  xhyve  docker-machine-driver-xhyve
      # This creates folder ~/.docker
      # Docker images are stored in $HOME/Library/Containers/com.docker.docker
      brew link --overwrite docker
      # /usr/local/bin/docker -> /Applications/Docker.app/Contents/Resources/bin/docker
      brew link --overwrite docker-machine
      brew link --overwrite docker-compose

      # docker-machine-driver-xhyve driver requires superuser privileges to access the hypervisor. To enable, execute:
      sudo chown root:wheel /usr/local/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
      sudo chmod u+s /usr/local/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "docker upgrading ..."
         docker version
         brew upgrade docker-machine-driver-xhyve
         brew upgrade xhyve
         brew upgrade docker-compose  
         brew upgrade docker-machine 
         brew upgrade docker 
      fi
   fi
   echo -e "\n$(docker --version)" >>$LOGFILE
      # Docker version 18.03.0-ce, build 0520e24
   echo -e "\n$(docker version)" >>$LOGFILE
      # Client:
       # Version:	18.03.0-ce
       # API version:	1.37
       # Go version:	go1.9.4
       # Git commit:	0520e24
       # Built:	Wed Mar 21 23:06:22 2018
       # OS/Arch:	darwin/amd64
       # Experimental:	false
       # Orchestrator:	swarm

   if [[ $TRYOUT == *"docker"* ]]; then  # run docker
      fancy_echo "TRYOUT run docker ..."
      docker-machine create default

      # See https://github.com/bonusbits/devops_bash_config_examples/blob/master/shared/.bash_docker
      # https://www.upcloud.com/support/how-to-configure-docker-swarm/
      # docker-machine --help
      # Create a machine:
      # docker-machine create default --driver xhyve --xhyve-experimental-nfs-share
      # docker-machine create -d virtualbox dev1
      # eval $(docker-machine env default)
      # docker-machine upgrade dev1
      # docker-machine rm dev2fi

      # docker run -d dockerswarm/swarm:master join --advertise=192.168.1.105:2375 consul://192.168.1.103:8500
      # sudo docker run -d dockerswarm/swarm:master join --advertise=192.168.1.105:2375 consul://192.168.1.103:8500
   fi
else
   if [[ $TRYOUT == *"docker"* ]]; then
      fancy_echo "ERROR: \"docker\" needs to be in CLOUD for TRYOUT."
   fi
fi

if [[ $CLOUD == *"minikube"* ]]; then 
   # See https://kubernetes.io/docs/tasks/tools/install-minikube/
   PYTHON_INSTALL  # function defined at top of this file.
   VIRTUALBOX_INSTALL # pre-requisite

   if ! command -v kubectl >/dev/null; then  # not in /usr/local/bin/minikube
      fancy_echo "Installing kubectl using Homebrew ..."
      #  https://kubernetes.io/docs/tasks/tools/install-kubectl/
      brew install kubectl
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "kubectl upgrading ..."
         kubectl version  # minikube version: v0.25.2 
            # ... and many other lines.
         brew upgrade kubectl
      fi
   fi
   echo -e "\n$(kubectl version)" >>$LOGFILE  # version: v0.25.2 

   if ! command -v minikube >/dev/null; then  # not in /usr/local/bin/minikube
      fancy_echo "Installing minikube using Homebrew ..."
      brew cask install minikube
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "minikube upgrading ..."
         minikube version  # minikube version: v0.25.2 
            # ... and many other lines.
         brew cask upgrade minikube
      fi
   fi
   echo -e "\n$(minikube version)" >>$LOGFILE  # version: v0.25.2 

   if [[ $TRYOUT == *"minikube"* ]]; then  # run minikube
      fancy_echo "TRYOUT run minikube ..."
      kubectl cluster-info
      #kubectl cluster-info dump  # for diagnostis

      # See https://kubernetes.io/docs/getting-started-guides/minikube/
      # minikube start
         # Starting local Kubernetes cluster...
         # Running pre-create checks...
         # Creating machine...
         # Starting local Kubernetes cluster...

      # kubectl run hello-minikube --image=k8s.gcr.io/echoserver:1.4 --port=8080
         # deployment "hello-minikube" created
      # kubectl expose deployment hello-minikube --type=NodePort
         # service "hello-minikube" exposed
   fi
else
   if [[ $TRYOUT == *"minikube"* ]]; then
      fancy_echo "ERROR: \"minikube\" needs to be in CLOUD for TRYOUT."
   fi
fi


# https://docs.openstack.org/mitaka/user-guide/common/cli_install_openstack_command_line_clients.html

# TODO: IBM's Cloud CLI from brew? brew search did not find it.
# is installed on MacOS by package IBM_Cloud_CLI_0.6.6.pkg from
# page https://console.bluemix.net/docs/cli/reference/bluemix_cli/get_started.html#getting-started
# or curl -fsSL https://clis.ng.bluemix.net/install/osx | sh
# Once installed, the command is "bx login".
# IBM's BlueMix cloud for AI has a pre-prequisite in NodeJs.
# npm install watson-visual-recognition-utils -g
# npm install watson-speech-to-text-utils -g
# See https://www.ibm.com/blogs/bluemix/2017/02/command-line-tools-watson-services/


if [[ $CLOUD == *"cf"* ]]; then  # contains aws.
   # See https://docs.cloudfoundry.org/cf-cli/install-go-cli.html
   if ! command -v cf >/dev/null; then
      fancy_echo "Installing cf (Cloud Foundry CLI) ..."
      brew install cloudfoundry/tap/cf-cli
      # see https://github.com/cloudfoundry/cli

      # To uninstall on Mac OS, delete the binary /usr/local/bin/cf, and the directory /usr/local/share/doc/cf-cli.
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "cf upgrading ..."
         cf --version
            # cf version 6.35.2+88a03e995.2018-03-15
         brew upgrade cloudfoundry/tap/cf-cli
      fi
   fi
   echo -e "\n$(cf --version)" >>$LOGFILE
   cf --version
      # cf version 6.35.2+88a03e995.2018-03-15

   if [[ $TRYOUT == *"cf"* ]]; then  # run minikube
      fancy_echo "TRYOUT run cf ..."
   fi
else
   if [[ $TRYOUT == *"cf"* ]]; then
      fancy_echo "ERROR: \"cf\" needs to be in CLOUD for TRYOUT."
   fi
fi


######### Virtualenv for Python 2 and Python3:


   # virtualenv supports both Python2 and Python3.
   # virtualenv -p "$(command -v python)" hooks/basic-python2
      #New python executable in /Users/wilsonmar/gits/wilsonmar/git-utilities/tests/basic-python2/bin/python2.7
      #Also creating executable in /Users/wilsonmar/gits/wilsonmar/git-utilities/tests/basic-python2/bin/python
      # Installing setuptools, pip, wheel...
   # virtualenv -p "$(command -v python3)" tests/basic-python3
   # virtualenv -p "c:\Python34\python.exe foo
   if [[ "$PYTHON_TOOLS" == *"virtualenv"* ]]; then
      if ! command -v virtualenv >/dev/null; then  # /usr/bin/virtualenvdriver
         fancy_echo "Installing PYTHON_TOOLS=\"virtualenv\" to manage multiple Python versions ..."
         pip3 install virtualenv
         pip3 install virtualenvwrapper
         source /usr/local/bin/virtualenvwrapper.sh
      else
         fancy_echo "No upgrade on MacOS for PYTHON_TOOLS=\"virtualenv\"."
      fi
      #fancy_echo "Opening virtualenv ..."
      #virtualenv
   else
      if [[ $TRYOUT == *"virtualenv"* ]]; then
         fancy_echo "ERROR: \"virtualenv\" needs to be in PYTHON_TOOLS for TRYOUT."
      fi
   fi
fi


######### SSH-KeyGen:


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
echo -e "\n   $SSHCONFIG ::" >>$LOGFILE
echo -e "$(cat $SSHCONFIG)" >>$LOGFILE

# See https://www.saltycrane.com/blog/2008/11/creating-remote-server-nicknames-sshconfig/
if grep -q "$FILEPATH" "$SSHCONFIG" ; then    
   fancy_echo "SSH \"$FILEPATH\" to \"$GITHUB_ACCOUNT\" already in $SSHCONFIG" >>$LOGFILE
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


######### Paste SSH Keys in GitHub:


# NOTE: pbcopy is a Mac-only command:
if [ "$(uname)" == "Darwin" ]; then
   pbcopy < "$FILE.pub"  # in future pbcopy of password and file transfer of public key.
#elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
fi

   fancy_echo "Now you copy contents of \"${FILEPATH}.pub\", "
   echo "and paste into GitHub, Settings, New SSH Key ..."
#   open https://github.com/settings/keys
   ## TODO: Add a token using GitHub API from credentials in secrets.sh 

   # see https://www.thegeekstuff.com/2008/11/3-steps-to-perform-ssh-login-without-password-using-ssh-keygen-ssh-copy-id/

   fancy_echo "Pop up from folder $FILEPATH ..."
   popd


######### Selenium browser drivers:


# To click and type on browser as if a human would do.
# See http://seleniumhq.org/
# Not necessarily: if [[ $TEST_TOOLS == *"selenium"* ]]; then  # contains .
   # https://www.utest.com/articles/selenium-setup-on-a-mac-and-configuring-selenium-webdriver-on-mac-os
   # per ttps://developer.mozilla.org/en-US/docs/Learn/Tools_and_testing/Cross_browser_testing/Your_own_automation_environment

   # Download the latest webdrivers into folder /usr/bin: https://www.seleniumhq.org/about/platforms.jsp
   # Edge:     https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/
   # Safari:   https://webkit.org/blog/6900/webdriver-support-in-safari-10/
      # See https://itisatechiesworld.wordpress.com/2015/04/15/steps-to-get-selenium-webdriver-running-on-safari-browser/
      # says it's unstable since Yosemite
   # Brave: https://github.com/brave/muon/blob/master/docs/tutorial/using-selenium-and-webdriver.md
      # Much more complicated!

   if [[ $GIT_BROWSER == *"chrome"* ]]; then  # contains azure.
      # Chrome:   https://sites.google.com/a/chromium.org/chromedriver/downloads
      if ! command -v chromedriver >/dev/null; then  # not installed.
         brew install chromedriver  # to /usr/local/bin/chromedriver
      fi

      PS_OUTPUT=$(ps -ef | grep chromedriver)
      if grep -q "chromedriver" "$PS_OUTFILE" ; then # chromedriver 2.36 is already installed
         fancy_echo "chromedriver already running." >>$LOGFILE
      else
         fancy_echo "Deleting chromedriver.log from previous session ..."
         rm chromedriver.log
      fi 

      if [[ $TRYOUT == *"chrome"* ]]; then
         PS_OUTPUT=$(ps -ef | grep chromedriver)
         if grep -q "chromedriver --port" "$PS_OUTPUT" ; then    
            fancy_echo "chromedriver already running." >>$LOGFILE
         else
            fancy_echo "Starting chromedriver in background ..."
            chromedriver & # invoke:
            # Starting ChromeDriver 2.36.540469 (1881fd7f8641508feb5166b7cae561d87723cfa8) on port 9515
            # Only local connections are allowed.
            # [1522424121.500][SEVERE]: bind() returned an error, errno=48: Address already in use (48)
            ps | grep chromedriver
            # 1522423621378   chromedriver   INFO  chromedriver 0.20.0
            # 1522423621446   chromedriver   INFO  Listening on 127.0.0.1:4444
         fi
      fi
   fi


   if [[ $GIT_BROWSER == *"firefox"* ]]; then  # contains azure.
      # Firefox:  https://github.com/mozilla/geckodriver/releases
      if ! command -v geckodriver >/dev/null; then  # not installed.
         brew install geckodriver  # to /usr/local/bin/geckodriver
      fi

      if grep -q "/usr/local/bin/chromedriver" "$BASHFILE" ; then    
         fancy_echo "PATH to chromedriver already in $BASHFILE"
      else
         fancy_echo "Adding PATH to /usr/local/bin/chromedriver in $BASHFILE..."
         echo "" >>"$BASHFILE"
         echo "export PATH=\"\$PATH:/usr/local/bin/chromedriver\"" >>"$BASHFILE"
         source "$BASHFILE"
      fi 

      if [[ $TRYOUT == *"chrome"* ]]; then
         PS_OUTPUT=$(ps -ef | grep geckodriver)
         if grep -q "geckodriver --port" "$PS_OUTPUT" ; then    
            fancy_echo "geckodriver already running." >>$LOGFILE
         else
            fancy_echo "Starting geckodriver in background ..."
            geckodriver & # invoke:
            # 1522423621378   geckodriver INFO  geckodriver 0.20.0
            # 1522423621446   geckodriver INFO  Listening on 127.0.0.1:4444
         fi
         ps | grep geckodriver
      fi 
   fi

   if [[ $GIT_BROWSER == *"phantomjs"* ]]; then  # contains azure.
      # NOTE: http://phantomjs.org/download.html is for direct download.
      if ! command -v phantomjs >/dev/null; then  # not installed.
         brew install phantomjs  # to /usr/local/bin/phantomjs  # for each MacOS release
      else
         if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
            # No need to invoke driver.
            fancy_echo "phantomjs upgrading ..."
            phantomjs --version  # 2.1.1
            brew upgrade phantomjs
         fi
      fi
      PHANTOM_VERSION=$(phantomjs --version)  # 2.1.1
      fancy_echo "PHANTOM_VERSION=$PHANTOM_VERSION"
      # NOTE: "export phantomjs= not nessary with brew install.

      if [[ $TRYOUT == *"phantomjs"* ]]; then
         phantomjs tests/phantomjs-smoke.js
         # More code at http://phantomjs.org/quick-start.html
      fi
   fi


# Browser add-ons:

   # TODO:
   #brew cask install --appdir="/Applications" flash-player  # https://github.com/caskroom/homebrew-cask/blob/master/Casks/flash-player.rb
   #brew cask install --appdir="/Applications" adobe-acrobat-reader
   #brew cask install --appdir="/Applications" adobe-air
   #brew cask install --appdir="/Applications" silverlight


   # TODO: install opencv for Selenium to recognize images
   # TODO: install tesseract for Selenium to recognize text within images

# TODO: http://www.agiletrailblazers.com/blog/the-5-step-guide-for-selenium-cucumber-and-gherkin
   # brew install ruby
   # gem install bundler
   # sudo gem install selenium-webdriver -v 3.2.1
   # gem install cucumber  #  business language
   # gem install rspec  # BDD mocking and performance assertions
   # if [[ $TRYOUT == *"bdd"* ]]; then 
   #   fancy_echo "TRYOUT run bdd ..."
    #       ruby test.rb
    # fi


if [[ $TEST_TOOLS == *"protractor"* ]]; then  # contains .
   # protractor for testing AngularJS versions greater than 1.0.6/1.1.4, 
   # See http://www.protractortest.org/#/ and https://www.npmjs.com/package/protractor
   NODE_INSTALL  # pre-requsite nodejs v6 and newer.
   # https://github.com/mbcooper/ProtractorExample

   # TODO: Inside virtualenv ?
   # npm install -g protractor
   # protractor conf.js  # run test
fi


######### GitHub hub to manage GitHub functions:


if [[ "$GIT_TOOLS" == *"hub"* ]]; then
   GO_INSTALL  # prerequiste
   if ! command -v hub >/dev/null; then  # in /usr/local/bin/hub
      fancy_echo "Installing hub for managing GitHub from a Git client ..."
      brew install hub
      # See https://hub.github.com/

      # fancy_echo "Adding git hub in $BASHFILE..."
      # echo "alias git=hub" >>"$BASHFILE"
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "hub upgrading ..."
         hub version | grep hub  # git version 2.16.3 # hub version 2.2.9
         brew upgrade hub 
      fi
   fi
   echo -e "\n   hub git version ::" >>$LOGFILE
   echo -e "$(hub version)" >>$LOGFILE
fi


######### Python test coding languge:


   if [[ $GIT_LANG == *"python"* ]]; then  # contains azure.
      # Python:
      # See https://saucelabs.com/resources/articles/getting-started-with-webdriver-in-python-on-osx
      # Get bindings: http://selenium-python.readthedocs.io/installation.html

      # TODO: Check aleady installed:
         pip install selenium   # password is requested. 
            # selenium in /usr/local/lib/python2.7/site-packages

      # TODO: If webdrive is installed:
         pip install webdriver

      if [[ $GIT_BROWSER == *"chrome"* ]]; then  # contains azure.
         python tests/chrome_pycon_search.py chrome
         # python tests/chrome-google-search-quit.py
      fi
      if [[ $GIT_BROWSER == *"firefox"* ]]; then  # contains azure.
         python tests/firefox_github_ssh_add.py
         # python tests/firefox_unittest.py  # not working due to indents
         # python tests/firefox-test-chromedriver.py
      fi
      if [[ $GIT_BROWSER == *"safari"* ]]; then  # contains azure.
         fancy_echo "Need python tests/safari_github_ssh_add.py"
      fi

      # TODO: https://github.com/alexkaratarakis/gitattributes/blob/master/Python.gitattributes
   fi   

# Now to add/commit - https://marklodato.github.io/visual-git-guide/index-en.html
# TODO: Protractor for AngularJS
# For coding See http://www.techbeamers.com/selenium-webdriver-python-tutorial/

# TODO: Java Selenium script


######### Sauce Labs with Node Selenium :


# https://github.com/saucelabs-sample-test-frameworks/JS-Protractor-Selenium
#   SAUCE_USERNAME=""
#   SAUCE_ACCESS_KEY=""
# ./node_modules/.bin/protractor conf.js


######### Golum Python Framework for Selenium :


if [[ $TEST_TOOLS == *"golum"* ]]; then  # contains golum.
   PYTHON3_INSTALL  # pre-requisite
   # https://golem-framework.readthedocs.io/en/latest/installation.html
   # https://github.com/lucianopuccio/Golem.git 
   pip install golem-framework  # installs Flask, itsdangerous, Werkzeug, MarkupSafe, 

   # Sstart the Golem Web Module, run the following command:
   golem gui

   #The Web Module can be accessed at 
   # open "http://localhost:5000/"

   # By default, the following user is available: username: admin / password: admin
   if [[ $TRYOUT == *"cleanup"* ]]; then
      echo -e "\n   Removing all logs ::" >>$LOGFILE
      echo -e "ls *.log" >>$LOGFILE
      rm geckodriver.log
      rm jmeter.log
      rm ghostdriver.log
      rm *.log
   fi
fi


######### COMM_TOOLS


#fancy_echo "At installing Collaboration / screen sharing:" >>$LOGFILE

   # https://www.biba.com/downloads.html
   # blue jeans? (used by ATT)
   # GONE? brew cask install --appdir="/Applications" Colloquy. ## IRC http://colloquy.info/downloads.html
   # GONE: brew cask install --appdir="/Applications" gotomeeting   # 32-bit

if [[ $COMM_TOOLS == *"hangouts"* ]]; then
   brew cask install --appdir="/Applications" google-hangouts
fi
if [[ $COMM_TOOLS == *"hipchat"* ]]; then 
   brew cask install --appdir="/Applications" hipchat
fi
if [[ $COMM_TOOLS == *"joinme"* ]]; then 
   brew cask install --appdir="/Applications" joinme
fi
if [[ $COMM_TOOLS == *"keybase"* ]]; then 
   brew cask install --appdir="/Applications" keybase  # encrypted https://keybase.io/
fi
if [[ $COMM_TOOLS == *"skype"* ]]; then 
   brew cask install --appdir="/Applications" skype  # unselect show birthdays
fi
   # obsolete: brew cask install --appdir="/Applications" microsoft-lync
   #brew cask install --appdir="/Applications" skype-for-business  # unselect show birthdays

if [[ $COMM_TOOLS == *"slack"* ]]; then
   brew cask install --appdir="/Applications" slack  # installed to "~/Applications" by default.
fi
if [[ $COMM_TOOLS == *"sococo"* ]]; then 
   brew cask install --appdir="/Applications" sococo
fi
if [[ $COMM_TOOLS == *"teamviewer"* ]]; then 
   brew cask install --appdir="/Applications" teamviewer
fi
if [[ $COMM_TOOLS == *"whatsapp"* ]]; then 
   brew cask install --appdir="/Applications" whatsapp
fi
if [[ $COMM_TOOLS == *"zoom"* ]]; then 
   brew cask install --appdir="/Applications" zoom   # 32-bit
fi
    #https://zapier.com/blog/disable-mic-webcam-notifications/


######### MEDIA TOOLS:


if [[ "$MEDIA_TOOLS" == *"others"* ]]; then
    echo "Installing MEDIA_TOOLS=others ..."; 
# brew cask install adobe-creative-cloud
# brew cask install camtasia   # screen recording and video editing
# brew cask install handbrake  # rip DVD
# brew cask install audacity   # audio recording and editing
# brew install ffmpeg
# brew install youtube-dl
# brew cask install qlimageize
# brew cask install screenflow
# brew cask install vlc
# brew cask install sketchup
#   brew cask install snagit

fi


######### Dump contents:


# List variables
echo -e "\n   env varibles, alphabetically ::" >>$LOGFILE
echo -e "$(export -p)" >>$LOGFILE

# List ~/.bash_profile:
echo -e "\n   $BASHFILE ::" >>$LOGFILE
echo -e "$(cat $BASHFILE)" >>$LOGFILE


#########  brew cleanup


#Listing of all brew cask installed (including dependencies automatically added):"
echo -e "\n   brew info --all ::" >>$LOGFILE
echo -e "$(brew info --all)" >>$LOGFILE
#Listing of all brews installed (including dependencies automatically added):""

if [[ $TRYOUT == *"cleanup"* ]]; then
   brew cleanup --force
   echo -e "\n   ls ~/Library/Caches/Homebrew ::" >>$LOGFILE
   echo -e "$(ls ~/Library/Caches/Homebrew)" >>$LOGFILE
   rm -f -r /Library/Caches/Homebrew/*
fi

# List contents of ~/.gitconfig
echo -e "\n   $GITCONFIG ::" >>$LOGFILE
echo -e "$(cat $GITCONFIG)" >>$LOGFILE

# List using git config --list:
echo -e "\n   git config --list ::" >>$LOGFILE
echo -e "$(git config --list)" >>$LOGFILE



######### Open editor to show log:


if [[ $TRYOUT == *"editor"* ]]; then
   fancy_echo "Opening editor in background to display log ..."
   case "$GIT_EDITOR" in
        atom)
            echo atom
            atom $LOGFILE &
            ;;
        code)
            echo code
            code $LOGFILE &
            ;;
        eclipse)
            echo eclipse
            eclipse $LOGFILE &
            ;;
        emacs)
            echo emacs
            emacs $LOGFILE &
            ;;
        macvim)
            echo macvim
            macvim $LOGFILE &
            ;;
        nano)
            echo nano
            nano $LOGFILE &
            ;;
        pico)
            echo pico
            pico $LOGFILE &
            ;;
        sublime)
            echo sublime
            subl $LOGFILE &
            ;;
        textedit)
            echo textedit
            textedit $LOGFILE &
            ;;
        textmate)
            echo textmate
            textmate $LOGFILE &
            ;;
        vim)
            echo vim
            vim $LOGFILE &
            ;;
        *)
            echo "$GIT_EDITOR not recognized."
            exit 1
   esac
fi



######### Disk space consumed:


FREE_DISKBLOCKS_END=$(df | sed -n -e '2{p;q}' | cut -d' ' -f 6) 
DIFF=$(((FREE_DISKBLOCKS_START-FREE_DISKBLOCKS_END)/2048))
echo -e "\n   $DIFF MB of disk space consumed during this script run." >>$LOGFILE
# 380691344 / 182G = 2091710.681318681318681 blocks per GB
# 182*1024=186368 MB
# 380691344 / 186368 G = 2042 blocks per MB

TIME_END=$(date -u +%s);
DIFF=$((TIME_END-TIME_START))
MSG="End of script after $((DIFF/60))m $((DIFF%60))s seconds elapsed."
fancy_echo "$MSG"
echo -e "\n$MSG" >>$LOGFILE
