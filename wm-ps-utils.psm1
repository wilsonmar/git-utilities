# wm-ps-utils.psm1 in https://github.com/wilsonmar/git-utilities
#            .psm1 = PowerShell module
# .ps1 files using this needs to have this at the top of the file:
#      Import-Module wm-ps-utils.psm1
# See https://msdn.microsoft.com/en-us/library/dd878284(v=vs.85).aspx

<# 
 .Synopsis
  Provides utilities for use with PowerShell.
#>

function Get-MacOsXsysteminformation {
    # From Stephane's http://powershelldistrict.com/powershell-mac-os-x/
    [xml]$infos = system_profiler -xml
    return $infos
}

Function Touch-File {
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

export-modulemember -function Touch-File 