REM In order to run this Help 2 registration script you must have
REM  all COL_* files and the .hxs file in the same directory as 
REM  this file. Additionally, InnovaHxReg.exe must be in the same
REM  directory or in the system path.
REM
REM For more information on deploying Help 2 files, refer to the 
REM  HelpStudio on-line help file under the 'Deploying the Help 
REM  System' section.

REM Remove the plug in to the Visual Studio.NET 2008 help system
REM InnovaHxReg /U /P /productnamespace:MS.VSIPCC.v90 /producthxt:_DEFAULT /namespace:ITL /hxt:_DEFAULT

REM Remove the plug in to the Visual Studio.NET 2005 help system
REM InnovaHxReg /U /P /productnamespace:MS.VSIPCC.v80 /producthxt:_DEFAULT /namespace:ITL /hxt:_DEFAULT

REM Remove the plug in to the Visual Studio.NET 2003 help system
REM InnovaHxReg /U /P /productnamespace:MS.VSCC.2003 /producthxt:_DEFAULT /namespace:ITL /hxt:_DEFAULT

REM Remove the plug in to the Visual Studio.NET 2002 help system
REM InnovaHxReg /U /P /productnamespace:MS.VSCC /producthxt:_DEFAULT /namespace:ITL /hxt:_DEFAULT

REM Un-Register the help file (title in Help 2.0 terminology)
InnovaHxReg /U /T /namespace:ITL /id:EnablerSDKRef /langid:1033 /helpfile:"EnablerSDKRef.hxs"

REM Un-Register the Namespace
InnovaHxReg /U /N /Namespace:ITL /Description:"The Enabler SDK Reference " /Collection:COL_EnablerSDKRef.hxc
