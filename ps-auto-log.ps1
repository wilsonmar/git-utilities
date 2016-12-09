# ps-auto-log.ps1
# by wilsonmar@gmail.com
# Based on http://mctexpert.blogspot.com/2012/10/automatically-create-log-of-your.html 
# To run on Mac:
#    chmod +x ps-auto-log.ps1
#    ./ps-auto-log.ps1
#
# Create a filename based on a ISO 8601 time stamp:
$Filename = `
    ((Get-date).Year).ToString()+"-"+`
    ((Get-date).Month).ToString("00")+"-"+`
    ((Get-date).Day).ToString("00")+"T"+`
    ((Get-date).Hour).ToString("00")+"-"+`
    ((Get-date).Minute).ToString("00")+"-"+`
    ((Get-date).Second).ToString("00")+"-local.txt"
    # 12-9-2016-8-39-6.txt TODO: Add timezone.
    # echo $Filename

# Set the storage path to a folder in $HOME/Documents:
    if( "$IsWindows" -eq $True ) {
      $Path = "C:\Users\$USER\Documents\PowerShell\Transcript"
    }else{ # Mac / Linux:
      $Path = "~/Documents/PowerShell/Transcript"
    }

# Turn on PowerShell transcripting:
Start-Transcript -Path "$Path\$Filename"
   # Sample output from command:
   # Transcript started, output file is ~/Documents/PowerShell/Transcript\2016-12-09T08-48-45-local.txt