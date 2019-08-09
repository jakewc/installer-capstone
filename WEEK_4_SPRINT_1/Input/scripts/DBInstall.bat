@echo off
echo -------------------------------------------------------------------------------- >> %3
echo Enabler Database Installation v4.0 >> %3
echo -------------------------------------------------------------------------------- >> %3
rem We expect to get these parameters
rem  %1  EnablerDB folder
rem  %2  Enabler Install folder
rem  %3  install log filename and path (C:\Enabler\install.log)
rem  %4  full path to OSQL
rem  %5  Instance name (if any)

echo  Enabler DB path = %1 >> %3
echo   Enabler folder = %2 >> %3
echo        OSQL Path = %4 >> %3
echo     SQL Instance = %5 >> %3

set inst=%5
rem -- instance parameter exist? prefix -S 
if %inst%s neq s set inst=-S%inst%

cd /D %2
rem this script requires the EnablerDB and log folders to be created 
rem the installer must do this before running this script

rem if we complete the dbinstall ok we create a file - so remove it now if it exists
if exist %2\DBINSTALL_OK attrib %2\DBINSTALL_OK -r
if exist %2\DBINSTALL_OK del %2\DBINSTALL_OK

rem -----------------------------------------------------------
rem -- make sure all the files we require are present
echo Checking for Enabler installation >> %3
if not exist %2\AfterRestore.sql echo Could not find %2\AfterRestore.SQL >> %3
if not exist %2\AfterRestore.sql goto ErrorFilesMissing
if not exist %2\Attach.sql       echo Could not find %2\Attach.SQL >> %3
if not exist %2\Attach.sql       goto ErrorFilesMissing
if not exist %2\AtUtil.exe       echo Could not find %2\AtUtil.EXE >> %3
if not exist %2\AtUtil.exe       goto ErrorFilesMissing
if not exist %2\DBUpgrade.bat    echo Could not find %2\DBUpgrade.BAT >> %3
if not exist %2\DBUpgrade.bat    goto ErrorFilesMissing
if not exist %2\CheckDB.sql      echo Could not find %2\CheckDB.SQL >> %3
if not exist %2\CheckDB.sql      goto ErrorFilesMissing
if not exist %2\Config70.sql     echo Could not find %2\Config70.SQL >> %3
if not exist %2\Config70.sql     goto ErrorFilesMissing
if not exist %2\Enabler.sql      echo Could not find %2\Enabler.SQL >> %3
if not exist %2\Enabler.sql      goto ErrorFilesMissing
if not exist %2\Load.sql         echo Could not find %2\Load.SQL >> %3
if not exist %2\Load.sql         goto ErrorFilesMissing

echo Debug: 1 >> %3
echo Files OK >> %3

rem -----------------------------------------------------------
rem -- is a SQL Server with osql installed?
echo Checking for SQL Server... >> %3

rem If SQL Server was installed by MSDEInstall then OSQL should be
rem in the PATH by now but may not be if the MSDE install didn't do
rem a reboot

rem If SQL Server was installed prior to running Enabler Install then
rem OSQL should be in the PATH by now

rem In either case the Wise installer checks that oSQL.EXE can be
rem found in the path and passes the full location of oSQL.EXE
rem to us as the first parameter


echo Debug: 2 >> %3

set PATH=%PATH%;%4;
echo %PATH% >> %3 2>>&1
echo %inst% >> %3

oSQL.EXE %inst% -U test -P osql >> %3 2>>&1
if %ERRORLEVEL% == 9009 goto ServerNotInstalled
if %ERRORLEVEL% == 1 goto OSQLInstalled

rem -----------------------------------------------------------
:ServerNotInstalled
rem This should NEVER happen since the Enabler Installer checks before running this script
echo ERROR: Database Server not installed. Cannot install Enabler Database >> %3 2>>&1
goto End

rem -----------------------------------------------------------
:OSQLInstalled
echo Found SQL Server OK >> %3 2>>&1



echo Debug: 3 >> %3
rem -----------------------------------------------------------
rem -- is database installed?
echo Checking for Enabler database...  >> %3
oSQL.EXE -d master %inst% -E -n -i checkdb.sql >> %3 2>>&1
echo Return from CheckDB: %ERRORLEVEL% >> %3 2>>&1
if %ERRORLEVEL% == 0 goto NoDatabaseAttached
if %ERRORLEVEL% GTR 0 goto GotDatabase
goto DBError

:NoDatabaseAttached
echo EnablerDB is not attached to SQL Server. checking files... >> %3 2>>&1

if exist c:\enablerdb\EnbData.dat goto AttachOnly
echo EnablerDB files not found >> %3

rem -----------------------------------------------------------
echo Creating EnablerDB Environment... >> %3 2>>&1
del config70.log > NUL 2>>&1
oSQL.EXE -d master %inst% -E -n -i config70.sql >> %3 2>>&1
if ERRORLEVEL 1 goto DBerror

echo Done >> %3

rem -----------------------------------------------------------
:GotDatabase

echo Debug: 4 >> %3
echo Removing old log files >> %3 2>>&1
if exist C:\Enabler\enabler.log del enabler.log
if exist C:\Enabler\load.log del load.log

echo Creating EnablerDB Tables... >> %3 2>>&1
oSQL.EXE %inst% -E -d EnablerDB -n -i enabler.sql >> %3 2>>&1

echo Creating EnablerDB Stored Procedures... >> %3 2>>&1
oSQL.EXE %inst% -E -d EnablerDB -n -i load.sql >> %3 2>>&1

if not exist %2\audittriggers.sql goto NoAuditTriggers:
echo Creating EnablerDB Audit Triggers for PCI-DSS... >> %3 2>>&1
oSQL.EXE %inst% -E -d EnablerDB -n -i audittriggers.sql >> %3 2>>&1
:NoAuditTriggers

if not exist %2\loadenbconfigx.sql goto NoEnbConfigX
echo Applying EnbConfigX Triggers... >> %3 2>>&1
oSQL.EXE %inst% -E -d EnablerDB -n -i loadenbconfigx.sql >> %3 2>>&1

:NoEnbConfigX
echo EnablerDB is now installed >> %3 2>>&1
echo Updating EnablerDB >> %3 2>>&1
CALL DBUpgrade.bat %5
oSQL.EXE %inst% -E -d EnablerDB -n -i AfterRestore.sql >> %3 2>>&1

echo Debug: 5 >> %3
rem -----------------------------------------------------------
echo Start scheduler >> %3 2>>&1
scutil /start schedule >> %3 2>>&1

echo Checking OS version
rem -------------------------------------------------------------------------------
rem ---			version == 6.3	->	Windows 8.1			
rem ---			version == 6.2	->	Windows 8			
rem ---			version == 6.1	->	Windows 7			
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

echo DELETE previously scheduled nightly backup >> %3 2>>&1

if %ISWINDOWS8ABOVE% EQU 0 (
%2\atutil /d \enabler\nightly >> %3 2>>&1
%2\atutil /d \enabler\bin\nightly >> %3 2>>&1
) 
rem --- when using SCHTASKS, we do not remove the existing one, just overwrite it
echo. >> %3 2>>&1

echo ADDING new scheduled task >> %3 2>>&1
if %ISWINDOWS8ABOVE% EQU 0 (
%2\atutil /a "cmd.exe /c %2\nightly.bat" 01:00 >> %3 2>>&1
) else (
schtasks /Create /TN EnablerNightly /SC DAILY /ST 01:00 /TR %2\nightly.bat /F >> %3 2>>&1
)
echo. >> %3 2>>&1

goto DatabaseDone

:AttachOnly
rem The files exists but the database isn't attached to the server.
echo Attaching database >> %3 2>>&1
rem Try the SQL2005 cmdline first
sqlcmd -E %inst% -i Attach.sql >> %3 2>>&1
if ERRORLEVEL 9009 goto AttachOnlyoSQL
if ERRORLEVEL 1 goto DBerror
goto AttachRestore
:AttachOnlyoSQL
oSQL.EXE -d master %inst% -E -n -i Attach.sql >> %3 2>>&1
if ERRORLEVEL 1 goto DBerror
:AttachRestore
rem AfterRestore - restore access rights
oSQL.EXE -d master %inst% -E -n -i AfterRestore.sql >> %3 2>>&1
if ERRORLEVEL 1 goto DBerror
goto GotDatabase

echo Debug: 6 >> %3
:DatabaseDone
rem -----------------------------------------------------------
echo Database Install complete >> %3 2>>&1
echo Database Install complete >> %2\DBINSTALL_OK
goto End

rem -----------------------------------------------------------
:ErrorFilesMissing
echo ERROR: Could not find files required by DBInstall.BAT >> %3 2>>&1
goto End

:DBError
echo ERROR: Could not access the database server >> %3 2>>&1
goto End

:End

echo Debug: 7 >> %3
