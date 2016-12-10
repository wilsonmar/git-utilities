# git-hooks-install.ps1
# by wilsonmar at gmail.com
# After the repo is cloned, this PowerShell script copies
# scripts in the repo's hooks folder into the .git/hooks
# and sets permissions.

echo "Remove *.sample files in .git/hooks ..."
Remove-Item .git/hooks/*.sample

echo "Copy hooks/git-commit into .git/hooks  ..."

Copy-Item hooks/*  .git/hooks
#Copy-Item hooks/git-commit  .git/hooks
#Copy-Item hooks/git-push  .git/hooks
#Copy-Item hooks/git-rebase  .git/hooks
#Copy-Item hooks/prepare-commit-msg .git/hooks

if( $IsWindows -eq $True ) {
   # icacls
}
if ( $IsOSX  -eq $True){
   chmod +x .git/hooks/git-commit
   chmod +x .git/hooks/git-push
   chmod +x .git/hooks/git-rebase
   chmod +x .git/hooks/prepare-commit-msg
}

ls .git/hooks

# echo "Done with status $? (0=OK)."
