@echo off
echo -------------------------------------------------------------------------------- >> c:\enabler\install.log 2>>&1
echo Enabler Database Update  >> c:\enabler\install.log 2>>&1
echo -------------------------------------------------------------------------------- >> c:\enabler\install.log 2>>&1


if not exist c:\enabler\mkupgrade.sql  echo Could not find MkUpgrade.sql >> c:\enabler\install.log 2>>&1
if not exist c:\enabler\mkupgrade.sql  goto ErrorMissingFiles

if not exist c:\enabler\populate.sql   echo Could not find Populate.sql >> c:\enabler\install.log 2>>&1
if not exist c:\enabler\populate.sql   goto ErrorMissingFiles

if not exist c:\enabler\DefaultData.sql echo Could not find DefaultData.sql >> c:\enabler\install.log 2>>&1
if not exist c:\enabler\DefaultData.sql goto ErrorMissingFiles

echo Preparing for upgrade >> c:\enabler\install.log 2>>&1
oSQL.EXE -E -S %1 -d EnablerDB -n -i mkupgrade.sql -o autoupgrade.bat

echo Updating EnablerDB... >> c:\enabler\install.log 2>>&1
call c:\enabler\autoupgrade.bat %1 >> c:\enabler\install.log


echo EnablerDB Upgrade complete >> c:\enabler\install.log 2>>&1
goto End

:ErrorMissingFiles
echo ERROR: Could not find some files required by DBUpgrade.BAT >> c:\enabler\install.log 2>>&1

:End
