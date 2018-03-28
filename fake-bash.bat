@echo off
:: From https://github.com/wilsonmar/git-utilities/fake-bash.bat
:: Create macros to emulate Linux/Mac BASH commands:

DOSKEY ls=dir /X
DOSKEY pwd=chdir
DOSKEY ps=tasklist $*
DOSKEY cat=type $1 | more

:: If Sublime Text editor has been installed:
set PATH=%PATH%;"C:\Program Files\Sublime Text 2\"
DOSKEY subl=sublime_text $*
