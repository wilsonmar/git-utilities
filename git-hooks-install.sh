#!/bin/sh

# git-hooks-install.sh
# by wilsonmar at gmail.com
# After the repo is cloned, this bash script copies 
# scripts in the repo's hooks folder into the .git/hooks 
# and sets permissions.

fancy_echo() { # to add blank line between echo statements:
  local fmt="$1"; shift
  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

fancy_echo "Remove *.sample files ..."
del .git/hooks/*.sample

fancy_echo "Copy hooks/git-commit into .git/hooks  ..."
cp hooks/prepare-commit-msg .git/hooks
chmod +x .git/hooks/prepare-commit-msg

#cp hooks/git-commit  .git/hooks
#chmod +x .git/hooks/git-commit

cp hooks/git-push  .git/hooks
chmod +x .git/hooks/git-push

cp hooks/git-rebase  .git/hooks
chmod +x .git/hooks/git-rebase

ls .git/hooks

fancy_echo "Done with status $? (0=OK)."
