[Code]
{define variables}

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
  INSTANCE_NAME_NEEDED:=1;
  INSTANCE_NAME_LIST:=0;
  PRE_BACKUP:=0;
  CHECKED:='A';
  SDK_APPS:=0;
  ICONS:='B';
  NOSTART:=0;
  UNATTENDED:=0;
  SLIENT:=0;
  PHASE2:=0;
  FAST_STARTUP:=0;
  BUILTIN_USERS_GROUP:='S-1-5-32-545';
  BUILTIN_ADMINISTRATORS_GROUP:='S-1-5-32-544';
  USAGE:=0;



end;