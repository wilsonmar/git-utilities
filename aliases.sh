# aliases.sh in https://github.com/wilsonmar/git-utilities
# NOTE: Functions are in functions.sh for Mac only.
# Both called from ~/.bash_profile for Bash or ~/.zshrc for zsh
# on both MacOS and git bash on Windows.

EDITOR="code"  # subl = Sublime Text
alias sbe="$EDITOR ~/.bash_profile"
alias sbp='source ~/.bash_profile'
alias rs='exec -l $SHELL'

alias c="clear"  # screen
alias x='exit'
alias p="pwd"
alias cf="find . -print | wc -l"  # count files in folder.
alias dir='ls -alrT'  # for windows habits
alias l='ls -FalhGT'  # T for year
alias last20='stat -f "%m%t%Sm %N" /tmp/* | sort -rn | head -20 | cut -f2-'
alias myip="ifconfig en0 | grep inet | grep -v inet6 | cut -d ' ' -f2"  # https://www.whatismyip.com/
alias pubip="curl ifconfig.me"  # public IP
alias pubip="curl http://canhazip.com"  # public IP also from slower "curl -s ifconfig.me" or curl https://checkip.amazonaws.com
alias wanip4='dig @resolver1.opendns.com ANY myip.opendns.com +short'
alias wanip6='dig @resolver1.opendns.com AAAA myip.opendns.com +short -6'
alias ramfree="top -l 1 -s 0 | grep PhysMem"

alias ga='git add .'  # --patch
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

alias tf="terraform $1"
alias tfa="terraform apply"
alias tfd="terraform destroy"
alias tfs="terraform show"

alias dockx="docker stop $(docker ps -a -q);docker rm -f $(docker ps -a -q)"
alias ports="sudo netstat -tulpn"  # mac