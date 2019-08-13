[Code]

{define variables}
var
{The default is for none of the apps to be installed without the SDKoption selected}
SDK_OPTIONS:Boolean;

{ Disabling 8.3 will install files with short name:
 https://support.microsoft.com/en-us/kb/121007}
FILE_SYSTEM:String;

{Driver Installation code}
DRIVERCODE:Integer;

{ SQL Server Major Product Number}
SQLVER_MAJOR:String;

{APPTITLE is the application title of the installation}
APPTITLE:String;
SQLTITLE:String;

{GROUP is the variable that holds the Program Files Group that
 shortcuts will be placed on the Windows Start Menu}
GROUP:String;

{DISABLED variable is initialized for backward compatability}
DISABLED:String;

{MAINDIR is the variable that holds the default destination directory}
MAINDIR:String;

{BACKUP is the variable that holds the path that all backup files will
 be copied to when overwritten}
BACKUP:String;

{DOBACKUP determines if a backup will be performed. The possible
 values are A (do backup) or B (do not do backup)}
DOBACKUP:String;

{DBDIR specifies the location of the Enabler database files}
DBDIR:String;

SQLSERVER_STARTED:String;

{SA_PASSWORD stores the SA password (if any)}
SA_PASSWORD:String;

{SQL Named Instance name}
SQL_SERVER:String;

{SQL Named Instance name}
SQL_INSTANCE:String;
CLIENT_SQL_INSTANCE:String;
SQLQUERY:String;
INSTANCE_NAME_NEEDED:Boolean;
INSTANCE_NAME_LIST:Boolean;
CMD_INSTANCE:String;
SQL_INSTANCES:String;

{OSQL_PATH stores the path to OSQL.EXE}
OSQL_PATH:String;

{SERVER_NAME stores the Enabler Server name (used for client installs only)}
SERVER_NAME:String;

{Variable to determine if the BAckup up checkbox option should be shown or not}
PRE_BACKUP:Boolean;

{Initialise Checked variable this stops applications variable resetting
 in the wizard loop}
CHECKED:String;

{Set variables for an SDK build. SDK checked, SDK_APPS if present}
SDK_APPS:Boolean;

{Initialise icons variable. A is desktop icons B is start menu icons}
ICONS:String;

{set variables to start apps or restart computer on finish}
NOSTART:Boolean;
RUNNING:String;
START_MPP:String;
START_PUMP:String;

{Initialise unattended variables}
UNATTENDED:Boolean;
SLIENT:Boolean;
PHASE2:Boolean;

{Initialise fast startup variables}
FAST_STARTUP:Boolean;

{Initialise variables for detecting Adminstrator and User group}
BUILTIN_USERS_GROUP:String;
BUILTIN_ADMINISTRATORS_GROUP:String;

{SHOW_USAGE indicates whether we should display a dialog describing the
 installer command-line usage}
SHOW_USAGE:Boolean;

procedure variableInitialisation ();
begin
  DRIVERCODE:=0;
  APPTITLE:='The Enabler';
  GROUP:='The Enabler';
  DISABLED:='!';
  MAINDIR:='Enabler';
  MAINDIR:='C:\%MAINDIR';       
  BACKUP:='%MAINDIR%\BACKUP';
  DOBACKUP:='B';
  DBDIR:=' C:\EnablerDB';
  INSTANCE_NAME_NEEDED:=True;
  INSTANCE_NAME_LIST:=False;
  PRE_BACKUP:=False;
  CHECKED:='A';
  SDK_APPS:=False;
  ICONS:='B';
  NOSTART:=False;
  UNATTENDED:=False;
  SLIENT:=False;
  PHASE2:=False;
  FAST_STARTUP:=False;
  BUILTIN_USERS_GROUP:='S-1-5-32-545';
  BUILTIN_ADMINISTRATORS_GROUP:='S-1-5-32-544';
  SHOW_USAGE:=False;
end;

{Variable COMPONENTS}
function GetCOMPONENTS():String;
var 
  COMPONENTS:String;  
begin
  COMPONENTS:='';
  if RegValueExists(HKEY_LOCAL_MACHINE,'SOFTWARE\ITL\Enabler','(Default)')then
  begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\ITL\Enabler','(Default)',COMPONENTS)
  end;
  Result:=COMPONENTS;
end;

{Variable APPLICATIONS}
function GetAPPLICATIONS():String;
var 
  APPLICATIONS:String;  
begin
  APPLICATIONS:='';
  if RegValueExists(HKEY_LOCAL_MACHINE,'SOFTWARE\ITL\Enabler','(Default)')then
  begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\ITL\Enabler','(Default)',APPLICATIONS)
  end;
  Result:=APPLICATIONS;
end;

{Variable OPERATING_SYSTEM}
function GetOPERATING_SYSTEM():String;
var 
  OPERATING_SYSTEM:String;  
begin
  OPERATING_SYSTEM:='';
  if RegValueExists(HKLM,'Software\Microsoft\Windows NT\CurrentVersion','CurrentVersion')then
  begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE,'Software\Microsoft\Windows NT\CurrentVersion','CurrentVersion',OPERATING_SYSTEM)
  end;
  Result:=OPERATING_SYSTEM;
end;

{Variable SDK}
function GetSDK():String;
var 
  SDK:String;  
begin
  SDK:='';
  if RegValueExists(HKEY_LOCAL_MACHINE,'SOFTWARE\ITL\Enabler','(Default)')then
  begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\ITL\Enabler','(Default)',SDK)
  end;
  Result:=SDK;
end;

{Variable ENBWEB_DOMAIN}
function GetENBWEB_DOMAIN():String;
var 
  ENBWEB_DOMAIN:String;  
begin
  ENBWEB_DOMAIN:='';
  if RegValueExists(HKEY_LOCAL_MACHINE,'SOFTWARE\ITL\Enabler','(Default)')then
  begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\ITL\Enabler','(Default)',ENBWEB_DOMAIN)
  end;
  Result:=ENBWEB_DOMAIN;
end;

{Variable ENBWEB_PORT}
function GetENBWEB_PORT():String;
var 
  ENBWEB_PORT:String;  
begin
  ENBWEB_PORT:='';
  if RegValueExists(HKEY_LOCAL_MACHINE,'SOFTWARE\ITL\Enabler','(Default)')then
  begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\ITL\Enabler','(Default)',ENBWEB_PORT)
  end;
  Result:=ENBWEB_PORT;
end;

{Variable ENV_COMPUTERNAME}
function GetENV_COMPUTERNAME():String;
var 
  ENV_COMPUTERNAME:String;  
begin
  ENV_COMPUTERNAME:='';
  if RegValueExists(HKEY_LOCAL_MACHINE, 'SYSTEM/CurrentControlSet/Services/EventLog/State', 'LastComputerName')then
  begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM/CurrentControlSet/Services/EventLog/State', 'LastComputerName',ENV_COMPUTERNAME)
  end;
  Result:=ENV_COMPUTERNAME;
end;


{Variable OS,OS_ARCHITECTURE,OS_ARCHITEW6432}
{Variable OS_ARCHITECTURE,OS_ARCHITEW6432}
function GetOS_ARCHITECTURE():String;
var 
  OS_ARCHITECTURE:String;  
begin
  OS_ARCHITECTURE:='';
  if RegValueExists(HKEY_LOCAL_MACHINE, 'SYSTEM/CurrentControlSet/Control/Session Manager/Environment', 'PROCESSOR_ARCHITECTURE')then
  begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM/CurrentControlSet/Control/Session Manager/Environment', 'PROCESSOR_ARCHITECTURE',OS_ARCHITECTURE)
  end;
  Result:=OS_ARCHITECTURE;
end;

function GetOS_ARCHITEW6432():String;
var 
  OS_ARCHITEW6432:String;  
begin
  OS_ARCHITEW6432:='';
  if RegValueExists(HKEY_LOCAL_MACHINE, 'SYSTEM/CurrentControlSet/Control/Session Manager/Environment', 'PROCESSOR_ARCHITECTURE')then
  begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM/CurrentControlSet/Control/Session Manager/Environment', 'PROCESSOR_ARCHITECTURE',OS_ARCHITEW6432)
  end;
  Result:=OS_ARCHITEW6432;
end;

function GetOS():Integer;
var
OS:Integer;
begin
OS:=0;
if GetOS_ARCHITECTURE()='AMD64' then
  begin
    os:=64;
  end;
if GetOS_ARCHITECTURE()='IA64' then
  begin
    OS:=64;
  end;
if GetOS_ARCHITECTURE()='x86' then
  begin
    if GetOS_ARCHITEW6432() = 'AMD64' then
      begin
        OS:=64;
      end
      else
      begin
        OS:=32
      end;
  end;
  Result:=OS
end;