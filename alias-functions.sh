# alias-functions.txt in https://github.com/wilsonmar/git-utilities
# For concatenating/pasting into ~/.bash_profile 
# on MacOS only, not in git bash for windows.

function gd() { # get dirty
	[[ $(git status 2> /dev/null | tail -n1) != *"working directory clean"* ]] && echo "*"
}
function parse_git_branch() {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(gd)/"
}

function gas() { git status ;  git add . -A ; git commit -m "$1" ; git push; }
function gsa() { git stash save "$1" -a; git stash list; }  # -a = all (untracked, ignored)
