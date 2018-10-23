# aliases.txt in https://github.com/wilsonmar/git-utilities
# For concatenating/pasting into ~/.bash_profile 

EDITOR="subl"
alias sbe="$EDITOR ~/.bash_profile"
alias sbp='source ~/.bash_profile'
alias rs='exec -l $SHELL'

alias c="clear"
alias p="pwd"
alias x='exit'
alias dir='ls -alr'  # for windows habits
alias ll='ls -FalhG'
alias last20='stat -f "%m%t%Sm %N" /tmp/* | sort -rn | head -20 | cut -f2-'
alias myip="ifconfig en0 | grep inet | grep -v inet6 | cut -d ' ' -f2"  # https://www.whatismyip.com/
alias pubip="curl ifconfig.me"  # public IP
alias ga='git add .'
function gas() { git status ;  git add . -A ; git commit -m "$1" ; git push; }
function gsa() { git stash save "$1" -a; git stash list; }  # -a = all (untracked, ignored)
alias gb='git branch -avv'
alias gbs='git status -s -b;git add . -A;git commit -m"Update";git push'
alias get='git fetch;' # git pull
alias gf='git fetch origin master;git diff master..origin/master'
alias gfu='git fetch upstream;git diff HEAD @{u} --name-only'
alias gc='git commit -m' # requires you to type a commit message
alias gcm='git checkout master'
alias gl='git log --pretty=format:"%h %s %ad" --graph --since=1.days --date=relative;git log --show-signature -n 1'
alias l1="git log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias l2="git log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
alias gmo='git merge origin/master'
alias gp='git push'
alias gpom='git push -u origin master'
alias grm='git rm $(git ls-files --deleted)'
alias gri='git rebase -i'
alias grl='git reflog -n 7'
alias grh='git reset --hard'
alias grl='git reflog -n 7'
alias grv='git remote -v'
alias gsl='git status -s -b; git stash list'
alias gss='git stash show'
alias hb="hub browse"
