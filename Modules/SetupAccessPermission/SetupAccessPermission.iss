[Files]

[Code]
var LOGTIME: String;

Exec('net.exe', 'localgroup /add EnablerAdministrators', '', SW_SHOW, ewWaitUntilTerminated, Result);
if SILENT = '0' then begin
  MsgBox('The Enabler', mbinformation, mb_OK);
End
Exec(ExpandConstant('{app}\CreateRegKeyEvent.bat'), '', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', '/subdirectories=directoriesonly ' + ExpandConstant('{app}')+'\log /grant='+ BUILTIN_USERS_GROUP+ '=CRWD /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', '/subdirectories=filesonly ' + ExpandConstant('{app}')+'\log\*.* /grant='+ BUILTIN_USERS_GROUP+ '=CRWD /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);

LOGTIME := GetDateTimeString('dd/mm/yyyy hh:nn:ss', '-', ':');
Log(Format('Start of setting permissions %s', [LOGTIME]));

if COMPONENTS = 'B' then begin
  Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', '/file ' + ExpandConstant('{app}')+'\enbkick.exe /grant='+ BUILTIN_USERS_GROUP+ '= /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
  Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', '/file ' + ExpandConstant('{app}')+'\vsql.exe /grant='+ BUILTIN_USERS_GROUP+ '= /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
  Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', '/file ' + ExpandConstant('{app}')+'\fcman.exe /grant='+ BUILTIN_USERS_GROUP+ '= /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
  Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', '/file ' + OSQL_PATH +' /grant='+ BUILTIN_USERS_GROUP+ '= /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
  Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', '/file ' + OSQL_PATH +' /grant=EnablerAdministrators=F /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
  Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', '/service psrvr4 /grant=EnablerAdministrators=F /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
End;

Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', ' /file'+SYS32+'\eventvwr.msc /grant='+BUILTIN_USERS_GROUP+'= /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', ' /file'+SYS32+'\config\Enabler.evt /grant='+BUILTIN_USERS_GROUP+'= /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', ' /subdirectories=directoriesonly '+ExpandConstant('{app}')+'\log /grant=EnablerAdministrators=F /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', ' /subdirectories=directoriesonly '+ExpandConstant('{app}')+'\log\*.* /grant=EnablerAdministrators=F /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);

Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', ' /subdirectories=directoriesonly '+ExpandConstant('{app}')+'\ /grant=EnablerAdministrators=F', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', ' /file'+ExpandConstant('{app}')+' /grant=EnablerAdministrators=F', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);

Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', '/subdirectories=filesonly'+ExpandConstant('{app}')+'\*.* /grant=EnablerAdministrators=F /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', '/file'+SYS32+'%\eventvwr.msc /grant=EnablerAdministrators=E /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', '/file'+SYS32+'\config\Enabler.evt /grant=EnablerAdministrators=F /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);

var LOGTIME2:String;
LOGTIME2 := GetDateTimeString('dd/mm/yyyy hh:nn:ss', '-', ':');
Log(Format('End of setting permissions %s', [LOGTIME2]));

if SILENT = '0' then Begin
  MsgBox('The Enabler', mbinformation, mb_OK);
End;

if COMPONENTS = 'B' then Begin
  Log('Installing or Updating EnablerDB');
  if SILENT = '0' then Begin
    MsgBox('The Enabler', mbinformation, mb_OK);
  End;
  Exec(ExpandConstant('{app}') + '\bin\psrvr4.exe', '/servuce', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
  Exec(ExpandConstant('{app}') + '\bin\enbweb.exe', '/install', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
  Log('Update Services Start timout setting');
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control','WaitToKillServiceTimeout','180000');
  if SILENT = '0' then Begin
    MsgBox(' ', mbinformation, mb_OK);
  End;