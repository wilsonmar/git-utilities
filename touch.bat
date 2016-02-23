@echo off

:: Mimics Mac touch command that sets the date/time of a file to the current date/time.
:: Put this file in the Windows PATH
:: Sample call: touch myfile.txt

copy /b %1 +,,

:: The %1 substitutes with myfile.txt.
:: The commas indicate the omission of the Destination parameter.
:: Thanks to http://superuser.com/questions/10426/windows-equivalent-of-the-linux-command-touch/764716
