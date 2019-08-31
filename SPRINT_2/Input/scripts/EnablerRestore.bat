@rem --- Enabler Restore ---
@echo off
rem Clear ERRORLEVEL first!
set ERRORLEVEL=
set ENABLERRESTORE=0

rem set the newest *.dmp file in c:\enablerdb as backupfile
for /f %%a IN ('dir /b /O:-D %ENABLER_DB%\*.dmp') do (
	set backupfile=%ENABLER_DB%\%%a
	goto ShowMessage
	)
)
set ENABLERRESTORE=%ERRORLEVEL%
if %ERRORLEVEL% NEQ 0 goto errors

:ShowMessage
echo.
echo Enabler Database Restore
echo.
echo !!! WARNING !!!
echo.
echo This script can only be run by a user in the Administrators group.
echo You are about to restore the Enabler database from:
echo   %backupfile%
echo The restore process will overwrite data The Enabler database.
echo.
echo Close all applications on this computer (or other connected clients)
echo that access The Enabler database before continuing.
echo.
echo Press Ctrl+C to cancel.
echo Press Enter to continue.
echo.
pause

if '%ENABLER_DB_INSTANCE_NAME%'=='' GOTO Default_Instance

:Named_Instance
set SERVER_NAME=-S .\%ENABLER_DB_INSTANCE_NAME%
echo INFO: Restoring to named instance %ENABLER_DB_INSTANCE_NAME%
goto Check_Backup

:Default_Instance
set SERVER_NAME=
echo INFO: Restoring to default instance
goto Check_Backup

:Check_Backup
if exist %backupfile% goto BackupExists
echo ERROR: backup file does not exist (%backupfile%)
set ENABLERRESTORE=1
goto End

:BackupExists

if not exist %ENABLER_ROOT%\scutil.exe goto NoSCUtilStop
rem Stop services that may be using the database
echo Stopping services...
%ENABLER_ROOT%\scutil /stop psrvr
%ENABLER_ROOT%\scutil /stop enbweb
goto Restore

:NoSCUtilStop
rem No SCUtil
net stop psrvr
net stop enbweb

:Restore
rem Restore the database from standard location. 
rem Note we start in Master since we cannot be using EnablerDB while restoring it
echo Restoring database from %BackupFile%...
osql -E -d master %SERVER_NAME% -Q "restore database enablerdb from disk='%backupfile%' with replace" -o %ENABLER_LOG%\EnablerRestore.log -b
set ENABLERRESTORE=%ERRORLEVEL%
if %ERRORLEVEL% NEQ 0 goto errors 

if not exist AfterRestore.sql goto NoAfterRestore
rem Re-apply access permissions
echo Re-applying access permissions...
osql -E -d enablerdb %SERVER_NAME% -i AfterRestore.sql -o %ENABLER_LOG%\AfterRestore.log -b
set ENABLERRESTORE=%ERRORLEVEL%
if %ERRORLEVEL% NEQ 0 goto errors

goto NoAfterRestore

:errors
echo.
echo *** WARNING! Could not complete the database restore ****
echo.
echo Refer to EnablerRestore.log and AfterRestore.log for more 
echo information about the errors. These logs are located in:
echo  %ENABLER_LOG%
echo.
echo *********************************************************
echo.

:NoAfterRestore

rem Restart services
if not exist %ENABLER_ROOT%\scutil.exe goto NoSCUtilStart

echo Restarting services...
%ENABLER_ROOT%\scutil /start psrvr
%ENABLER_ROOT%\scutil /start enbweb
goto end

:NoSCUtilStart
net start psrvr
net start enbweb

:end
echo.
echo Restore Done!

rem return ENABLERRESTORE as ERRORLEVEL. Needed since scutil /start resets ERRORLEVEL
cmd /C exit %ENABLERRESTORE%
