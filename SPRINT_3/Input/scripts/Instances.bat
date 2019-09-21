
@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
SET ERRORLEVEL=0
SET NAMES=
SET Checked32Bit=0
set OS=

:CheckOS
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT

:FindNames
If %Checked32Bit%==0 goto ReadNativeRegistry
:: If 32-bit OS, no need to run this (else you get duplicates in list output file)
If %Checked32Bit%==1 IF %OS% NEQ 32BIT goto Read32bitOn64bitRegistry
goto End

:ReadNativeRegistry
Echo Reading native registry
SET Checked32Bit=1
SET Key="HKLM\Software\Microsoft\Microsoft SQL Server"
goto ReadRegistry

:Read32bitOn64bitRegistry
:: Check the 32 bit registry on 64 bit OS as this is where the SQL 2005 instance names end up
Echo Reading 32 bit on 64 bit registry
SET Checked32Bit=2
SET Key="HKLM\Software\Wow6432Node\Microsoft\Microsoft SQL Server"
goto ReadRegistry

:ReadRegistry
ECHO Reading
:: delims is a TAB followed by a space
FOR /F "tokens=3* delims=	 " %%A IN ('2^>nul REG QUERY %Key% /V "InstalledInstances" ^|FIND "InstalledInstances"') DO SET NAMES=%%A
ECHO %NAMES%
ECHO %ERRORLEVEL%
If %ERRORLEVEL% NEQ 0 goto Error

SET THISNAME=

:ReplaceDelim
:: 'FOR /F' treats "\0" as separate delimiters, so need to replace with a single-byte delimiter (ie TAB)"
::SEARCHTEXT="\0"
SET SEARCHTEXT=\0
::REPLACETEXT=<TAB>
SET REPLACETEXT=	

FOR /F %%A IN ("%NAMES%") DO (
  SET string=%%A
  SET modified=!string:%SEARCHTEXT%=%REPLACETEXT%!
  ECHO !modified! 
)
SET NAMES=!modified!
goto StripNames

:StripNames
::Reads off one instance at a time and then strips it from the list of names which are separated by \0
::Win 7 allows you to specify a separator for the REG QUERY so that it doesn't have to be \0 
::but XP does not accept that command
FOR /F  "delims=	" %%A IN ("%NAMES%") DO SET THISNAME=%%A
if "%THISNAME%" EQU "" goto FindNames
ECHO %THISNAME% >> %1
SET NAMES=!NAMES:%THISNAME%=!
SET THISNAME=

goto StripNames

:Error
ECHO "Registry key doesn't exist"

:End
ENDLOCAL
