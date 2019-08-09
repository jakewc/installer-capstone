@echo off
echo Enabler Database Backup started
rem Clear ERRORLEVEL first!
set ERRORLEVEL=
set NIGHTLY70ERROR=

echo Checking OS version
rem -------------------------------------------------------------------------------
rem ---			version == 10.0 -> Windows 10 / Windows Server 2016
rem ---			version == 6.3	->	Windows 8.1 / Windows Server 2012R2			
rem ---			version == 6.2	->	Windows 8 / Windows Server 2012			
rem ---			version == 6.1	->	Windows 7 /	Windows Server 2008 R2		
rem ---	For Windows 8 and above, the AT command is deprecated, should use SCHTASKS instead			
rem ---	SCHTASKS uses 24 hour format which means 1:00 is an invalid command 		
rem ---	MUST use 01:00 instead			
rem --- Minimum supported version for SCHTASKS is Windows XP/Windows	Server 2003			
rem -------------------------------------------------------------------------------

for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j

SET ISWINDOWS8ABOVE=0

if "%VERSION%" == "10.0" GOTO Windows8Above
if "%VERSION%" == "6.3" GOTO Windows8Above
if "%VERSION%" == "6.2" GOTO Windows8Above
GOTO FinishCheck

:Windows8Above
SET ISWINDOWS8ABOVE=1
GOTO FinishCheck

:FinishCheck
if %ISWINDOWS8ABOVE%==1 (
echo Windows 8 above
) else (
echo Windows 8 below
)

if NOT '%1' == '' goto User_Specified_Instance
if '%ENABLER_DB_INSTANCE_NAME%'=='' GOTO Default_Instance

:Named_Instance
set SERVER=-S .\%ENABLER_DB_INSTANCE_NAME%
echo INFO: Backup named instance %ENABLER_DB_INSTANCE_NAME%
goto Read_Variables

:Default_Instance
set SERVER=
echo INFO: Backup default instance
goto Read_Variables

:User_Specified_Instance
set SERVER=-S %1
echo INFO: Backup instance %1

:Read_Variables
if '%ENABLER_ROOT%'=='' echo INFO: Enabler environment variables not set (using defaults)
if '%ENABLER_ROOT%'=='' set ENABLER_ROOT=C:\Enabler
if '%ENABLER_LOG%'=='' set ENABLER_LOG=C:\Enabler\log
if '%ENABLER_BIN%'=='' set ENABLER_BIN=C:\Enabler\bin
if '%ENABLER_DB%'=='' set ENABLER_DB=C:\EnablerDB

rem @echo on
cd %ENABLER_ROOT%
oSQL.EXE -E -d EnablerDB %SERVER% -i %ENABLER_ROOT%\nightly.sql -o %ENABLER_LOG%\nightly.log -b
set backupError=%ERRORLEVEL%

@echo off
if %ERRORLEVEL% NEQ 0 goto errors
echo Backup Completed Successfully
echo %date:~4,10% %time:~0,8% Backup Completed Successfully >> %ENABLER_LOG%\nightly.log

if exist %ENABLER_ROOT%\nightly.log del %ENABLER_ROOT%\nightly.log

rem -------------------------------------------------------------------------------------
rem -- Because the backup worked we will remove any scheduled tasks that may have been
rem -- set up because of a previous failure and set up the standard 01:00 nightly job
rem -------------------------------------------------------------------------------------

rem -- Get the Hour that the scheduled task normally runs Nightly70 batch file (defaults to 01)
rem -- redirect to temp file with no count, no headers, get from file, trim % assign to variable, delete temp file
rem -- If the temp file contains an error message TaskTime will be set to hour 0 (midnight)
SET TaskTimeHr=1 
SET TaskTimeMin=00
oSQL.EXE -E -d EnablerDB %SERVER% -Q "SET NOCOUNT ON; SELECT datepart("hh",Backup_Time),datepart("mi",Backup_Time) FROM global_settings" -h-1 -b > %ENABLER_LOG%\res_time_tmp.txt
if %ERRORLEVEL% NEQ 0 goto AfterGetTime

FOR /F "tokens=1,2*" %%m IN (%ENABLER_LOG%\res_time_tmp.txt) do (
SET TaskTimeHr=%%m
SET TaskTimeMin=%%n
)
del %ENABLER_LOG%\res_time_tmp.txt
if %TaskTimeMin% LSS 10 SET TaskTimeMin=0%TaskTimeMin%
if "%TaskTimeHr%" LSS 10 SET TaskTimeHr=0%TaskTimeHr%

:AfterGetTime
echo The Backup TaskTime is %TaskTimeHr%:%TaskTimeMin%

if %ISWINDOWS8ABOVE% EQU 0 (
atutil /d %ENABLER_ROOT%\nightly.bat
at %TaskTimeHr%:%TaskTimeMin% /every:M,T,W,Th,F,S,Su cmd.exe /c %ENABLER_ROOT%\nightly.bat %1
) else (
schtasks /Create /TN EnablerNightly /SC DAILY /ST %TaskTimeHr%:%TaskTimeMin% /TR %ENABLER_ROOT%\nightly.bat %1 /F
)

rem -------------------------------------------------------------------------------------
rem -- Delete old dump files other than the n newest (n is determined by database setting)
rem -------------------------------------------------------------------------------------
rem -- Backup_Files is the number of archives we want to keep
rem -- NOTE:   The 'Backup_Files' column not being present can cause a 1 to be returned, in
rem -- which case we should maintain the status quo by deleting all archives other than the 
rem -- newest;  this is OK, because we are only deleting files that match the filename mask.

rem -- get a file count of DMP files in %ENABLER_DB% folder
set FileCounter=0
for %%a in (%ENABLER_DB%\Enabler_*.dmp) do (
       call set /a FileCounter=%%FileCounter%%+1
)

rem -- redirect to temp file with no count or headers, retrieve from file, trim & assign to variable
oSQL.EXE -E -d EnablerDB %server% -Q "SET NOCOUNT ON; SELECT Backup_Files FROM Global_Settings" -h-1 -b > %ENABLER_LOG%\res_files_tmp.txt
if %ERRORLEVEL% NEQ 0 goto AfterGetArchiveSetSize

set /P ArchiveSetSize= < %ENABLER_LOG%\res_files_tmp.txt
for /f %%m IN ('echo %ArchiveSetSize%') do set /A ArchiveSetSize=%%m
del %ENABLER_LOG%\res_files_tmp.txt

:AfterGetArchiveSetSize
rem -- if ArchiveSetSize is negative or zero change to 1
if %ArchiveSetSize:~0,1%==- set ArchiveSetSize=1
if %ArchiveSetSize%==0 set ArchiveSetSize=1
echo Found %FileCounter% DMP files in %ENABLER_DB%, required archive set size is %ArchiveSetSize%

rem -- get a list of the files in date order (oldest to newest)
rem -- EnableDelayedExpansion is used to allow variables to update instantly

if %FileCounter%==0 goto AfterDeletions
SetLocal EnableDelayedExpansion
set z=%FileCounter%

for %%a in (%ENABLER_DB%\Enabler_*.dmp) do (
	rem echo ArchiveSetSize=!ArchiveSetSize!
	if !z! GTR !ArchiveSetSize! (
		echo deleting %%a 
		del "%%a"
		call set /a z=!!z!!-1 
	)
)	

:AfterDeletions

goto done

:errors

set NIGHTLY70ERROR=1

echo.
echo *************** WARNING! The Backup Failed! ******************
echo.
echo Please re-run Nightly.bat to ensure a backup file is created
echo refer to Nightly.log for more information about the errors.
echo.
echo **************************************************************
echo.

rem  -- Log error to nightly.log --  
echo %date:~4,10% Nightly.bat > %ENABLER_LOG%\nightly.log
echo %time:~0,8% - Backup Failed ErrorLevel: %backupError% >> %ENABLER_LOG%\nightly.log
if %backupError% NEQ 9009 goto osqlOK 
echo %time:~0,8% - osql.exe not found in PATH >> %ENABLER_LOG%\nightly.log
:osqlOK
echo %time:~0,8% - Removing existing backup schedule >> %ENABLER_LOG%\nightly.log

rem -------------------------------------------------------------------------------------
rem Remove existing backup task (because we know it failed) and replace with a new one
rem -------------------------------------------------------------------------------------
atutil /d %ENABLER_ROOT%\nightly

set hr=%TIME:~0,2%
echo DEBUG: Current Hour is %hr%
rem increment the hour to use for the new scheduled task
call set /a hr=hr+1 
if %hr%==24 set hr=0
if %hr% LSS 10 SET hr=0%hr%

echo DEBUG: New Hour is %hr%
echo Rescheduling backup task for %hr%:00

if %ISWINDOWS8ABOVE% EQU 0 (
at %hr%:00 /every:M,T,W,Th,F,S,Su cmd.exe /c %ENABLER_ROOT%\nightly.bat %1
) else (
schtasks /Create /TN EnablerNightly /SC DAILY /ST %hr%:00 /TR %ENABLER_ROOT%\nightly.bat %1 /F
)

echo %time:~0,8% - Adding next scheduled retry of backup at %hr%:00 >> %ENABLER_LOG%\nightly.log

:done
rem exit and set error level to 0 or 1 depending on how NIGHT70ERROR was set
cmd /C exit %NIGHTLY70ERROR%
rem Script Completed
