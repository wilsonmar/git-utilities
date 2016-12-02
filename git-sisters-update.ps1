# git-sisters-update.ps1 from within http://github.com/wilsonmar/git-utilities.
# by Wilson Mar (wilsonmar@gmail.com, @wilsonmar)

# This script was created for experiementing and learning Git with GitHub.
# Git commands in this script are meant as examples for manual entry
# explained during my live "Git and GitHub" tutorials and
# explained at https://wilsonmar.github.io/git-commands-and-statuses/).
# Most of the regularly used Git commands are covered here.

# This script clones and edits a sample repo with known history.

# This script is designed to be "idempotent" in that repeat runs
# result in the same condition whether it's run the first or subsequent times.
# This is achieved by beginning the run by deleting what was created
# by the previous run.

# PRE-REQUSITES: Before running this on a Mac, install PowerShell for Mac.
   # TODO: Add handling of script call attribute containing REPONAME and GITHUB_USER:
  $GITHUB_USERID="wilson-jetbloom" # <-- replace with your own

# Sample call in MacOS running PowerShell for Mac: 
#     chmod +x git-sisters-update.ps1
#     ./git-sisters-update.ps1
# results in "Add " as branch name. Alternately, run script with your own branch:
#     ./git-sisters-update.ps1 "Add year 1979"

# Last tested on MacOS 10.12 (Sierra) 2015-11-29
# http://skimfeed.com/blog/windows-command-prompt-ls-equivalent-dir/


function sisters_new_photo-info
{
    # sisters_new_photo-info  1979  "Bloomfield, Connecticut"
    $PIC_YEAR = $args[0] # 1979 or other year.
    $FILE_CONTEXT = "photo-info.md" # file name
    $PIC_CITY = $args[1] # City

    Remove-Item $FILE_CONTEXT -recurse -force # CAUTION: deleting file!
        # -force deletion of hidden and read only items.
    New-Item $FILE_CONTEXT >$null
    $NL = "`n" # New Line $s, $t -join ", "
    $OUT_STRING  = "# Photo Information" +$NL
    $OUT_STRING += $NL
    $OUT_STRING += "**Year:** " +$PIC_YEAR +$NL # **Year:** 1978
    $OUT_STRING += $NL
    $OUT_STRING += "**City: ** " +$PIC_CITY +$NL # **City: ** Harwich Port, Massachusetts
    $OUT_STRING | Set-Content $FILE_CONTEXT

        echo "******** cat $FILE_CONTEXT for $PIC_YEAR : AFTER changes :"
    cat $FILE_CONTEXT
}

function sisters_new_meta_file
{
    # TODO: 
    $PERSON_NAME = $args[0]
    $FILE_CONTEXT = $args[0].ToLower() + ".md" # file name

    $SMILING = $args[1] # smiling true or false
    $CLOTHING = $args[2]

    Remove-Item $FILE_CONTEXT -recurse -force # CAUTION: deleting file!
        # -force deletion of hidden and read only items.
    New-Item $FILE_CONTEXT >$null

    $NL = "`n" # New Line $s, $t -join ", "
    $OUT_STRING  = "# $PERSON_NAME" +$NL 
    $OUT_STRING += $NL
    # PROTIP: Double grave-accent(`) to use back-tick as regular text: 
    $OUT_STRING += "**Smiling:** ``$SMILING``" +$NL
    $OUT_STRING += $NL
    $OUT_STRING += "**Outfit:** $CLOTHING"
    $OUT_STRING | Set-Content $FILE_CONTEXT

        echo "******** cat $FILE_CONTEXT : AFTER changes :"
    cat $FILE_CONTEXT
}

function sisters_replace_meta_file
{
    $PERSON_NAME  = $args[0]
    $FILE_CONTEXT = $args[0].ToLower() + ".md" # file name
        echo "******** cat $FILE_CONTEXT : BEFORE change :"
    cat $FILE_CONTEXT

        echo "******** processing $FILE_CONTEXT :"
    #$SMILING = $args[1] # smiling true or false
    #$CLOTHING = $args[2] 

               # Get-Content info: https://technet.microsoft.com/en-us/library/ee176843.aspx
    $WORK_TEXT = Get-Content $FILE_CONTEXT 
    #cat $WORK_TEXT

    # About regex in PowerShell: https://www.youtube.com/watch?v=K3JKmWmbbGM
    if ($args[1] -eq "true"){
      $WORK_TEXT -replace '(\*\*Smiling:\*\* `true`)' ,'\*\*Smiling:\*\* `false`'
    }else{ # -eq "false"
      $WORK_TEXT -replace '(\*\*Smiling:\*\* `false`)','\*\*Smiling:\*\* `true`'
    }

    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
    [System.IO.File]::WriteAllLines($MyPath, $WORK_TEXT, $Utf8NoBomEncoding)
    # $WORK_TEXT | Set-Content $FILE_CONTEXT
    # Set-Content info: https://msdn.microsoft.com/powershell/reference/5.1/microsoft.powershell.management/Set-Content?f=255&MSPPError=-2147217396

    # PROTIP: Use https://regex101.com/ using Flavor: PY (python) to verify:
    # Put slashes in front of special characters used as regular text:  

        echo "******** cat $FILE_CONTEXT : AFTER changes :"
    cat $FILE_CONTEXT
}


# Create blank lines in the log to differentiate different runs:
        echo ""
        echo ""
        echo ""
        echo ""
        echo ""
   # Make the beginning of run easy to find:
        echo "**********************************************************"
$NOW = Get-Date -Format "yyyy-MM-ddTHH:mmzzz"
        echo "******** NOW=$NOW :"
    $psversiontable
           echo "IsWindows=$IsWindows"
           echo "IsOSX=$IsOSX"
           echo "IsLinux=$IsLinux"
    #[System.Environment]::OSVersion.Version

git --version

# exit #1

  $REPONAME='sisters'
  $UPSTREAM="https://github.com/hotwilson/sisters" # a repo prepared for the class.
  $CURRENT_COMMIT=""

        echo "******** Delete $REPONAME remaining from previous run (for idempotent script):"
$FileExists = Test-Path $REPONAME
if ($FileExists -eq $True ){
   # See https://technet.microsoft.com/en-ca/library/hh849765.aspx?f=255&MSPPError=-2147217396
   Remove-Item -path ${REPONAME} -Recurse -Force # instead of rm -rf ${REPONAME}
}
#  exit #2

# New-item ${REPONAME} -ItemType "directory" >$null  # instead of mkdir ${REPONAME}
   # >$null suporesses several lines being printing out by PS to confirm.

    $GITHUB_REPO="https://github.com/"+ $GITHUB_USERID +"/"+ $REPONAME
        echo "******** Before running this, fork from $UPSTREAM "
        echo "******** git clone $GITHUB_REPO "
         # Notice the string concatenation format:
git clone "$($GITHUB_REPO).git" # $REPONAME # --depth=1

    # Size of bytes in folder: instead of Linux command): du -hs ${REPONAME}
    # (7 files in 1475 bytes) https://blogs.technet.microsoft.com/heyscriptingguy/2012/05/25/getting-directory-sizes-in-powershell/
    Get-ChildItem $REPONAME | Measure-Object -Sum Length | Select-Object Count, Sum

#  exit #3

        echo "******** Ensure $REPONAME folder is specified in .gitignore file:"
# & ((Split-Path $MyInvocation.InvocationName) + "\my_ps_functions.ps1")
if (Test-Path ".gitignore"){
   #     echo "******** .gitignore file found within ${REPONAME} folder."
   Select-String -Pattern "$REPONAME" -Path ".gitignore" > $null # -CaseSensitive
   #get-content myfile.txt -ReadCount 1000 | foreach { $_ -match "my_string" }
        echo "******** ${REPONAME} FOUND within .gitignore file."
} Else {
   echo "${REPONAME}">>.gitignore   # save text at bottom of file.
    #  sed 's/fields/fields\nNew Inserted Line/' .gitignore
        echo "******** ${REPONAME} added to bottom of .gitignore file."
}
#  exit #4


cd ${REPONAME}
$CurrentDir = $(get-location).Path;
# This outputs the parent folder, not the current folder:
#$CURRENTDIR = (Get-Item -Path ".\" -Verbose).FullName   # Get-Location cmdlet
#$CURRENTDIR = $PSScriptRoot    # PowerShell specific
#        echo "CURRENTDIR=$CURRENTDIR"
        echo "******** Now in $REPONAME folder! - cd .. before re-run!"
        echo $CURRENTDIR

# exit #5


        echo "******** Run PowerShell file for Git configurations at the repo level:"
        $ScriptPath = Split-Path $MyInvocation.InvocationName
        Write-Host "Path:" $MyInvocation.MyCommand.Path
        # NOTE: PowerShell accepts both forward and backward slashes:
        & ((Split-Path $MyInvocation.InvocationName) + '/git_client-config.ps1') 
        # Alternately, use & to run scripts in same scope: 
        # & "../git_client-config.ps1 global" #
        # Alternately, use . to run scripts in child scope that will be thrown away: 
        # . "../git_client-config.ps1 global" #

#  exit #6

         echo "******** git remote add upstream $UPSTREAM :"
git remote add upstream ${UPSTREAM} 
         echo "******** git remote -v :"
git remote -v
         echo "******** git remote show origin :"
git remote show origin

         echo "******** cat .git/HEAD to show internal current branch:"
    # The contents of HEAD is stored in this file:
    cat .git/HEAD

         echo "******** git branch -avv at master:"
git branch -avv

# exit #7

         echo "******** git l = git log of commits in repo:"
         # add -10 to list 10 lines using l for log alias:
git l
         echo "******** tree of folders in working area:"
    # PS TRICK: Different commands to list folders with properties:
    if( "$IsWindows" -eq $True ) {
        dir
    }else{ # Mac / Linux:
        ls # -al
    }            
    #tree
         echo "******** git reflog (showing only what occurred locally):"
git reflog

         # These above commands cover the 5 dimensions: branch, commits, files, staging, lines, hunks.

         echo "******** git status at initial clone:"
git status

#  exit #8

         echo "******** cat ${REPONAME}/bebe.md at HEAD:"
    cat bebe.md

         echo "******** git blame bebe.md : "
git blame bebe.md
         # NOTE: 
         echo "******** git l = git log of commits in repo:"
         # add -10 to list 10 lines using l for log alias:
git l -10
         # Notice the title "BeBe" and blank lines in the file are from the initial commit.
         # Two lines were changed in the latest commit.

#  exit #9

#         echo "******** git show --oneline --abbrev-commit - press q to quit:"
#git show --oneline --abbrev-commit

#        echo "******** Begin trace :"
#    # Do not set trace on:
#    set -x  # xtrace command         echo on (with ++ prefix). http://www.faqs.org/docs/abs/HTML/options.html

        echo "******** git checkout master branch:"
git checkout master

    # PS TRICK: Check for no arguments specified with invocation command:
    if( $($args.Count) -eq 0 ) {
       $CURRENT_BRANCH="feature1"
    }else{
       $CURRENT_BRANCH=$args[0]
    } 
        echo "******** git checkout new branch ""$CURRENT_BRANCH"" from master branch :"
git checkout -b $CURRENT_BRANCH 
    git branch -avv
        # PS TRICK: Double-quotes to display words in quotes: 
        echo "******** git reflog at ""$CURRENT_BRANCH"" :"
    git reflog

    $CURRENT_YEAR = "1979"
        echo "******** Make changes to $CURRENT_YEAR files and stage it at $CURRENT_COMMIT :"
sisters_new_photo-info  $CURRENT_YEAR  "Hartford, Connecticut"
    # Notice the person name is upper/lower case:
sisters_new_meta_file  BeBe     false  "Whatever that is"
sisters_new_meta_file  Heather  false  "boots"
sisters_new_meta_file  Laurie   false  "boots"
sisters_new_meta_file  Mimi     true   "boots"

#  exit #10

        echo "******** git status : before git add :"
    git status
        echo "******** git add :"
git add .  # photo-info.md  bebe.md  heather.md  laurie.md  mimi.md
        echo "******** git status : after git add "
    git status
        echo "******** git commit of $CURRENT_YEAR (new commit SHA) :"
git commit -m"Snapshot for $CURRENT_YEAR"
        echo "******** git status : after git add "
    git status
        echo "******** Note nothing listed after git commit."
        echo "******** git l = git log of commits in repo:"
    git l

 exit #11

    # TODO: Extract $CURRENT_COMMIT from capturing git command.

    $CURRENT_COMMIT="c4b84db"
        echo "******** git checkout $CURRENT_COMMIT : (parent branch) :"
git checkout $CURRENT_COMMIT
         echo "******** cat bebe.md at $CURRENT_COMMIT :"
    cat bebe.md
        echo "******** git log at $CURRENT_BRANCH :"
    git commit

  exit #12

    $CURRENT_COMMIT="a874ef4"
        echo "******** git reset --soft $CURRENT_COMMIT (to remove it):"
git reset --soft $CURRENT_COMMIT
        echo "******** git fsck after $CURRENT_COMMIT :"
    git fsck
        echo "******** git reflog at $CURRENT_BRANCH :"
    git reflog

   exit #13

        echo "******** Make changes to files and stage it at $CURRENT_COMMIT :"
echo "change 1">>bebe.md
git add bebe.md
        echo "******** git reset HEAD at $CURRENT_COMMIT :"
git reset HEAD
        echo "******** git fsck after $CURRENT_COMMIT :"
    git fsck

   exit #14

    $CURRENT_COMMIT="82e957c"
        echo "******** git reset --hard a874ef2 :"
git reset --hard $CURRENT_COMMIT
        echo "******** git fsck after $CURRENT_COMMIT :"
    git fsck


   exit #15

        echo "******** $NOW end."

