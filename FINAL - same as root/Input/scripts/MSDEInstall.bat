@echo off
echo -------------------------------------------------------------------------------- >> c:\enabler\install.log
echo Enabler MSDE 2000 Database Install >> c:\enabler\install.log
echo -------------------------------------------------------------------------------- >> c:\enabler\install.log
rem We get two parameters from the Install program:
rem   %1  drive letter of location of MSDE installation
rem   %2  full path to location of MSDE (including drive letter), may contain spaces (and traces of nuts)

if exist c:\enabler\MSDE_INSTALLED_OK attrib c:\enabler\MSDE_INSTALLED_OK
if exist c:\enabler\MSDE_INSTALLED_OK del c:\enabler\MSDE_INSTALLED_OK

if '%2' == '' goto CleanUsage
if not exist "%~2" goto ErrorFilesMissing

echo Installing MSDE >> c:\enabler\install.log

rem the Enabler install puts in a RunOnce to restart the install 
rem before it runs this script, because the setup (below) will
rem reboot the PC in some situations (clean install)

rem go to location of MSDE install
%1
cd %2

rem now actually start the install
start /wait setup.exe /settings msde2000setup.ini /i Sql2000.msi /L*v c:\enabler\msde2000install.log /qb
echo MSDE Setup.EXE Result = %ERRORLEVEL% >> c:\enabler\install.log 2>>&1
if %ERRORLEVEL% == 1641 goto RebootPending
if not %ERRORLEVEL% == 0 goto InstallFailed

rem the Enabler install also removes the RunOnce it added if no
rem reboot occurs (i.e. if this is not a clean MSDE install)

echo installed ok >> c:\enabler\MSDE_INSTALLED_OK

echo MSDE installed >> c:\enabler\install.log
echo Starting MSDE >> c:\enabler\install.log
net start MSSQLServer >> c:\enabler\install.log

rem -----------------------------------------------------------
:OSQLInstalled
goto End

:ErrorFilesMissing
echo Files required for the install are missing from the system >> c:\enabler\install.log
goto End

:CleanUsage
echo ERROR: Location of MSDE not specified >> c:\enabler\install.log 2>>&1
goto End

RebootPending:
echo MSDE should reboot the computer now...
echo reboot pending >> c:\enabler\MSDE_REBOOT_PENDING
goto End

:InstallFailed
echo ERROR: MSDE install failed >> c:\enabler\install.log 2>>&1
goto End

:End
