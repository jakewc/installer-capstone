rem - --------------------------------------------------------------------
rem - This batch file handles installation of SQL2005/2008R2/2012/2014/2016 SQL servers
rem - --------------------------------------------------------------------

@echo off
echo -------------------------------------------------------------------------------- >> c:\enabler\install.log
echo Enabler SQL Server Express Installation >> c:\enabler\install.log
echo -------------------------------------------------------------------------------- >> c:\enabler\install.log
rem We get two parameters from the Install program:
rem   %1  drive letter of location of SQLServerExpress installation
rem   %2  full path to location of SQLServerExpress (including drive letter), may contain spaces
rem   %3  sa password from installer (case-sensitive)
rem   %4  sys admin user account 
rem   %5  SQL2012/SQL2014/SQL2016 string to indicate is SQL version being installed

rem Errors returned to Wise installer
SET /A "ERRORNO_NO_ERROR"=0
SET /A "ERRORNO_PASSWORD_NOT_STRONG"=1
SET /A "ERRORNO_REBOOT_REQUIRED"=2
SET /A "ERRORNO_UPDATES_REQUIRED"=3
SET /A "ERRORNO_FAILED"=4


SET /A "ERRORNO=%ERRORNO_NO_ERROR%"
SET /A "ERRORCODE=0"

rem If the 4th parameter is missing we know it's a SQL2005 install,
rem no 5th parameter is SQL2008R2 otherwise it is SQL2012/SQL2014/SQL1016 install
if '%2' == '' goto CleanUsage
if '%3' == '' goto CleanUsage
if not exist "%~2" echo Could not find %2
if not exist "%~2" goto ErrorFilesMissing


:InstallSQLServerExpress

rem The Enabler install puts in a RunOnce to restart the install 
rem before it runs this script, because the setup  (below)  will
rem reboot the PC in some situations (clean install).

rem SQLEXPRESS (5th parameter) is given the echo message is different 
rem If a SysAdminAccount parameter is given we'll install 2008, otherwise
rem we'll install 2005  - in either case the code resumes at AfterInstall.

if '%4' == '' goto OptionInstallSQL2005

rem --------------------- only difference is the echo message and log

rem -------------------- SQL SERVER 2008, 2012, 2014, 2016 ----------------------------------
rem :OptionInstallSQL2008R2_201X

rem go to location of SQLServerExpress install
%1
cd %2
rem SQL2008R2/201X includes drive, path and '\'

rem ------------------- same parameters for SQL2008R2/201X
SQLEXPR.EXE /INSTANCEID="MSSQLSERVER" /ACTION="Install" /FEATURES=SQLENGINE,Conn /Q /HIDECONSOLE /TCPENABLED="1" /INSTANCENAME="MSSQLSERVER" /AGTSVCSTARTUPTYPE="Automatic" /ISSVCSTARTUPTYPE="Automatic" /ISSVCACCOUNT="NT AUTHORITY\NetworkService" /ASSVCSTARTUPTYPE="Automatic" /SQLSVCSTARTUPTYPE="Automatic" /SQLSVCACCOUNT="NT AUTHORITY\SYSTEM" /SQLSYSADMINACCOUNTS=%4 /SECURITYMODE="SQL" /SAPWD=%3 /IACCEPTSQLSERVERLICENSETERMS

rem ------------------------------------------------------------
:AfterInstall

set SETUPERROR=%ERRORLEVEL% 
goto PARSE_RETURNED_INSTALL_ERRORS


rem -------------------- SQL SERVER 2005 ----------------------------------------

:OptionInstallSQL2005

rem go to location of SQLServer install
%1
cd %2
rem SQL2005 includes drive, path and '\'
rem set SQL2005PATH=%~dp2

echo Installing SQLServer2005 Express >> c:\enabler\install.log
start /wait SQLEXPR.EXE DISABLENETWORKPROTOCOLS=0 ADDLOCAL=SQL_Engine,Connectivity INSTANCENAME=MSSQLSERVER SECURITYMODE=SQL SAPWD=%3 /qb

goto AfterInstall

rem ------------------------------------------------------------

:ErrorFilesMissing
echo Files required for the install are missing from the system >> c:\enabler\install.log
goto End

:CleanUsage
echo Required Parameters
echo  %1 Drive letter of database install
echo  %2 Full path to database install (including drive letter)
echo  %3 SA password (case sensitive)
echo ERROR: Location of SQL2005/2008R2/201X not specified >> c:\enabler\install.log 2>>&1
goto End


Rem SQL Server install problems that you can get :-
Rem Error  0 - OK
Rem Error  0x0013 ( 19 ), Password not strong enough
Rem Error  0x0261 ( 609 ) (-2067922335) Updates required, missing hotfix
Rem Error  0x0669 (1641), Reboot required
Rem Error  0x0BC2 (3010), Reboot required
Rem Error  0x4005 (16389) Previous install requires a reboot( i.e .Net 3.5 ) before SQl server install can run
:PARSE_RETURNED_INSTALL_ERRORS

rem Mask off top part of error code(facility code)
SET /A "ERRORCODE = %SETUPERROR% & 0xffff"

echo SQLServer %5 Express SQLEXPR.EXE Result = %SETUPERROR% (%ERRORCODE%) >> c:\enabler\install.log 2>>&1

SET "SQL_VERSION=%5"
if X%SQL_VERSION% == X (
 SET "SQL_VERSION=SQL2008"
)   

if %ERRORCODE% == 0 (
  echo INFO: SQLServer %5 installed successfully >> c:\enabler\install.log 2>>&1
  goto NO_ERROR
)
if %ERRORCODE% == 19 (
  echo ERROR: SQLServer %5 install failed, password not strong enough >> c:\enabler\install.log 2>>&1
  goto ERROR_PASSWORD
)
if %ERRORCODE% == 609 (
  echo ERROR: SQLServer %5  install failed, Updates required, missing hotfix >> c:\enabler\install.log 2>>&1
  goto ERROR_UPDATES_REQUIRED
)
if %ERRORCODE% == 1641 (
  echo ERROR: SQLServer %5  install successful, Reboot required >> c:\enabler\install.log 2>>&1
  goto ERROR_REBOOT
)
if %ERRORCODE% == 3010 (
  echo ERROR: SQLServer %5  install successful, Reboot required >> c:\enabler\install.log 2>>&1
  goto ERROR_REBOOT
)
 
goto ERROR_FAILED

:NO_ERROR
SET ERRORNO=%ERRORNO_NO_ERROR%
goto End
:ERROR_PASSWORD
SET ERRORNO=%ERRORNO_PASSWORD_NOT_STRONG%
goto End
:ERROR_REBOOT
SET ERRORNO=%ERRORNO_REBOOT_REQUIRED%
goto End
:ERROR_UPDATES_REQUIRED
SET ERRORNO=%ERRORNO_UPDATES_REQUIRED%
goto End
:ERROR_FAILED
SET ERRORNO=%ERRORNO_FAILED%
goto End

:End

EXIT /B %ERRORNO%

