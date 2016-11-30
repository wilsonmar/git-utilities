# my_ps_functions.ps1 within https://github.com/wilsonmar/git-utilities
# PowerShell functions custom library to workaround dificiencies.
# for running under PowerShell on Mac or Windows
# by wilsonmar@gmail.com @wilsonmar
# Here are various custom functions
# Sample invocation code:
#    & ((Split-Path $MyInvocation.InvocationName) + "\my_ps_functions.ps1")

# From orad in http://stackoverflow.com/questions/31888580/a-better-way-to-check-if-a-path-exists-or-not-in-powershell
# https://connect.microsoft.com/PowerShell/feedbackdetail/view/1643846/
# Add aliases that should be made available in PowerShell by default:
function not-exist { -not (Test-Path $args) }
Set-Alias !exist not-exist -Option "Constant, AllScope"
Set-Alias exist Test-Path -Option "Constant, AllScope"

# Use this in conditional statements such as:
#    if (exist $path) { ... }
#    and
#    if (not-exist $path)) { ... }
#    if (!exist $path)) { ... }