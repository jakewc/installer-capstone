@echo off
if '%1' == '' goto usage 

set server=-S%COMPUTERNAME%\%3
if '%3' == '' set server=.\%2

if '%2' == '' goto enabler_db


echo running %1.SQL on Instance %server%, creating output in
echo  %ENABLER_LOG%\%1.log 
oSQL.EXE -E -S %server% -d EnablerDB -i %1.sql -o %ENABLER_LOG%\%1.log
notepad %ENABLER_LOG%\%1.log
goto end 

:enabler_db
echo running %1 on EnablerDB, creating output in
echo  %ENABLER_LOG%\%1.log 
oSQL.EXE -E %server% -d EnablerDB -n -i %1.sql -o %ENABLER_LOG%\%1.log
notepad %ENABLER_LOG%\%1.log
goto end

:usage 
echo Usage:
echo  sql70 script-name [instance-name] [server-name]
echo.
echo Notes:
echo - instance-name and server-name are optional
echo - This script can be run by users with database access or in the Administrators group.
echo.

:end 
