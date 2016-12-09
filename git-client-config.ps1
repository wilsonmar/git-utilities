# git_client-config.ps1 within https://github.com/wilsonmar/git-utilities
# for running under PowerShell on Mac or Windows
# See https://www.develves.net/blogs/asd/articles/using-git-with-powershell-on-windows-10/

# Default is local:
if( $args[0] -eq "global" ) {
   $GIT_GLOBAL = "--global"
}else{
   $GIT_GLOBAL = "" # local 
} 

        echo "******** Running script file git_client-config.ps1"
# Change string from "" to "--global" 
if( $GIT_GLOBAL -eq "--global" ) {
        echo "******** Creating $GIT_GLOBAL repo in $HOME home dir using git config commands"
}else{
        echo "******** Creating local ../.git/config file using git config commands"
}


# TODO: Create separate shell file to define git aliases for repo.
# Verify settings:
    git config $GIT_GLOBAL core.filemode false

# Using variables built into PowerShell: See https://help.github.com/articles/dealing-with-line-endings/
# See https://www.jetbrains.com/help/idea/2016.2/handling-lf-and-crlf-line-endings.html
if( $IsWindows -eq $True ) {
        echo "******** Configuring git core.autocrlf for Windows!"
    git config $GIT_GLOBAL core.autocrlf true
}
if ( $IsOSX  -eq $True){
        echo "******** Configuring git core.autocrlf for Mac!"
    git config $GIT_GLOBAL core.autocrlf input
}
        # see https://help.github.com/articles/dealing-with-line-endings/
        # to remove files in Git's index and reset from HEAD to pick up new line endings.
        # On Git add . it is ok to see messages:
        # "warning: CRLF will be replaced by LF in file."

    git config $GIT_GLOBAL push.default simple

    git config $GIT_GLOBAL core.safecrlf true

# On Unix systems, ignore ^M symbols created by Windows:
# git config $GIT_GLOBAL core.whitespace cr-at-eol

# Change default commit message editor program to Sublime Text (instead of vi):
if ( $IsOSX  -eq $True){
    git config $GIT_GLOBAL core.editor "~/Sublime\ Text\ 3/sublime_text -w"
    #git config $GIT_GLOBAL core.editor=subl -w
}

# Allow all Git commands to use colored output, if possible:
git config $GIT_GLOBAL color.ui auto
git config $GIT_GLOBAL color.status always
#color.branch.current=green bold
#color.branch.remote=red bold
#color.status.add=green bold
#color.status.added=green bold
#color.status.updated=green bold
#color.status.changed=red bold
#color.status.untracked=red bold

# See https://git-scm.com/docs/pretty-formats : Add "| %G?" for signing
# In Windows, double quotes are needed:
git config $GIT_GLOBAL alias.l  "log --pretty='%Cred%h%Creset %C(yellow)%d%Creset | %Cblue%s%Creset' --graph"
    # To see first 5 lines: git l -5 

git config $GIT_GLOBAL alias.s  "status -s"
#it config $GIT_GLOBAL alias.w "show -s --quiet --pretty=format:'%Cred%h%Creset | %Cblue%s%Creset | (%cr) %Cgreen<%ae>%Creset'"
git config $GIT_GLOBAL alias.w  "show -s --quiet --pretty=format:'%Cred%h%Creset | %Cblue%s%Creset'"
git config $GIT_GLOBAL alias.ca "commit -a --amend -C HEAD" # (with no message)

# Have git diff use mnemonic prefixes (index, work tree, commit, object) instead of standard a and b notation:
git config $GIT_GLOBAL diff.mnemonicprefix true
    # See http://stackoverflow.com/questions/28017249/what-does-diff-mnemonicprefix-do
    # diff --git i/foo/bar.txt w/foo/bar.txt
    # index abcd123..1234abc 100644
    # --- i/foo/bar.txt
    # +++ w/foo/bar.txt
    # See https://git-scm.com/docs/diff-config

# Save & Reuse Recorded Resolution of conflicted merges - https://git-scm.com/docs/git-rerere
git config $GIT_GLOBAL rerere.enabled false
    # See https://chuva-inc.com/blog/fast-tip-enable-git-rerere-right-now

# Disable “how to stage/unstage/add” hints given by git status:
git config $GIT_GLOBAL advice.statusHints false

# Allow git diff to do basic rename and copy detection:
git config $GIT_GLOBAL diff.renames copies

#Always show a diffstat at the end of a merge:
git config $GIT_GLOBAL merge.stat true

# git config $GIT_GLOBAL --list   # Dump config $GIT_GLOBAL file

