# alias-functions.txt in https://github.com/wilsonmar/git-utilities
# For concatenating/pasting into ~/.bash_profile 
# on MacOS only, not in git bash for windows.

function gd() { # get dirty
	[[ $(git status 2> /dev/null | tail -n1) != *"working directory clean"* ]] && echo "*"
}
function gas() { git status ;  git add . -A ; git commit -m "$1" ; git push; }
function gsa() { git stash save "$1" -a; git stash list; }  # -a = all (untracked, ignored)


# color code next line based on previous commands return code..
bash_prompt_command()
{
    RTN=$?
    prevCmd=$(prevCmd $RTN)
}
PROMPT_COMMAND=bash_prompt_command
prevCmd()
{
    if [ $1 == 0 ] ; then
        echo $GREEN
    else
        echo $RED
    fi
}
if [ $(tput colors) -gt 0 ] ; then
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    RST=$(tput op)
fi
export PS1="[e[36m]u.h.W[e[0m][$prevCmd]>[$RST]"

#For use on Mac only (not Windows Git Bash):
function parse_git_branch() {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(gd)/"
}
# This enables:
export PS1="\n  \w\[\033[33m\] \$(parse_git_branch)\[\033[00m\]\n$ "
# instead of:
#export PS1="\n\n  \w\[\033[33m\] \n$ "

# On Mac only:
# alias ss="/System/Library/Frameworks/ScreenSaver.framework/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine -background &"

### Get os name via uname ###
_myos="$(uname)"
 
### add alias as per os using $_myos ###
case $_myos in
   Linux) alias foo='/path/to/linux/bin/foo';;
   FreeBSD|OpenBSD) alias foo='/path/to/bsd/bin/foo' ;;
   SunOS) alias foo='/path/to/sunos/bin/foo' ;;
   *) ;;
esac


# To convert between number bases:
d2b() {
  [ -z "$1" ] && echo "usage: d2b decnumber" && return 1
  echo "obase=2; $1" | bc
}
d2h() {
  [ -z "$1" ] && echo "usage: d2h decnumber" && return 1
  echo "obase=16; $1" | bc
}
h2b() {
  [ -z "$1" ] && echo "usage: h2b hexnumber" && return 1
  echo "obase=2; ibase=16; " `echo $1 | tr '[a-zxX]*' '[A-Z00]'` | bc
}
h2d() {
  [ -z "$1" ] && echo "usage: h2d hexnumber" && return 1
  echo "ibase=16; " `echo $1 | tr '[a-zxX]*' '[A-Z00]'` | bc
}
b2d() {
  [ -z "$1" ] && echo "usage: b2d binnumber" && return 1
  echo "ibase=2; $1" | bc
}
b2h() {
  [ -z "$1" ] && echo "usage: b2h binnumber" && return 1
  echo "obase=16; ibase=2; $1" | bc
}
