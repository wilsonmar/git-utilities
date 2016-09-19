
# git-sample-repo-create.ps1 from within http://github.com/wilsonmar/git-utilities.
# by Wilson Mar (wilsonmar@gmail.com, @wilsonmar)

# This script was created for experiementing and learning Git.
# Git commands in this script are meant as examples for manual entry
# explained during my live "Git and GitHub" tutorials and
# explained at https://wilsonmar.github.io/git-commands-and-statuses/).
# Most of the regularly used Git commands are covered here.

# This script creates and populates a sample repo which is then 
# uploaded to a new repo created using GitHub API calls

# This script is designed to be "idempotent" in that repeat runs
# begin by deleting what was created: the local repo and repo in GitHub.

# Sample call in Win10 running within MacOS:
# chmod +x git-sample-repo-create.sh
# ./git-sample-repo-create.sh

# Last tested on MacOS 10.11 (El Capitan) 2015-09-15
# http://skimfeed.com/blog/windows-command-prompt-ls-equivalent-dir/

# Create blank lines in the log to differentiate different runs:
echo ""
echo ""
echo ""
echo ""
echo ""

echo "******** Version :"
#if [ "$IsWindows" ]; then
   $psversiontable
   echo "IsWindows=$IsWindows"
   echo "IsOSX=$IsOSX"
   echo "IsLinux=$IsLinux"
#fi
git --version

# Make the beginning of run easy to find:
echo "**********************************************************"
$REPONAME='git-sample-repo'
echo "******** STEP Delete $REPONAME remnant from previous run:"
$FileExists = Test-Path $REPONAME
if ($FileExists -eq $True ){
   # See https://technet.microsoft.com/en-ca/library/hh849765.aspx?f=255&MSPPError=-2147217396
   Remove-Item -path ${REPONAME} -Recurse -Force #rm -rf ${REPONAME}  # PowerShell specific
   # Ignore error about path not being there.
}
New-item ${REPONAME}  # mkdir ${REPONAME}
exit
cd ${REPONAME}
#$CURRENTDIR = (Get-Item -Path ".\" -Verbose).FullName   # Get-Location cmdlet
$CURRENTDIR = $PSScriptRoot    # PowerShell specific
echo "CURRENTDIR=$CURRENTDIR"


echo "******** STEP Init repo :"
# init without --bare so we get a working directory:
git init
# return the .git path of the current project::
git rev-parse --git-dir
ls .git/

echo "******** STEP Make develop the default branch instead of master :"
# The contents of HEAD is stored in this file:
cat .git/HEAD
# Change from default "ref: refs/heads/master" :
    # See http://www.kernel.org/pub/software/scm/git/docs/git-symbolic-ref.html
git symbolic-ref HEAD refs/heads/develop
cat .git/HEAD
git branch
$DEFAULT_BRANCH="develop"
echo "DEFAULT_BRANCH=$DEFAULT_BRANCH"


echo "******** STEP Attribution & Config (not --global):"
# See https://git-scm.com/docs/pretty-formats :
git config user.email "wilsonmar@gmail.com"
git config user.name "Wilson Mar" # Username (not email) in GitHub.com cloud.
$GITHUBUSER="wilsonmar"
echo "******** GITHUBUSER=$GITHUBUSER "


# WORKFLOW: After gpg is installed, find:
# gpg --list-keys
# gpg --gen-key
git config user.signingkey 2E23C648  # not --global

# Verify settings:
git config core.filemode false

git config core.autocrlf input
git config core.safecrlf true


# On Unix systems, ignore ^M symbols created by Windows:
# git config core.whitespace cr-at-eol

# Change default commit message editor program to Sublime Text (instead of vi):
git config core.editor "$home/Sublime\ Text\ 3/sublime_text -w"

# Allow all Git commands to use colored output, if possible:
git config color.ui auto

# See https://git-scm.com/docs/pretty-formats : Add "| %G?" for signing
# In Windows, double quotes are needed:
git config alias.l  "log --pretty='%Cred%h%Creset %C(yellow)%d%Creset | %Cblue%s%Creset' --graph"
git config alias.s  "status -s"
#it config alias.w "show -s --quiet --pretty=format:'%Cred%h%Creset | %Cblue%s%Creset | (%cr) %Cgreen<%ae>%Creset'"
git config alias.w  "show -s --quiet --pretty=format:'%Cred%h%Creset | %Cblue%s%Creset'"
git config alias.ca "commit -a --amend -C HEAD" # (with no message)

# Have git diff use mnemonic prefixes (index, work tree, commit, object) instead of standard a and b notation:
git config diff.mnemonicprefix true

# Reuse recorded resolution of conflicted merges - https://git-scm.com/docs/git-rerere
git config rerere.enabled false

# git config --list   # Dump config file

echo "******** STEP commit (initial) README :"
echo "hello" > README.md  # no touch command on Windows.
git add .
git commit -m "README.md"
git l -1


echo "******** STEP amend commit README : "
# ammend last commit with all uncommitted and un-staged changes:
echo "some more\r\n">>README.md
git ca  # use this alias instead of git commit -a --amend -C HEAD
git l -1

echo "******** STEP amend commit 2 : "
# ammend last commit with all uncommitted and un-staged changes:
echo "still more\r\n">>README.md
git ca  # alias for git commit -a --amend -C HEAD
git l -1
git diff

echo "******** STEP commit .DS_Store in .gitignore :"
echo ".DS_Store">>.gitignore
git add .
git commit -m "Add .gitignore"
git l -1

echo "******** STEP commit --amend .secrets in .gitignore :"
echo ".secrets">>.gitignore
git add .
git ca  # use this alias instead of git commit -a --amend -C HEAD
git l -1

git reflog
Get-ChildItem  # ps for ls -al

cat README.md

echo "******** STEP lightweight tag :"
git tag "v1"  # lightweight tag

echo "******** STEP checkout HEAD to create feature1 branch : --------------------------"
git checkout HEAD -b feature1
# git branch
ls .git/refs/heads/
git l -1

echo "******** STEP commit c - LICENSE.md : "
echo "MIT\r\n">>LICENSE.md
git add .
git commit -m "Add c"
git l -1
Get-ChildItem  # ls -al

echo "******** STEP commit: d"
echo "free!">>LICENSE.md
echo "d">>file-d.txt
git add .
git commit -m "Add d in feature1"
git l -1
Get-ChildItem  # ls -al


echo "******** STEP Merge feature1 :"
# Instead of git checkout $DEFAULT_BRANCH :
# git checkout @{-1}  # doesn't work in PowerShell.
git checkout $DEFAULT_BRANCH
   # response is "Switched to branch 'develop"

# Alternately, use git-m.sh to merge and delete in one step.
# git merge --no-ff (no fast forward) for "true merge":
#git merge feature1 --no-ff --no-commit  # to see what may happen
git merge feature1 -m "merge feature1" --no-ff  # --verify-signatures 
# resolve conflicts here?
git add .
# git commit -m "commit merge feature1"
git branch
git l -1


echo "******** STEP Remove merged branch ref :"
git branch -D feature1
git branch
git l -1

echo "******** $NOW What's dangling? "
git fsck --dangling --no-progress

echo "******** STEP commit: e"
echo "e">>file-e.txt
git add .
git commit -m "Add e"
git l -1

echo "******** STEP commit f : "
echo "f">>file-f.txt
Get-ChildItem
git add .
git commit -m "Add f"
git l -1


echo "******** STEP heavyeight tag (a commit) :"
#  git tag -a v0.0.1 -m"v1 unsigned"
   git tag -a v0.0.1 -m"v1 signed" -s  # signed "heavyweight" tag
   # For numbering, see http://semver.org/
# echo "******** STEP tag verify :"
# git tag -v v1  # calls verify-tag.
git verify-tag v0.0.1

# echo "******** STEP tag show :"
# git show v1  # Press q to exit scroll.


echo "Copy this and paste to a text edit for reference: --------------"
git l
echo "******** show HEAD : ---------------------------------------"
git w HEAD
echo "******** show HEAD~1 :"
git w HEAD~1
echo "******** show HEAD~2 :"
git w HEAD~2
echo "******** show HEAD~3 :"
git w HEAD~3
echo "******** show HEAD~4 :"
git w HEAD~4

echo "******** show HEAD^ :"
git w HEAD^
echo "******** show HEAD^^ :"
git w HEAD^^
echo "******** show HEAD^^^ :"
git w HEAD^^^
echo "******** show HEAD^^^^ :"
git w HEAD^^^^

echo "******** show HEAD^1 :"
git w HEAD^1
echo "******** show HEAD^2 :"
git w HEAD^2

echo "******** show HEAD~1^1 :"
git w HEAD~1^1
echo "******** show HEAD~2^1 :"
git w HEAD~2^1
echo "******** show HEAD~3^1 :"
git w HEAD~3^1

echo "******** show HEAD~1^2 :"
git w HEAD~1^2

echo "******** show HEAD~2^2 :"
git w HEAD~2^2
echo "******** show HEAD~2^3 :"
git w HEAD~2^3
Get-ChildItem  # ls -al

echo "******** Reflog: ---------------------------------------"
git reflog

exit

echo "******** show HEAD@{5} :"
# FIX: git w HEAD@{5}

echo "******** Create archive file, excluding .git directory :"
$NOW = Get-Date -Format "yyyy-MM-ddTHH:mmzzz"
# WARNING: The DateTime string format returned by Get-Date contains characters that can't be used for file names. Try something like this:
# new-item -path .\desktop\testfolder -name "$NOW.txt" `
#        -value (get-date).toString() -itemtype file
$FILENAME="$REPONAME_$NOW.zip"
#NOW=$(date +%Y-%m-%d:%H:%M:%S)
#FILENAME=$(echo ${REPONAME}_${NOW}.zip)
   # See https://gallery.technet.microsoft.com/scriptcenter/Get-TimeZone-PowerShell-4f1a34e6

echo "FILENAME=$FILENAME"

# Commented out to avoid creating a file from each run:
# git archive --format zip --output ../$FILENAME  feature1
# ls -l ../$FILENAME


echo "******** STEP checkout c :"
Get-ChildItem  # ls -al
git show HEAD@{5}
git checkout HEAD@{5}
Get-ChildItem

echo "******** Go back to HEAD --hard :"
git reset --hard HEAD
# git checkout HEAD
Get-ChildItem


echo "******** Garbage Collect (gc) what Git can't reach :"
git gc
git reflog
Get-ChildItem
echo "******** Compare against previous reflog."




# See https://gist.github.com/caspyin/2288960 about GitHub API
# From https://gist.github.com/robwierzbowski/5430952 on Windows
# From https://gist.github.com/jerrykrinock/6618003 on Mac

echo "****** GITHUBUSER=$GITHUBUSER, CURRENTDIR=$CURRENTDIR, REPONAME=$REPONAME"
echo "****** DESCRIPTION=$DESCRIPTION"

# Invoke file defined manually containing definition of GITHUB_PASSWORD:
# Dot is cross-platform whereas source command is only for Bash:
   $RSA_PUBLIC_KEY = Get-Content "~/.ssh/id_rsa.pub"
   # echo "RSA_PUBLIC_KEY=$RSA_PUBLIC_KEY"
      # Bash command to load contents of file into env. variable:
#   export RSA_PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)
   # TODO: Windows version.
   # ECHO "RSA_PUBLIC_KEY=$RSA_PUBLIC_KEY"

   $SECRETS = Get-Content "~/.secrets" | ConvertFrom-StringData
   echo $SECRETS.TWITTER_TOKEN
   # err: echo "SECRETS.TWITTER_TOKEN=${SECRETS.TWITTER_TOKEN}"

   Import-module "../MyTwitter.psm1"
   Send-Tweet -Message '@adbertram Thanks for the Powershell Twitter module'

   $body = @{
    Name = "So long and thanks for all the fish"
   }
   Invoke-RestMethod -Method Post -Uri "$resource\new" -Body (ConvertTo-Json $body) -Header @{"X-ApiKey"=$apiKey}

    #GITHUB_TOKEN=$(curl -v -u "$GITHUBUSER:$GITHUB_PASSWORD" -X POST https://api.github.com/authorizations -d "{\"scopes\":[\"delete_repo\"], \"note\":\"token with delete repo scope\"}" | jq ".token")
