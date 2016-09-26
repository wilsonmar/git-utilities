Function Touch-File
{
    $file = $args[0]
    if($file -eq $null) {
        throw "No filename supplied"
    }

    if(Test-Path $file)
    {
        (Get-ChildItem $file).LastWriteTime = Get-Date
    }
    else
    {
        echo $null > $file
    }
}

Function Color-All-Black {

  $strComputer = "."

  $colItems = get-wmiobject -class "Win32_Process" -namespace "root\CIMV2" `
  -computername $strComputer | write-output

  foreach ($objItem in $colItems) {
#      if ($objItem.WorkingSetSize -gt 3000000) {
#      write-host  $objItem.Name, $objItem.WorkingSetSize -foregroundcolor "magenta" }
#     else {
     write-host $objItem.Name, $objItem.WorkingSetSize
#     }
  }
}