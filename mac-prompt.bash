# mac-prompt.bash in https://github.com/wilsonmar/git-utilities
# For concatenating/pasting into ~/.bash_profile 

function gd() { # get dirty
	[[ $(git status 2> /dev/null | tail -n1) != *"working directory clean"* ]] && echo "*"
}
function parse_git_branch() {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(gd)/"
}
#function parse_git_branch() {
#     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
#}
export PS1="\n  \w\[\033[33m\] \$(parse_git_branch)\[\033[00m\]\n$ "
