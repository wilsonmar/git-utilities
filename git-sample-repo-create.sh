#!/usr/bin/env bash

# git-sample-repo-create.sh from within http://github.com/wilsonmar/git-utilities.
# by Wilson Mar (wilsonmar@gmail.com
# This creates and populates a sample repo for my "Git and GitHub" tutorial,
# Explained at https://wilsonmar.github.io/git-commands-and-statuses/)

# Sample call in MacOS Terminal shell window:
# chmod +x git-sample-repo-create.sh
# ./git-sample-repo-create.sh

# Tested on MacOS 10.11 (El Capitan)
# TODO: Get a version that works on Windows

# clear
echo ""
echo ""
echo ""
echo ""
echo ""
# Make the beginning of run easy to find:
echo "**********************************************************"
echo "******** STEP Delete \"$REPONAME\" remnant from previous run:"
REPONAME='git-sample-repo'
rm -rf ${REPONAME}
mkdir ${REPONAME}
cd ${REPONAME}
CURRENTDIR=${PWD##*/}

echo "******** Git version :"
# After "brew install git" on Mac:
git --version

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
DEFAULT_BRANCH="develop"
echo $DEFAULT_BRANCH

echo "******** STEP Config (not --global):"
# See https://git-scm.com/docs/pretty-formats :
git config user.email "wilsonmar@gmail.com"
git config user.name "Wilson Mar" # Username (not email) in GitHub.com cloud.
git config user.user "wilsonmar" # Username (not email) in GitHub.com cloud.
#GITHUBUSER=$(git config github.email)  # Username (not email) in GitHub.com cloud.
# echo $GIT_AUTHOR_EMAIL
# echo $GIT_COMMITTER_EMAIL
GITHUBUSER="wilsonmar"
echo "******** GITHUBUSER=$GITHUBUSER "

# After gpg is installed:
# gpg --list-keys
# gpg --gen-key
git config --global user.signingkey 2E23C648

# Verify settings:
git config core.filemode false

# On Unix systems, ignore ^M symbols created by Windows:
# git config core.whitespace cr-at-eol

# Change default commit message editor program to Sublime Text (instead of vi):
git config core.editor "~/Sublime\ Text\ 3/sublime_text -w"

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
touch README.md
git add .
git commit -m "README.md"
git l -1

echo "******** STEP amend commit README : "
# ammend last commit with all uncommitted and un-staged changes:
echo "some more\n">>README.md
git ca  # use this alias instead of git commit -a --amend -C HEAD
git l -1

echo "******** STEP amend commit 2 : "
# ammend last commit with all uncommitted and un-staged changes:
echo "still more\n">>README.md
git ca  # alias for git commit -a --amend -C HEAD
git l -1

echo "******** STEP commit .DS_Store in .gitignore :"
echo ".DS_Store">>.gitignore
git add .
git commit -m "Add .gitignore"
git l -1

echo "******** STEP commit --amend .passwords in .gitignore :"
echo ".passwords">>.gitignore
git add .
git ca  # use this alias instead of git commit -a --amend -C HEAD
git l -1

git reflog
ls -al

cat README.md

# echo "******** rebase squash : "


echo "******** STEP lightweight tag :"
git tag "v1"  # lightweight tag

echo "******** STEP checkout HEAD to create feature1 branch : --------------------------"
git checkout HEAD -b feature1
# git branch
ls .git/refs/heads/
git l -1

echo "******** STEP commit c - LICENSE.md : "
echo "MIT">>LICENSE.md
git add .
git commit -m "Add c"
git l -1
ls -al

echo "******** STEP commit: d"
echo "free!">>LICENSE.md
echo "d">>file-d.txt
git add .
git commit -m "Add d in feature1"
git l -1
ls -al

echo "******** STEP Merge feature1 :"
# Instead of git checkout $DEFAULT_BRANCH :
git checkout @{-1}  # checkout previous branch (develop, master)

# Alternately, use git-m.sh to merge and delete in one step.
# git merge --no-ff (no fast forward) for "true merge":
#git merge feature1 --no-ff --no-commit  # to see what may happen
git merge feature1 -m "merge feature1" --no-ff  # --verify-signatures 
# resolve conflicts here?
git add .
# git commit -m "commit merge feature1"
git branch
git l -1

echo "******** $NOW Remove merged branch ref :"
git branch -D feature1
git branch
echo "******** $NOW What's dangling? "
git fsck --dangling --no-progress
git l -1

echo "******** STEP commit: e"
echo "e">>file-e.txt
git add .
git commit -m "Add e"
git l -1

echo "******** STEP commit: f"
echo "f">>file-f.txt
ls -al
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
ls -al

# exit

echo "******** Reflog: ---------------------------------------"
git reflog
echo "******** show HEAD@{5} :"
git w HEAD@{5}


echo "******** Create archive file, excluding .git directory :"
NOW=$(date +%Y-%m-%d:%H:%M:%S-MT)
FILENAME=$(echo ${REPONAME}_${NOW}.zip)
echo $FILENAME
# Commented out to avoid creating a file from each run:
# git archive --format zip --output ../$FILENAME  feature1
# ls -l ../$FILENAME


echo "******** checkout c :"
ls -al
git show HEAD@{5}
git checkout HEAD@{5}
ls -al

echo "******** Go back to HEAD --hard :"
git reset --hard HEAD
# git checkout HEAD
ls -al


echo "******** Garbage Collect (gc) what Git can't reach :"
git gc
git reflog
ls -al
echo "******** Compare against previous reflog."

# git stash save "text message here"

# git stash list /* shows whats in stash */
# git stash show -p stash@{0} /* Show the diff in the stash */

# git stash pop stash@{0} /*  restores the stash deletes the tash */
# git stash apply stash@{0} /*  restores the stash and keeps the stash */
# git stash drop stash@{0}
# git stash clear /*  removes all stash */


# Undo last commit, preserving local changes:
# git reset --soft HEAD~1

# Undo last commit, without preserving local changes:
# git reset --hard HEAD~1

# Undo last commit, preserving local changes in index:
# git reset --mixed HEAD~1

# Undo non-pushed commits:
# git reset origin/$DEFAULT_BRANCH


#     Revert a range of the last two commits:
# git revert HEAD~2..HEAD
# Create several revert commits:
# git revert a867b4af 25eee4ca 0766c053

# Reverting a merge commit
# git revert -m 1 <merge_commit_sha>
# See http://git-scm.com/blog/2010/03/02/undoing-merges.html


# From https://www.youtube.com/watch?v=sevc6668cQ0&t=41m40s
# git rebase master --exec "make test"

# echo "******** Bisect loop : "
# for loop:
#     git bisect start
#     git bisect good master
#     git bisect run make test
# end loop

# echo "******** Remote commands : "
# git fetch origin
# git reset --hard origin/$DEFAULT_BRANCH

# echo "******** Cover your tracks:"
# Remove from repository all locally deleted files:
# git rm $(git ls-files --deleted)

# Move the branch pointer back to the previous HEAD:
# git reset --soft HEAD@{1}

# See https://gist.github.com/caspyin/2288960 about GitHub API
# From https://gist.github.com/robwierzbowski/5430952 on Windows
# From https://gist.github.com/jerrykrinock/6618003 on Mac
# read "REPONAME?New repo name (enter for ${PWD##*/}):"

# read "USER?Git Username (enter for ${GITHUBUSER}):"
# read "DESCRIPTION?Repo Description:"
DESCRIPTION="Automated Git repo from run using $REPONAME in https://github.com/wilsonmar/git-utilities."
#echo "Enter <return> to make the new repo public, 'x' for private"

echo "****** GITHUBUSER=$GITHUBUSER, CURRENTDIR=$CURRENTDIR, REPONAME=$REPONAME"
echo "****** DESCRIPTION=$DESCRIPTION"

# Invoke file defined manually containing definition of GITHUB_PASSWORD:
source ~/.passwords  # but don't ECHO "GITHUB_PASSWORD=$GITHUB_PASSWORD"

   # Bash command to load contents of file into env. variable:
export RSA_PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)
   # TODO: Windows version.
   # ECHO "RSA_PUBLIC_KEY=$RSA_PUBLIC_KEY"

# Since no need to create another if one already exists:
if [ "$GITHUB_TOKEN" = "" ]  # Not run before
then
	echo "******** Creating Auth GITHUB_TOKEN to delete repo later : "
    GITHUB_TOKEN=$(curl -v -u "$GITHUBUSER:$GITHUB_PASSWORD" -X POST https://api.github.com/authorizations -d "{\"scopes\":[\"delete_repo\"], \"note\":\"token with delete repo scope\"}" | jq ".token")
       # (using jq installed locally)
       # See https://developer.github.com/v3/oauth_authorizations/#create-a-new-authorization

   # WORKFLOW: Manually see API Tokens on GitHub | Account Settings | Administrative Information 
else  
	echo "******** Verifying Auth GITHUB_TOKEN to delete repo : "
#    FIX: Commented out due to syntax error near unexpected token `|'
    RESPONSE=$(curl -v -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com | jq ".repository_url")
    echo "******** repository_url=$RESPONSE"
    #curl -v -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com 
       # API Token (32 character long string) is unique among all GitHub users.
       # Response: X-OAuth-Scopes: user, public_repo, repo, gist, delete_repo scope.
    # TODO: Check if RESPONSE is what's expected (URL). exit if not.
fi

####
    echo "******** Checking GITHUB_AVAIL from prior run . "
    GITHUB_AVAIL=$(curl -X GET https://api.github.com/repos/${GITHUBUSER}/${REPONAME}  | jq ".full_name")
    echo "GITHUB_AVAIL=$GITHUB_AVAIL"
       # Expecting "full_name": "wilsonmar/git-sample-repo",

if [ "$GITHUB_AVAIL" = "${GITHUBUSER}/${REPONAME}" ]  # Not run before
then
	echo "******** No GITHUB repo known to delete. "
else
	echo "******** Deleting GITHUB_REPO created earlier : "
        # TODO: Delete repo in GitHub.com Settings if it already exists:
      # Based on https://gist.github.com/JadedEvan/5639254
      # See http://stackoverflow.com/questions/19319516/how-to-delete-a-github-repo-using-the-api
    curl -X DELETE -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/${GITHUBUSER}/${REPONAME}
      # Response is 204 No Content per https://developer.github.com/v3/repos/#delete-a-repository
#    GITHUB_AVAIL = ""
fi

#### Create repo in GitHub:
curl -u $GITHUBUSER:$GITHUB_PASSWORD https://api.github.com/user/repos -d "{\"name\": \"${REPONAME:-${CURRENTDIR}}\", \"description\": \"${DESCRIPTION}\", \"private\": false, \"has_issues\": false, \"has_downloads\": true, \"has_wiki\": false}"
   # Response is a bunch of JSON with HATEOAS.

#curl -u "$GITHUBUSER:$GITHUB_PASSWORD" --data "{\"title\":\"test-key\",\"key\":\"ssh-rsa ${RSA_PUBLIC_KEY} \"}" https://api.github.com/user/keys
# Now go to the GitHub.com account and see the new repo there and
# manually add your public key to your github account

# if response is valid:
    # Set the freshly created repo to the origin and push
    git remote add origin "https://github.com/$GITHUBUSER/$REPONAME.git"
    git remote -v
    git push --set-upstream origin develop

#    git remote set-url origin git@github.com:${GITHUBUSER}/${REPONAME}.git
#    git remote set-head origin develop
#    git config branch.develop.remote origin
# fi

exit
echo "********** Making change that will be duplicated oneline : "
echo "Change locally">>README.md

echo "********** DOTHIS: Manually make a change online GitHub file : "
echo "Add to bottom of README.md \"Changed online\" and Save."

echo "********** Doing git pull to create conflict : "
git pull



# Commented out for cleanup at start of next run:
# cd ..
# rm -rf ${REPONAME}

echo "******** $NOW end."
