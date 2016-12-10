# git-hooks-install.ps1
# by wilsonmar at gmail.com
# After the repo is cloned, this PowerShell multi-platform script
# copies scripts in the repo's hooks folder into the .git/hooks
# and sets permissions.

#echo "Remove *.sample files in .git/hooks ..."
Remove-Item .git/hooks/*.sample

#echo "Copy hooks/git-commit into .git/hooks  ..."
Copy-Item hooks/*  .git/hooks
#Copy-Item hooks/git-commit  .git/hooks
#Copy-Item hooks/git-push  .git/hooks
#Copy-Item hooks/git-rebase  .git/hooks
#Copy-Item hooks/prepare-commit-msg .git/hooks

#echo "Change permissions  ..."
$SUBDIR=".git/hooks"
Get-ChildItem "$SUBDIR" -Filter *.log | 
Foreach-Object {
    $content = Get-Content $_.FullName
    echo $content
    if( $IsWindows -eq $True ) {
       # attrib to set file permissions
       # icacls to set ownership in Access Control Lists
    }
    if ( $IsOSX -eq $True){
       chmod +x $SUBDIR$content
    }
}

#echo "Change permissions  ..."
ls .git/hooks

echo "Done with status $? (0=OK)."
