# aliases.sh in https://github.com/wilsonmar/git-utilities
# NOTE: Functions are in functions.sh for Mac only.
# Both called from ~/.bash_profile for Bash or ~/.zshrc for zsh
# on both MacOS and git bash on Windows.

EDITOR="code"  # code = Visual Studio Code; subl = Sublime Text
alias sbe="$EDITOR ~/.bash_profile"
alias sbp='source ~/.bash_profile'
alias rs='exec -l $SHELL'

alias ..='cd ..'
alias c="clear"  # screen
alias h='history'
alias x='exit'
alias p="pwd"
alias j='jobs -l'

alias now='date +"%T %d-%m-%Y"'
alias epoch='date -u +%s'

alias dir='ls -alrT'  # for windows habits
alias l='ls -FalhGT'  # T for year
alias lf="ls -p"      # list folders only
alias cf="find . -print | wc -l"  # count files in folder.
# Last 30 files updated anywhere:
alias f30='stat -f "%m%t%Sm %N" /tmp/* | sort -rn | head -30 | cut -f2- 2>/dev/null'

alias kp="ps auxwww"  # the "kp" alias ("que pasa")

alias myip="ifconfig en0 | grep inet | grep -v inet6 | cut -d ' ' -f2"  # https://www.whatismyip.com/
alias pubip="curl ifconfig.me"  # public IP
alias mac="curl http://canhazip.com"  # public IP also from slower "curl -s ifconfig.me" or curl https://checkip.amazonaws.com
alias wanip4='dig @resolver1.opendns.com ANY myip.opendns.com +short'
alias wanip6='dig @resolver1.opendns.com AAAA myip.opendns.com +short -6'
alias ramfree="top -l 1 -s 0 | grep PhysMem"

alias ga='git add .'  # --patch
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

# alias ports="sudo netstat -tulpn"  # mac

#if command -v docker >/dev/null; then  # installed in /usr/local/bin/docker
#   echo "Docker installed, so ..."
#   alias dockx="docker stop $(docker ps -a -q);docker rm -f $(docker ps -a -q)"
#fi

# More: https://www.cyberciti.biz/tips/bash-aliases-mac-centos-linux-unix.html