clear
cd sisters

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

    #$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
    #[System.IO.File]::WriteAllLines($MyPath, $WORK_TEXT, $Utf8NoBomEncoding)

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

        echo "******** Make changes to files and stage it at $CURRENT_COMMIT :"
    sisters_new_photo-info  1979  "Hartford, Connecticut"
   # Notice the person name is upper/lower case:
   sisters_new_meta_file  BeBe    false  "Whatever that is"
#   sisters_new_meta_file  Heather  false  "boots"
#    sisters_new_meta_file  Laurie   false  "boots"
#   sisters_new_meta_file  Mimi     true  "boots"

cd ..