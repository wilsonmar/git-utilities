@echo off
:: From https://github.com/wilsonmar/git-utilities/fake-bash.bat
:: Create macros to emulate Linux/Mac BASH commands:

DOSKEY ls=dir /X
DOSKEY pwd=chdir
DOSKEY ps=tasklist $*
