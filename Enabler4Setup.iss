;===================================
; EnablerSetup return codes:
;===================================

; 0 - Successful
; 1 - Parameter error
; 2 - new IE/new MDAC required
; 3 - UNC(network) Install error
; 4 - No Database Server/MSI/.NET components to install. (Can't add Start menu items)
; 5 - SA Password error
; 6 - MSDE/MSI requires reboot
; 7 - MSDE/MSI/.NET installation error
; 8 - OSQL not working after install. Reboot required.
; 9 - DBInstall.bat error
; 10 - Upgrade error
; 11 - SQL Server not running
; 12 - Windows OS not supported
; 13 - UNUSED (was Device Driver Installation Failure)
; 14 - UNUSED (was The Driver requires a restart to complete installation)
; 15 - UNUSED (was The Device wasn't present after driver installation)
; 16 - UNUSED (was File copy error)
; 17 - Not admin
; 18 - SQL Version not compatible
; 19 - SQL Named Instance incorrect
; 20 - not enough disk space
; 21 - C: drive compressed
; 22 - Installation of VC runtime failed
; 23 - .NET 3.5 required but cannot be installed automatically (Windows Server 2008 only)
; 24 - Enabler API install failed
; 25 - 8dot3Name disabled 
 
; This variable forces applications to be installed even if the SDK options is not avaliable or selected
; By including a letter in a varaible that application will be installed
; Even if the SDK options is not avaliable or ticked
; See the variable near the bottom to change what applications are installed when SDK is checked
; A - MMPSim
; B - Pumpdemo
; C - Documents (This includes all SDK documents)
; D - Sample Apps (All sample apps are copied across)
; F - ITLMPPSim.dll

[Setup]
AppName=Enabler4
AppVersion=4.6.3.6087
WizardStyle=modern
AppId={{95EC957B-DB36-4EDD-9C7C-B19F896CC37D}
AppPublisher=Integration Technologies Limited
AppPublisherURL=https://integration.co.nz/
DefaultDirName={commonpf}\Enabler4
OutputBaseFilename=Enabler4Setup
SetupLogging=yes
DisableWelcomePage=no

[Types]
Name: "Client"; Description: "Client"
Name: "Server"; Description: "Server"

;I'M NOT SURE WHERE THESE FILES CAME FROM:
;ITL.Enabler.API.dll
;ITL.Enabler.API.TLB

[Files]
;=========================
; install Third-Party DLLs
;=========================
Source: "{#SourcePath}\Input\Extra\comdlg32.ocx"; DestDir: "{app}";
Source: "{#SourcePath}\Input\Extra\comct232.ocx"; DestDir: "{app}";
Source: "{#SourcePath}\Input\Extra\comctl32.ocx"; DestDir: "{app}";
Source: "{#SourcePath}\Input\Extra\Mscomm32.ocx"; DestDir: "{app}";
Source: "{#SourcePath}\Input\Extra\Msflxgrd.ocx"; DestDir: "{app}";
Source: "{#SourcePath}\Input\Extra\Msrdc20.ocx"; DestDir: "{app}";
Source: "{#SourcePath}\Input\Extra\Msrdo20.dll"; DestDir: "{app}";
Source: "{#SourcePath}\Input\Extra\Msvcp60.dll"; DestDir: "{app}";

//===============
//Enabler Files
//===============
Source:"{#SourcePath}\Input\bin\scutil.exe";DestDir: "{app}"; Check: IsInstallType('B');

;==================
; Security components
;==================
Source: "{#SourcePath}\Input\EnbSecurityController.exe"; DestDir: "{app}"; Flags: skipifsourcedoesntexist;
Source: "{#SourcePath}\Input\SecurityModule.dll"; DestDir: "{app}"; Flags: skipifsourcedoesntexist;
Source: "{#SourcePath}\Input\AuditTrail.dll"; DestDir: "{app}"; Flags: skipifsourcedoesntexist;
Source: "{#SourcePath}\Input\itl.ico"; DestDir: "{app}";

//====================
//create beta license - uses function createLicense();
//====================
Source: "{#SourcePath}\Input\ConvertV4BetaLicense.exe"; DestDir: "{app}";

//=================
//API Assemblies
//=================
//commented out in Wise script but included for posterity
//Source: "{#SourcePath}\Input\API\ActiveX\EnbSessionX.ocx"; DestDir: "{app}";
//Source: "{#SourcePath}\Input\EnbOPTX.ocx"; DestDir: "{app}";
//Source: "{#SourcePath}\Input\API\ActiveX\EnbAttendantX.ocx"; DestDir: "{app}";
//Source: "{#SourcePath}\Input\API\ActiveX\EnbPumpX.ocx"; DestDir: "{app}";

//Only include ActiveX2 controls if they're in the source directory (this wasn't actually the case in the Wise script, they just get installed with no checks)
Source: "{#SourcePath}\Input\API\ActiveX\EnbSessionX2.ocx"; DestDir: "{app}";
Source: "{#SourcePath}\Input\EnablerSoundEvents.reg"; DestDir: "{app}";
Source: "{#SourcePath}\Input\API\ActiveX\EnbAttendantX2.ocx"; DestDir: "{app}";
Source: "{#SourcePath}\Input\API\ActiveX\EnbPumpX2.ocx"; DestDir: "{app}";
//include EnbConfigX if available - this one DOES get checked
Source: "{#SourcePath}\Input\API\ActiveX\EnbConfigX.ocx"; DestDir: "{app}"; Flags: skipifsourcedoesntexist;

//java assemblies
Source: "{#SourcePath}\Input\Extra\joda-time-LICENSE.txt"; DestDir: "{app}";
Source: "{#SourcePath}\Input\Extra\joda-time-NOTICE.txt"; DestDir: "{app}";
Source: "{#SourcePath}\Input\API\Java\enabler-api-1.0.jar"; DestDir: "{app}";
Source: "{#SourcePath}\Input\Extra\joda-time-2.0.jar"; DestDir: "{app}";

//Enabler 4 .NET API assembly self installing package
//TODO PRESENT IN OLD WISE SCRIPT - 'update this MSI to install to different location'

Source: "{#SourcePath}\Input\API\NET\InstallEnablerApi.msi"; DestDir: "{app}"; 

//TODO - perform all checks and executions for .msi file

//Enabler 2 WPF Controls for .NET API
Source: "{#SourcePath}\Input\API\NET\ITL.Enabler.WPFControls.dll"; DestDir: "{app}";
Source: "{#SourcePath}\Input\API\NET\System.Windows.Controls.DataVisualization.Toolkit.dll"; DestDir: "{app}";
Source: "{#SourcePath}\Input\API\NET\WPFToolkit.dll"; DestDir: "{app}";

//===================
//startup processing
//===================
Source: "{#SourcePath}\Input\IsAdmin.exe"; DestDir:"{tmp}";
//Install autosupport early on so that if an error occurs customers can use it
Source: "{#SourcePath}\Input\AutoSupport.exe"; DestDir:"{app}";
//copy readme and release notes files into TEMP folder
Source: "{#SourcePath}\Input\release.txt"; DestDir:"{tmp}" ;

//===================
//setup environment variables
//====================
Source: "{#SourcePath}\Input\bin\setx64.exe"; DestDir: "{app}\bin"; Check: IsOS(64);
Source: "{#SourcePath}\Input\bin\setx32.exe"; DestDir: "{app}\bin"; Check: IsOS(32);
Source: "{#SourcePath}\Input\Extra\ATL.dll"; DestDir: "{app}"; Check: IsWindowsVersion(5);
Source: "{#SourcePath}\Input\Extra\mfc42.dll"; DestDir: "{app}"; Check: IsWindowsVersion(5);
Source: "{#SourcePath}\Input\Extra\mfc42u.dll"; DestDir: "{app}"; Check: IsWindowsVersion(5);
Source: "{#SourcePath}\Input\Release Notes.htm"; DestDir: "{app}"; Flags: skipifsourcedoesntexist;
Source: "{#SourcePath}\Input\Update\PumpUpdate.htm"; DestDir: "{app}"; Flags: skipifsourcedoesntexist;
Source: "{#SourcePath}\Input\bin\atutil.exe"; DestDir: "{app}";
Source: "{#SourcePath}\Input\bin\odbcnfg.exe"; DestDir: "{app}";
Source: "{#SourcePath}\Input\bin\odbcnfg64.exe"; DestDir: "{app}";
Source: "{#SourcePath}\Input\EnbKick.exe"; DestDir: "{app}";

//============
//save config
//============
Source:"{#SourcePath}\Input\bin\DriveCompressed.exe";DestDir:"{app}\bin";

//==========
//SDK docs
//==========
Source:"{#SourcePath}\Input\Extra\InnovaHxReg.exe"; DestDir:"{app}\SDK\Doc\VisualStudio"; Flags: dontcopy;
Source:"{#SourcePath}\Input\bin\enbclient.exe"; DestDir: "{app}";
Source:"{#SourcePath}\Input\bin\Interop.IWshRuntimeLibrary.dll"; DestDir: "{app}";

//===========
//C++ redists
//===========
Source: "{#SourcePath}\Input\MsiQueryProduct.exe"; DestDir: "{app}";
Source: "{#SourcePath}\Input\Extra\vcredist_x86.exe"; DestDir: "{app}";

//========================
//setup access permissions
//========================
Source: "{#SourcePath}\Input\bin\subinacl.exe"; DestDir: "{app}\bin";



; for modules not worked on yet
Source: "{#SourcePath}\ClientInstallInput\bin\EnablerEvent.dll"; DestDir: "{app}\bin"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\Extra\PDFViewer.exe"; DestDir: "{app}\bin"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\CreateRegKeyEvent.bat"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\scripts\Instances.bat"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\EnbSecurityController.exe"; DestDir: "{app}"; Check: IsInstallType('A');



[Dirs]
; deleteafterinstall ONLY DELETES if folder empty at end of install
Name: "{app}\Docs";
Name: "{app}\SDK\Doc\VisualStudio"; 
Name: "{app}\SDK"; 
Name: "{app}\SDK\Samples"; 
Name: "{group}\SDK\";

[Run]
; Test the running of an executable file if a server installation is selected in the wizard.
Filename: "{#SourcePath}\ForTestPurposesOnly\SqlServerMockInstall.exe"; Check: IsInstallType('B');

[Messages]
;Change the message on the standard welcome page
WelcomeLabel1=Welcome to The Enabler Setup Program. %nThis Program will install The Enabler on your computer.
WelcomeLabel2=We Recommend that you exit all Windows programs before running this Setup Program. %n%nClick Cancel to quit Setup and close any programs you have running. Click Next to continue with the Setup program. %n%nWARNING: This program is protected by copyright law and international treaties. %n%nUnauthorized reproduction or distribution of this program, or any portion of it, may result in severe civil and criminal penalties, and will be prosecuted to the maximum extent possible under law.

[Code]

//========================================
//variable declarations
//========================================

//Pages MUST be initialized here (at the end of this block) as they need to know each other to be presented in the right order
//Installer variables MUST be initialized here as they need to be global for many sequential processes of the install

var  
  
  APPNAME: string;
  OUTPUTBASEFILENAME: String;
  COMPONENTS: string;
  APPLICATIONS:String;
  ENBWEB_DOMAIN:String;
  ENBWEB_PORT:String;
  COMPUTERNAME:String;
  OS_ARCHITECTURE:String;
  OS_ARCHITEW6432:String;
   
  //The default is for none of the apps to be installed without the SDKoption selected
  SDK_OPTIONS:String;
  SDK_APPS:Integer;  //Set variables for an SDK build. SDK checked, SDK_APPS if present
  SDK:String;
  OS:Integer;

  //Disabling 8.3 will install files with short name: https://support.microsoft.com/en-us/kb/121007
  FILE_SYSTEM:Integer;

  //Driver Installation code
  DRIVERCODE:Integer;

  //SQL Server Major Product Number
  SQLVER_MAJOR:String;

  //APPTITLE is the application title of the installation
  APPTITLE:String;
  SQLTITLE:String;
  SQL_NEEDED:boolean;
  SQLEXPRESSNAME:string;

  //GROUP is the variable that holds the Program Files Group that shortcuts will be placed on the Windows Start Menu
  GROUP:String;

  //DISABLED variable is initialized for backward compatability
  DISABLED:String;

  //MAINDIR is the variable that holds the default destination directory
  MAINDIR:String;

  //BACKUP is the variable that holds the path that all backup files will be copied to when overwritten
  BACKUP:String;

  //DOBACKUP determines if a backup will be performed. The possible values are A (do backup) or B (do not do backup)
  DOBACKUP:String;

  //DBDIR specifies the location of the Enabler database files
  DBDIR:String;

  SQLSERVER_STARTED:String;

  //SA_PASSWORD stores the SA password (if any)
  SA_PASSWORD:String;

  //SQL Named Instance name
  SQL_SERVER:String;

  //SQL Named Instance name
  SQL_INSTANCE:String;
  PC_NAME:String;
  CLIENT_SQL_INSTANCE:String;
  SQLQUERY:String;
  INSTANCE_NAME_NEEDED:Boolean;
  INSTANCE_NAME_LIST:Boolean;
  CMD_INSTANCE:boolean;
  SQL_INSTANCES:String;

  //OSQL_PATH stores the path to OSQL.EXE
  OSQL_PATH:String;

  //SERVER_NAME stores the Enabler Server name (used for client installs only)
  SERVER_NAME:String;

  ENV_COMPUTERNAME:String;

  //Variable to determine if the Backup up checkbox option should be shown or not
  PRE_BACKUP:Boolean;

  //Initialise Checked variable this stops applications variable resetting in the wizard loop
  CHECKED:String;

  //Initialise icons variable. A is desktop icons B is start menu icons
  ICONS:String;

  //set variables to start apps or restart computer on finish
  NOSTART:Boolean;
  RUNNING:String;
  START_MPP:String;
  START_PUMP:String;

  //Initialise unattended variables
  UNATTENDED:string;
  SILENT:Boolean;
  PHASE2:Boolean;

  //Initialise fast startup variables
  FAST_STARTUP:string;

  //Initialise variables for detecting Adminstrator and User group
  BUILTIN_USERS_GROUP:String;
  BUILTIN_ADMINISTRATORS_GROUP:String;

  //SHOW_USAGE indicates whether we should display a dialog describing the installer command-line usage
  SHOW_USAGE:Boolean;

  WINDOWS_VERSION: String;
  WINDOWS_BASE_VERSION: Integer;
  MIN_WINDOWS_VERSION: Integer;
  OPERATING_SYSTEM: String;
  ENB_VERSION: String;

  //vars used in STARTUP PROCESSING
  SYS:string;
  INST_DRIVE:string;
  CMD_PATH:string;
  USERNAME:string;
  WIN_PRODUCT_TYPE_LINE:Ansistring;
  WIN_PRODUCT_TYPE:integer;
  IEXPLORE_PATH:String;
  IEXPLORE_VERSION:string;
  SHOW_IE_WARNING:boolean;
  HTML_RELEASE_NOTES:boolean;
  IS_WINDOWS_SERVER:boolean;
  NAME:string;
  COMPANY:string;
  LOGO_TYPE:string;
  DOBRAND:boolean;
  EXPLORER:boolean;
  COMMON:string;
  PROGRAM_FILES:string;

  //vars used in PARSE COMMAND LINE VARIABLES
  CMDLINE_LOG:String;
  CMDLINEUPPER: String;
  CMDLINEVAL: String;
  CMDOPTION: String;
  CMDUPPER: String;
  CMDSTART:String;
  CMDEND: String;
  ERROR_RTN:BOOLEAN;
  JUNK:string;
  PRE_UPGRADE_BACKUP:string;

  //used in ReturnFromRestart()
  RESTART:String;
  LAST_COMPONENTS:String;

  //USED IN INSTALL ENABLER FILES
  STARTUPDIR:STRING;
  DESKTOPDIR:STRING;
  STARTMENUDIR:STRING;
  GROUPDIR:STRING;
  CSTARTUPDIR:STRING;
  CDESKTOPDIR:STRING;
  CSTARTMENUDIR:STRING;
  CGROUPDIR:STRING;
  CGROUP_SAVE:string;

  //used in remove vars from registry
  BACKUPDIR:string;

  //setup env vars
  SETX_PATH:string;
  ENABLER_ROOT:string;
  ENABLER_LOG:string;
  ENABLER_DB_INSTANCE_NAME:string;

  //for decideReboot();
  DO_START_ACTIONS:integer;
  OPEN_WEB:string;
  ENBWEB_PORT_STR:string;
  RESTART_DECISION:boolean;

  //install SDK Docs
  ENABLER_SERVER:string;

  //.net framework installation.
  NET2_0_INSTALLED: integer;
  NET3_0_INSTALLED: integer;
  NET3_5_INSTALLED: integer;
  NET4_INSTALLED: integer;
  NET4_6_INSTALLED: integer;
  DOTNET_VERSION: integer;
  DOTNET350_SP: integer;
  DOTNET_RUNTIME_REQUIRED: integer;
  WIN2008_SERVER: integer;

  //Read Me Page  
  readMePage: TOutputMsgMemoWizardPage;
  releaseNotesButton: TNewButton;

  //install type page
  pageInstallType: TwizardPage;
  radioClient,radioServer: TRadioButton;
  lblClient, lblServer, lblSDK: TLabel;
  sdkCheckBox: TNewCheckBox;

  //server name entry page
  serverNameEntryPage:TInputQueryWizardPage;
  serverName:String;
  embeddedCheckBox:TNewCheckBox;
  embedded:Boolean;

  //instance name page
  instanceNamePage:TInputQueryWizardPage;
  instanceName:String;

  //no server installed page
  noServerInstalledPage:TOutputMsgWizardPage;

  //SA Password page
  SAPasswordPage: TInputQueryWizardPage;

  password:string;
  passwordcheck:string; //these need to be the same for the check

  //Port/Domain page
  portPage:TInputQueryWizardPage;
  portNum:String;                     //may need to be int
  domainName: String;
  lblPort:TLabel;

//========================================
//Variable initialisation.
//======================================== 

procedure variableInitialisation ();
var 
  osResultCode: Integer;
begin
  Log('Initialising variables.');

  // Get registry key values.
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\ITL\Enabler','Components',COMPONENTS);  // Initialise Components variable
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\ITL\Enabler','Applications',APPLICATIONS);  // Initialise Applications variable

  // Get the environment variables to determine OS.
  OS_ARCHITECTURE := GetEnv('PROCESSOR_ARCHITECTURE');
  OS_ARCHITEW6432 := GetEnv('PROCESSOR_ARCHITEW6432');

  if OS_ARCHITECTURE ='AMD64' then begin
    OS:=64;
  end
  else if OS_ARCHITECTURE ='IA64' then begin
      OS:=64;
  end
  else if OS_ARCHITECTURE ='x86' then begin
    if OS_ARCHITEW6432 = 'AMD64' then begin
      OS:=64;   // Installing driver from 32-bit installer on 64-bit OS (WOW64).
    end
    else begin
      OS:=32;   // Installing driver from 32-bit installer on 32-bit OS.
    end;
  end;

  // We will set this variable according to the 'Windows Current Version' Registry Key
  // NOTE: The Registry Key is: \\HKLM\Software\Microsoft\Windows NT\CurrentVersion\(CurrentVersion) - it contains a number.
  // NOTE: Windows 10 returns a value of 6.3 for backwards compatibility. Indicates its Windows 8.1
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'Software\Microsoft\Windows NT\CurrentVersion','CurrentVersion',OPERATING_SYSTEM);

  DRIVERCODE:=0;   // Driver Installation code.
  APPNAME := '{#SetupSetting("AppName")}';
  OUTPUTBASEFILENAME := '{#SetupSetting("OutputBaseFileName")}';
  APPTITLE:='The Enabler';  // APPTITLE is the application title of the installation.
  GROUP:='The Enabler';   // GROUP is the variable that holds the Program Files Group that shortcuts will be placed on the Windows Start Menu.
  DISABLED:='!';  // DISABLED variable is initialized for backward compatability.
  
  //MAINDIR:='C:\Enabler';   // MAINDIR is the variable that holds the default destination directory.    
  //BACKUP:=MAINDIR+'\BACKUP';   // BACKUP is the variable that holds the path that all backup files will be copied to when overwritten
  DOBACKUP:='B';   // DOBACKUP determines if a backup will be performed. The possible values are A (do backup) or B (do not do backup).
  DBDIR:=' C:\EnablerDB';   // DBDIR specifies the location of the Enabler database files.

  // SQL Named Instance name.
  PC_NAME:=GetEnv('COMPUTERNAME');
  INSTANCE_NAME_NEEDED:=True;
  INSTANCE_NAME_LIST:=False;
  ENV_COMPUTERNAME:=GetEnv('COMPUTERNAME');

  PRE_BACKUP:=False;   //Variable to determine if the BAckup up checkbox option should be shown or not
  CHECKED:='A';  // Initialise Checked variable this stops applications variable resetting in the wizard loop.

  // Set variables for an SDK build. SDK checked, SDK_APPS if present.
  SDK_APPS:=0;
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\ITL\Enabler','SDK',SDK);

  // Variables with defaults for ENBWEB port & domain.
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\ITL\Enabler','EnbWebDomain',ENBWEB_DOMAIN);
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\ITL\Enabler','EnbWebPort',ENBWEB_PORT);
  
  // Initialise icons variable. A is desktop icons, B is start menu icons.
  ICONS:='B';

  // Set variables to start apps or restart computer on finish.
  NOSTART:=False;

  // Initialise unattended variables.
  UNATTENDED:='0';
  SILENT:=False;
  PHASE2:=False;

  // Initialise fast startup variables.
  FAST_STARTUP:='0';

  // Initialise variables for detecting Adminstrator and User group.
  BUILTIN_USERS_GROUP:='S-1-5-32-545';
  BUILTIN_ADMINISTRATORS_GROUP:='S-1-5-32-544';

  // SHOW_USAGE indicates whether we should display a dialog describing the installer command-line usage.
  SHOW_USAGE:=False;

  // Get the windows version installed.
  MIN_WINDOWS_VERSION:=3; // The minimum Windows version required. Version 3 is Windows NT.
  WINDOWS_VERSION:=GetWindowsVersionString;     // Eg. 10.00.1856
  WINDOWS_BASE_VERSION:=StrToInt(Copy(WINDOWS_VERSION, 1, Pos('.', WINDOWS_VERSION)-1));    // Eg. 10

  // Set the Enabler version.
  ENB_VERSION:='{#SetupSetting("AppVersion")}'; // This variable was never initialised in the wise script. Initialised with a value here to enable compiler to run.
  
  // Check if operating system is Windows 10.
  if Exec(ExpandConstant('{win}\System32\cmd.exe'), '/C ver | find /i "Version 10."', '', SW_SHOW, ewWaitUntilTerminated, osResultCode) then begin
    OPERATING_SYSTEM:='10';
    Log('Running on Windows 10/Windows Server 2016, set OPERATING SYSTEM = 10');
  end;
  
  Log('Installing Enabler V' + ENB_VERSION + ' on Windows V' + WINDOWS_VERSION + ' ' + IntToStr(OS) + 'bit (Version ' + OPERATING_SYSTEM + ')');
                       
end;

//========================================
//installer-wide functions
//========================================

//functions for logger

procedure MoveLogFile();
// Current log file location is the user's temp folder. eg. C:\Users\Jamie\AppData\Local\Temp\Setup Log 2019-08-05 #001.txt
// The location or file name is not configurable so copy it to a new location with a new name and delete the old file.
var
  copyResult, deleteResult: boolean;
  logFilePathName, logFileName, newFilePathName: string;
begin
  logFilePathName := ExpandConstant('{log}');
  logFileName := appName + ' ' + ExtractFileName(logFilePathName);

  // Set the new location as the directory where the installer .exe is being run from.
  newFilePathName := ExpandConstant('{src}\') + logFileName;

  // Can't move log file, so copying file to new location and deleting old one.
  copyResult := FileCopy(logFilePathName, newFilePathName, false);
  if copyResult = False then
    Log('Unable to copy log file ' + logFilePathName)
  else
    deleteResult := DeleteFile(logFilePathName);
    if deleteResult = False then
      Log('Unable to delete log file ' + logFilePathName);
      FileCopy(logFilePathName, newFilePathName, false);  // Copy log file again to include the 'unable to delete log file' entry.
end;
 
//abort an install
procedure ExitProcess(exitCode:integer);
  external 'ExitProcess@kernel32.dll stdcall';

procedure Abort();
begin
  moveLogFile();
  ExitProcess(0);
end;


// Returns true if the installation type is the type passed to the function.
function IsInstallType(installType: String): Boolean;
begin
  if components = installType then 
    Result := true
  else
    Result := false;   
end;

//returns true if the OS type (32/64-bit) matches the passed parameter
function isOS(OSNum:integer):boolean;
begin
  if OS = OSNum then begin
    Result:=true;
  end
  else begin
    Result:=false;
  end;
end;

//returns true if Windows Version is less than parameter number version
function isWindowsVersion(checkNum:integer):boolean;
begin
  if WINDOWS_BASE_VERSION < checkNum then begin
    Result:=true;
  end
  else begin
    Result:=False;
  end;
end;


//check which pages to skip/display depending on components selected

function ShouldSkipPage(PageID:Integer):Boolean;
begin
  Result:=False;

  //pages exclusive to Client install
  if PageID = noServerInstalledPage.ID then begin
    if IsInstallType('A') then begin
      Result:=True;
    end;
  end;
  if PageID = SAPasswordPage.ID then begin
    if isInstallType('A') then begin
      Result:=True;
    end;
  end;
  if PageID = portPage.ID then begin
    if isInstallType('A') then begin
      Result:=true;
    end;
  end;

  //pages exclusive to Server install
  if PageID = serverNameEntryPage.ID then begin
    if IsInstallType('B') then begin
      Result:= True;
    end;
  end;
  if PageID = instanceNamePage.ID then begin
    if IsInstallType('B') then begin
      Result:= True;
    end;

  end;  

end;

//on pages that require user input, do not let them progress if something is wrong with their input

function NextButtonClick(CurPageID:Integer):Boolean;
begin
  Result:=True;

  //if passwords do not match
  if CurPageID = SAPasswordPage.ID then begin
    if SAPasswordPage.Edits[0].Text <> SAPasswordPage.Edits[1].Text then begin
      MsgBox('The passwords do not match. Please re-enter.', mbError, MB_OK);
      Result := False;
    end;
  end;

  //if password field is empty
  if CurPageID = SAPasswordPage.ID then begin
    if SAPasswordPage.Edits[0].Text = '' then begin
      MsgBox('The password field is empty. Please enter a password.', mbError, MB_OK);
      Result := False;
    end;
  end;
  if CurPageID = SAPasswordPage.ID then begin
    if SAPasswordPage.Edits[1].Text = '' then begin
      MsgBox('The re-enter password field is empty. Please re-enter the password to confirm.', mbError, MB_OK);
      Result := False;
    end;
  end;

  //if port number is empty
  if CurPageID = portPage.ID then begin
    if portPage.Edits[0].Text = '' then begin
      MsgBox('The port number field is empty. Please enter a port number. 8081 is the default.', mbError, MB_OK);
      Result := False;
    end;
  end;

  //if domain name is empty
  if CurPageID = portPage.ID then begin
    if portPage.Edits[1].Text = '' then begin
      MsgBox('The domain name is empty. Please enter a domain name. Use your local network domain if you have one, otherwise the default is mydomain.com.', mbError, MB_OK);
      Result := False;
    end;
  end;
end;

//==========================
//parse command line options
//==========================

procedure parseCommandLineOptions();
begin
  CMDLINEUPPER:= ExpandConstant('{param:CMDLINEVAL|}');  //  NOTE!!! You need /CMDLINEVAL='' to specify a command line command
  if CMDLINEUPPER <> '' then begin
    CMDOPTION:= CMDLINEUPPER;
    CMDUPPER:= CMDLINEUPPER;
    //!!! DEBUG ONLY - COMMENT OUT FOR RELEASE !!! MAKES PASSWORD VISIBLE!!!!
    Log('Option = '+CMDUPPER);
    //!!! DEBUG ONLY - COMMENT OUT FOR RELEASE !!!
    CMDSTART:= CMDUPPER;
    CMDEND:= CMDUPPER;

    //Check for /? or /h or -? or -h  - AT THE START OF THE STRING
    if CMDSTART = '-H' then begin
      Log('User requested usage -H')
      SHOW_USAGE:= true
    end;
    if CMDSTART = '-?' then begin
      Log('User requested usage -?')
      SHOW_USAGE:= true
    end;
    if CMDSTART = '/H' then begin
      Log('User requested usage /H')
      SHOW_USAGE:= true
    end;
    if CMDSTART = '/?' then begin
      Log('User requested usage /?')
      SHOW_USAGE:= true
    end;

    //Silent unattended install
    if pos('/S',CMDUPPER) <> 0 then begin
      Log('SILENT install selected')
      UNATTENDED:='1'
      SILENT:=true
      //error code only for silent mode install
      ERROR_RTN:=true
    end;
    //automatic server install
    if pos('/FULL',CMDUPPER) <> 0 then begin
      Log('FULL Enabler Server install selected')
      UNATTENDED:='1'
      COMPONENTS:='B'
      APPLICATIONS:='ABCDEF'
      if pos('/CLIENT', CMDLINEUPPER) <> 0 then begin
        Log('ERROR: Cannot use /CLIENT and /FULL together')
        Abort();
      end;
    end;
    //automatic client install
    if pos('/CLIENT', CMDUPPER) <> 0 then begin
      Log('CLIENT install selected')
      UNATTENDED:='1';
      COMPONENTS:='A'
      if pos('/FULL', CMDLINEUPPER) <> 0 then begin
        Log('ERROR: Cannot use /CLIENT and /FULL together')
        Abort()
      end;
      if pos('/PASSWORD', CMDLINEUPPER) <> 0 then begin
        Log('ERROR: Cannot use /CLIENT and /PASSWORD together')
        Abort()
      end;

      //THESE THREE OPTIONS WITH PARAMETERS (/CLIENT:servername) MUST BE ENTERED WITHOUT A SPACE
      if pos('/CLIENT:', CMDUPPER) <> 0 then begin
        JUNK:=copy(CMDUPPER, 9, Length(CMDUPPER)-1)
        SERVER_NAME:=copy(CMDUPPER, 9, Length(CMDUPPER)-1)
        Log('Enabler Server name has been entered: '+SERVER_NAME)
      end;
    end;
    //Get SA password (used for Server installs with pre-existing SQL server)
    if pos('/PASSWORD:', CMDUPPER) <> 0 then begin
      JUNK:=copy(CMDUPPER, 11, Length(CMDUPPER)-1)
      SA_PASSWORD:=copy(CMDUPPER, 11, Length(CMDUPPER)-1)
      //this could be a problem but the .wse says this is literally the string '*****'
      CMDUPPER:='/PASSWORD:*****'
      Log('PASSWORD for SA has been entered')
    end;
    //get the sql instance name
    if pos('/INSTANCE:', CMDUPPER) <> 0 then begin
      JUNK:=copy(CMDUPPER, 11, Length(CMDUPPER)-1)
      SQL_INSTANCE:=copy(CMDUPPER, 11, Length(CMDUPPER)-1)
      //'*****' string appears here too
      CMDUPPER:= '/INSTANCE:*****'
      Log('SQL Named Instance - ' + SQL_INSTANCE)
      CMD_INSTANCE:=true;
      //Configure SQL query for the default instance or the instance name passed in the command line
      SQLQUERY:= PC_NAME + '\' + SQL_INSTANCE;
    end;
    //The APPS option is no longer supported
    if pos('/APPS:', CMDUPPER) <> 0 then begin
      Log('The /APPS option was ignored - this option no longer supported.')
    end;
    //Option to install simulators WITHOUT SDK
    if pos('/MPPSIM', CMDUPPER) <> 0 then begin
      Log('Install Simulator EXE and DLL')
      SDK_OPTIONS := 'AF'
    end;
    //Option to install but NOT start Enabler services
    if pos('/NOSTART', CMDUPPER) <> 0 then begin
      Log('Not starting Enabler services - NOSTART selected.')
      NOSTART:=true;
    end;
    //Option to install SDK automatically
    if pos('/ENABLERSDK', CMDUPPER) <> 0 then begin
      Log('Install full SDK')
      SDK_OPTIONS:='ABC'
      SDK:='A'
    end;
    //Rebuild representation of cmdline suitable for logging
    CMDLINE_LOG:=CMDUPPER;

    //Supplying the parameter /BACKUPDB will initiate a Pre-Upgrade Backup
    if pos('/BACKUPDB', CMDUPPER) <> 0 then begin
      if COMPONENTS = 'A' then begin
        Log('INFO: /BACKUPDB option ignored. Cannot backup DB on /CLIENT install.')
      end
      else begin
        PRE_UPGRADE_BACKUP:='A';
      end;
    end;
  end;

  if (SHOW_USAGE) then begin
    Log('WARNING: Install stopped to show usage.');    
    //TODO - create dialog box "INSTALL USAGE"
    MsgBox('Install stopped to show usage', mbinformation, MB_OK);
    Abort();
  end;
  Log('CMD ' + CMDLINE_LOG)
end;

//==================
//startup processing
//==================

procedure startupProcessing();

var
  version:TWindowsVersion;
  ResultCode:integer;

begin
//check if the user is an admin
  Exec(ExpandConstant('{tmp}')+'\IsAdmin.exe', '', '', SW_SHOW,
     ewWaitUntilTerminated, ResultCode)
  if ResultCode = 0 then begin
        if SILENT = false then begin
              MsgBox('Not an administrator', mbInformation, MB_OK)
        end;
    Log('Install stopped - Not an administrator');
    Abort();
  end;

  //Needed to view release notes
  //IEXPLORE_PATH is used to store the full path and name of the IE executable.
  IEXPLORE_PATH:='';
  if RegValueExists(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\IEXPLORE.EXE','Path')then
  begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\IEXPLORE.EXE','Path',IEXPLORE_PATH)
    Log('IE Location ' + IEXPLORE_PATH);
  end;

  //get system information into IEXPLORE_VERSION
  IEXPLORE_VERSION:='';
  if RegValueExists(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Internet Explorer','Version')then
  begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Internet Explorer','Version',IEXPLORE_VERSION)
    Log('IE VERSION: ' + IEXPLORE_VERSION);
  end;

  if (strtoint(IEXPLORE_VERSION) < 5) then begin
  //We require IE 5 or later
    SHOW_IE_WARNING:= false;
    if FileExists(ExpandConstant('{src}')+'\Release Notes.htm') then begin
      Log('Warning: A Newer Version of IE is required to display release notes');
      SHOW_IE_WARNING:=true;
    end;
    if SHOW_IE_WARNING then begin
      if UNATTENDED = '1' then begin
        Log('Install stopped - never version of IE is required')
        Abort()
      end
      else begin
        MsgBox('A newer Internet Explorer is required', mbInformation, MB_OK)
        Log('User chose to exit install')
        Abort();
      end;
    end;
  end;
  
  if (FileExists(ExpandConstant('{src}')+'\Release Notes.htm')) then begin
    HTML_RELEASE_NOTES:=true;
  end
  else begin
    HTML_RELEASE_NOTES:=false;
  end;

  //If the destination system does not have a writable Windows\System directory,
  //system files will be written to the Windows\ directory

  //I have no idea how to check this elegantly
  if not FileCopy('{#SourcePath}\Input\test.txt',ExpandConstant('{sys}'), false) then begin
    SYS:=ExpandConstant('{win}');
  end;

  //INST_DRIVE stores the drive letter we are installing from
  INST_DRIVE:= ExpandConstant('{src}');
  Log('Installing from '+INST_DRIVE+' drive.');

  //Figure out the windows OS product type
  Exec('CMD.EXE', '/c wmic.exe os get producttype > ' + ExpandConstant('{tmp}')+'\WinProductType.txt', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);

  //Search for file CMD.EXE in Path and place into Variable CMD_PATH
  CMD_PATH:=ExpandConstant('{cmd}');
  
  //USERNAME is the variable that holds the Windows Logon name
  USERNAME:=ExpandConstant('{sysuserinfoname}');

  //Decide whether we are installing on a server OS
  IS_WINDOWS_SERVER:=false;

  //read lines of file into WIN_PRODUCT_TYPE_LINE
  LoadStringFromFile(ExpandConstant('{tmp}')+'\WinProductType.txt',WIN_PRODUCT_TYPE_LINE);
  if pos('1',WIN_PRODUCT_TYPE_LINE) <> 0 then begin
    //workstation edition of windows
    WIN_PRODUCT_TYPE:=1;
  end;
  if pos('2',WIN_PRODUCT_TYPE_LINE) <> 0 then begin
    //Domain controller
    WIN_PRODUCT_TYPE:=2;
    IS_WINDOWS_SERVER:= true;
  end;
  if pos('3',WIN_PRODUCT_TYPE_LINE) <> 0 then begin
    //Server
    WIN_PRODUCT_TYPE:=3;
    IS_WINDOWS_SERVER:=true;
  end;
  Log('Windows product type: ' + inttostr(WIN_PRODUCT_TYPE));

  //This IF/THEN/ELSE  block reads the default Program Files and Common directories from the registry 
  
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion','CommonFilesDir',COMMON);
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion','ProgramFilesDir',PROGRAM_FILES);
  EXPLORER:=true;

  //BRANDING determines if the installation will be branded with a name and company.
  if (FileExists(ExpandConstant('{src}')+'branding\config.ini')) then begin
    NAME:=GetIniString('Registration', 'Name', 'Name', ExpandConstant('{src}')+'\branding\config.ini');
    COMPANY:=GetIniString('Registration', 'Company', 'Company', ExpandConstant('{src}')+'\branding\config.ini');
    LOGO_TYPE:=GetIniString('Registration', 'INSTALL_LOGO', 'Logo_Type', ExpandConstant('{src}')+'\branding\config.ini');
    if NAME = '' then begin
      DOBRAND:=true;
      NAME:=ExpandConstant('{sysuserinfoname}');
      COMPANY:=ExpandConstant('{sysuserinfoorg}');
    end;
  end;

  //see if these is a current Enabler database
  if FileExists(DBDIR+'\ENBData.dat') then begin
    PRE_BACKUP:=true;
  end;

  //Initialise COMPONENTS variable depending on windows system type
  GetWindowsVersionEx(version);
  if version.NTPlatform then begin
  //don't want to overwrite registry variable so if already defined leave it alone
    if COMPONENTS = '' then begin
      COMPONENTS:='B';
    end
  end
  else begin
    //cannot install server without NT
    COMPONENTS:='A';
    if UNATTENDED = '1' then begin
      if COMPONENTS = 'A' then begin
        Log('ERROR: Cannot install server on this version of windows');
        Abort();
      end;
    end;
  end;
end;

//=================================================================
//Return from a restart
//=================================================================

//See if we are restarting because of an MSDE or MSI Installer or .NET restart

//!!!!NOTE: THE RESTART KEY IS CREATED IN ANY MODULE WHERE A REBOOT IS NECESSARY
//!!!!IF THE RESTART KEY EXISTS, IT NEEDS TO BE DELETED BEFORE THE REBOOTED SETUP FINISHES OR INSTALL WILL ALWAYS BE TREATED AS REBOOTED INSTALL
//!!!!THIS HAPPENS LATER ON IN .NET 3.5 SP1 MODULE

procedure returnFromRestart();
begin
  RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler', 'Restart',RESTART)
  RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler', 'InstallComponents',LAST_COMPONENTS)
  if RESTART <> '' then begin
    Log('Restarting from previous installation reboot.');
    PHASE2:=True;
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler','Restart', 'True');
    //load the variables from the registry. Components, SDK and Applications have done this already by this point
    RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler', 'Backup',PRE_UPGRADE_BACKUP);
    RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler', 'SA',SA_PASSWORD);
    RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler', 'UnattendedInstall',UNATTENDED);
    RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler', 'InstanceName',SQL_INSTANCE);
  end
  else if LAST_COMPONENTS <> '' then begin
    Log('Restarting from MSDE 2000 reboot.');
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler','InstallComponents', COMPONENTS);
    if SQL_NEEDED then begin
      if UNATTENDED = '0' then begin
        MsgBox('Could not locate MSDE', mbInformation, MB_OK);
      end;
      Log('ERROR:Continuing a previous install - MSDE was not located');
      Abort();
    end;
    PHASE2:=true;
    COMPONENTS:=LAST_COMPONENTS; 

    if SILENT then begin
      MsgBox(APPTITLE +' - Continuing Install', mbinformation, mb_OK);
    end;
    Log('Continuing Install' );

    sleep(5000);

    if SILENT then begin
      MsgBox('Not sure what this is for', mbinformation, mb_OK);
    end;
  end;

  //The SDK option is available if the SDK folder is present
  if DirExists(ExpandConstant('{src}\SDK')) then begin
    SDK_APPS:= 1;
  end;
end;


//=============================
//Check Windows version.
//=============================
procedure checkWindowsVersion();
var message: String;
begin
  // Check that the minimum Windows version is installed.
  if WINDOWS_BASE_VERSION < MIN_WINDOWS_VERSION then begin
    message := 'The base Windows version found was v' + IntToStr(WINDOWS_BASE_VERSION) + ' but the minimum Windows version required is v' + IntToStr(MIN_WINDOWS_VERSION) + '. Aborting installation.';
    Log(message);
    if UNATTENDED = '0' then begin
      SuppressibleMsgBox(message, mbCriticalError, MB_OK, IDOK);
    end;
    Abort();
  end;
end;


//=============================
//Check file system.
//=============================
procedure checkFileSystem();
var dWordValue: Cardinal;
begin
  // Get the file system value. 
  RegQueryDWordValue(HKEY_LOCAL_MACHINE,'SYSTEM\CurrentControlSet\Control\FileSystem','NtfsDisable8dot3NameCreation',dWordValue);
  FILE_SYSTEM := dWordValue;                     

  // Check that the Windows file system 8.3 file name creation is not disabled.
  if FILE_SYSTEM = 1 then begin
    Log('ERROR: Installation Failed. Error Code: 25. 8dot3 name creation is disabled on all volumes on the system.');
    if UNATTENDED = '0' then begin
      SuppressibleMsgBox('Installation Failed. Error Code: 25'#13#10#13#10'Windows file system has 8.3 file name creation disabled. Please refer to the Installation Instructions and re-run the Enabler Installer again.', mbCriticalError, MB_OK, IDOK);
    end;
    Abort();
  end;
end;


//=============================
//Check disk space requirements
//=============================

//Hardcoded to  800MB plus the COMPONENTS. 800MB is to cover space for Applications, SDK doc, SDK app, SQL Server, MIS, .NET
//SQL 2016 - 1480MB for enginel
//SQL 2008/2012/2014 - 820MB for engine 3.8GB for complete install
//SQL 2005 - 280MB for engine, 2.0GB for complete install 
//SQL 2000 - 270MB (obsolete) 
//MPPSim - 192KB 
//Pumpdemo - 200KB 
//.NET 3.5 - 30MB 
//MSI 4.5 - 3MB - based on installer size 
//SDK Docs - 2.08MB 
//Sample Apps - 8.55MB 
//Documentation - 5.2MB

procedure checkDiskSpace();
var
  DISK_SPACE:Cardinal;
  FreeMB, TotalMB:Cardinal;
begin
  GetSpaceOnDisk(ExpandConstant('{autopf}'), true, FreeMB, TotalMB);
  DISK_SPACE:=FreeMB;
  Log('Checking disk space');
  if DISK_SPACE < 1480 then begin
    if SILENT = false then begin
      Log('Installation failed');
      MsgBox('Install failed - not enough space', mbInformation, MB_OK);
    end;
    Log('Not enough install space');
    Abort();
  end;
end;


//=============================
//INSTALL .NET 3.5
//=============================

procedure installNet3Point5();
var
  message: String;
  i: Integer;
  dWordValue: Cardinal;
  progressPage: TOutputProgressWizardPage;
  ResultCode: Integer;
begin
  // Check the versions of .NET installed.
  RegQueryDWordValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\NET Framework Setup\NDP\v2.0.50727','Install',dWordValue);
  NET2_0_INSTALLED := dWordValue;
  RegQueryDWordValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.0','Install',dWordValue);
  NET3_0_INSTALLED := dWordValue;
  RegQueryDWordValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5','Install',dWordValue);
  NET3_5_INSTALLED := dWordValue;
  RegQueryDWordValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4','Install',dWordValue);
  NET4_INSTALLED := dWordValue;
  RegQueryDWordValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4.6','Install',dWordValue);
  NET4_6_INSTALLED := dWordValue;

  DOTNET_VERSION := 0;
  DOTNET350_SP := 0;

  if NET3_5_INSTALLED = 1 then begin
    Log('Found .NET v3.5 runtime');
    DOTNET_VERSION := 350;
    RegQueryDWordValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5','SP',dWordValue);
    DOTNET350_SP := dWordValue;
  end
  else if NET3_0_INSTALLED = 1 then begin
    Log('Found .NET v3.0 runtime');
    DOTNET_VERSION := 300;
  end
  else if NET2_0_INSTALLED = 1 then begin
    Log('Found .NET v2.0 runtime');
    DOTNET_VERSION := 200;
  end;

  // We actually require .NET 3.5 SP 1 to run (see EP-1146)
  DOTNET_RUNTIME_REQUIRED := 0;

  if DOTNET_VERSION < 350 then begin
    DOTNET_RUNTIME_REQUIRED := 1;
  end;

  if DOTNET350_SP = 0 then begin
    DOTNET_RUNTIME_REQUIRED := 1;
  end;

  if DOTNET_RUNTIME_REQUIRED = 1 then begin
    if not FileExists(ExpandConstant('{src}')+'\Win\DotNetFX\3.5\dotNetFx35setup.exe') then begin
      if SILENT = False then begin
        MsgBox('.NET 3.5 Framework Installer Failed. Aborting installation.', mbInformation, MB_OK);
      end;
      Log('ERROR: Missing .NET 3.5 Framework Installer');
      Abort();
    end;

    if SILENT = False then begin
      try
        progressPage := CreateOutputProgressPage('Progress Stage','Installing .Net 3.5'#13#10#13#10'This may take a couple of minutes. Please wait...');
        progressPage.SetProgress(0, 0);
        progressPage.Show;
      finally
        progressPage.Hide;
      end;
    end;

    // On Windows Server 2008 the runtime has to be installed using the server manager tool, so if we get here we can't continue.
    WIN2008_SERVER := 0;

    if OPERATING_SYSTEM = '6.0' then begin
      WIN2008_SERVER := 1;
    end
    else if OPERATING_SYSTEM = '6.1' then begin
      WIN2008_SERVER := 1;
    end;

    if WIN2008_SERVER = 1 then begin
      if IS_WINDOWS_SERVER = True then begin
        Log('INFO: Cannot use dotNetFx installer on Windows Server 2008');
        Log('INFO: .NET Runtime must be installed before Enabler using Administrative Tools - Server Manager.');

        if SILENT = False then begin
          message := '.NET 3.5 Runtime required.'#13#10#13#10'The Enabler requires the .NET 3.5 runtime to be installed.'#13#10#13#10;
          message := message + 'On Windows Server 2008 this must be installed manually using:'#13#10'   Administrative Tools - Server Manager'#13#10#13#10;
          message := message + 'You must do this before running the Enabler installer.';
          MsgBox(message, mbInformation, MB_OK);
        end;
        Abort();
      end;
    end;

    // .NET 3.5 will auto-reboot therefore better write RunOnce to the registry.
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler','Restart', 'True');
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce','EnablerInstall',ExpandConstant('{src}')+'\'+OUTPUTBASEFILENAME+'.exe');

    Log('Installing .NET 3.5 Framework');
    Exec(ExpandConstant('{win}\System32\cmd.exe'), '/C "'+ExpandConstant('{src}')+'\Win\DotNetFX\3.5\dotNetFx35setup.exe" /Q', '', SW_SHOW, ewWaitUntilTerminated, ResultCode)
    
    if ResultCode = 3010 then begin
      Log('INFO: .NET 3.5 Framework Already Installed');
    end
    else begin
      if not ResultCode = 0 then begin
        // 4121 means MSI is required - should not happen because we install this automatically.
        if ResultCode = 4121 then begin
          if SILENT = False then begin
            MsgBox('.NET 3.5 Framework Installer Failed. MSI 4.5 required.', mbInformation, MB_OK);
          end;
          Log('.NET 3.5 requires MSI 4.5');
        end
        else begin
          if SILENT = False then begin
            MsgBox('.NET 3.5 Framework Installer Failed. ERROR LEVEL = '+IntToStr(ResultCode), mbInformation, MB_OK);
          end;
          Log('.NET 3.5 Framework Installation Failed.');
        end;
        // Remove the registry keys added by MSI reboot
        RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler','UnattendedInstall', UNATTENDED);
        // Removed exit !!!!!!!!!!!!!!!!!!!!!!!
      end;
    end;

    if SILENT = False then begin
      try
        progressPage.SetText('REMOVE Installing .Net 3.5'#13#10#13#10'This may take a couple of minutes. Please wait...','');
        progressPage.SetProgress(0, 0);
        progressPage.Show;
      finally
        progressPage.Hide;
      end;
    end;
  end;

  // Remove the registry keys added by any restart in the previous sections. Note: Contrary to this comment, the old wise script doesn't remove the keys.
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler','SA', SA_PASSWORD);
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler','Backup', PRE_UPGRADE_BACKUP);
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler','UnattendedInstall', UNATTENDED);
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler','Restart', RESTART);
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler','InstanceName', SQL_INSTANCE);

  // Remove the one once key if still present.
  // This happens if 3.5 is installed and doesn't reboot
  // And then the driver install on XP will execute the runonce key causing the install to start again
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce','EnablerInstall',ExpandConstant('{src}')+'\'+OUTPUTBASEFILENAME+'.exe');
end;


//=============================
//INSTALL ENABLER FILES
//=============================

procedure installEnablerFiles();
var
  ResultCode:integer;
begin
//Load registry settings required to add start menu items

//if system has windows 95 shell interface (i.e. if system is 32-bit not 16-bit)
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','StartUp',STARTUPDIR);
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','Desktop',DESKTOPDIR);
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','Start Menu',STARTMENUDIR);
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','Programs',GROUPDIR);
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','Common Startup',CSTARTUPDIR);
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','Common Desktop',CDESKTOPDIR);
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','Common Start Menu',CSTARTMENUDIR);
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','Common Programs',CGROUPDIR);

  CGROUP_SAVE:=GROUP;
  DESKTOPDIR:=CDESKTOPDIR;
  GROUP:=CGROUPDIR+'\'+GROUP;

  //else begin
  //Just being paranoid really - we should never get here because we check the OS Version earlier on
  //Log('ERROR: Cannot add Start Menu items');
  //Abort();
  //end;


  if COMPONENTS = 'B' then begin  
    if FileExists(ExpandConstant('{app}')+'\psrvr4.exe') then begin
      Exec(ExpandConstant('{app}')+'\scutil.exe', '/STOP psrvr','',SW_SHOW,ewWaitUntilTerminated, ResultCode);
      if ResultCode <> 0 then begin
        Log('INFO: Could not stop PSRVR (rc='+inttostr(ResultCode) + ')');
      end;
    end;
    if FileExists(ExpandConstant('{app}')+'\bin\psrvr4.exe') then begin
      Exec(ExpandConstant('{app}')+'\scutil.exe', '/STOP psrvr','',SW_SHOW,ewWaitUntilTerminated, ResultCode);
      if ResultCode <> 0 then begin
        Log('INFO: Could not stop PSRVR (rc='+inttostr(ResultCode) + ')');
      end
    end
    else begin
      if FileExists(ExpandConstant('{app}')+'\psrvr.exe') then begin
        Exec(ExpandConstant('{app}')+'\scutil.exe', '/STOP psrvr','',SW_SHOW,ewWaitUntilTerminated, ResultCode);
        if ResultCode <> 0 then begin
          Log('INFO: Could not stop PSRVR (rc='+inttostr(ResultCode)+')');
        end;
      end;
    end;
    if FileExists(ExpandConstant('{app}')+'\bin\WebHost.exe') then begin
      Exec(ExpandConstant('{app}')+'\scutil.exe', '/STOP WebHost','',SW_SHOW,ewWaitUntilTerminated, ResultCode);
      if ResultCode <> 0 then begin
        Log('INFO: Could not stop Enabler Web (rc='+inttostr(ResultCode)+')');
      end;
    end;
    if FileExists(ExpandConstant('{app}')+'\bin\EnbWeb.exe') then begin
      Exec(ExpandConstant('{app}')+'\scutil.exe', '/STOP psrvr','',SW_SHOW,ewWaitUntilTerminated, ResultCode);
      if ResultCode <> 0 then begin
        Log('INFO: Could not stop Enabler Web (rc='+inttostr(ResultCode)+')');
      end;
    end;
  end;
end;

//===================================
//remove variables in windows registry
//===================================
procedure removeRegistryVars();
begin
  RegDeleteKeyIncludingSubkeys(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler\Applications');
  RegDeleteKeyIncludingSubkeys(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler\Backup');
  RegDeleteKeyIncludingSubkeys(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler\Components');
  RegDeleteKeyIncludingSubkeys(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler\SA');
  RegDeleteKeyIncludingSubkeys(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler\SDK');
  RegDeleteKeyIncludingSubkeys(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler\UnattendedInstall');


  //When the BACKUP feature is enabled, the BACKUPDIR is initialized
  If DOBACKUP = 'A' then begin
    BACKUPDIR:=BACKUP;
  end;

  //COMMENT LINES IN .WSE - WE ALREADY HAVE A FUNCTION TO CHECK DISK SPACE:

  //Check free disk space calculates free disk space as well as component sizes.
  //It should be located before all Install File actions.
  //Check free disk space

  //Remove ATL.DLL hook if preset to prevent automatic activation of MSDE setup
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\Classes\CLSID\{44EC053A-400F-11D0-9DCD-00A0C90391D3}\InprocServer32', '(Default)', ')1pFEf=hI=DBiz@GgPxz>w.''b9VZqf(g6u.Q(31aR');
end;

//=======================================
//Add uninstall items to the Install Log
//=======================================

procedure logUninstallItems();
var
  ResultCode:integer;
begin
  //Uninstall the API
  Log('Execute path: '+ExpandConstant('{sys}')+'\msiexec.exe /quiet /L+* '+ExpandConstant('{app}')+'\log\APIInstall.log /uninstall ' +ExpandConstant('{app}')+'\InstallEnablerAPI.msi');

  //Embed the Enabler product version - used to determine which version is installed
  Log('EnablerVersion: '+ENB_VERSION);

  //These lines reset COMMON and MAINDIR to short filenames. This is for backwards compatibility
  COMMON:=ExpandConstant('{commonpf}');
  MAINDIR:=ExpandConstant('{app}');

  //Add some extra entries to the Wise log - so temporary or generated files are removed at uninstall
  Log('Execute path: '+ExpandConstant('{sys}')+'\msiexec.exe /quiet /L+* '+ExpandConstant('{app}')+'\log\APIInstall.log /X '+ ExpandConstant('{app}')+'\InstallEnablerAPI.msi');

  //Run an optional integrators sql file
  if COMPONENTS = 'B' then begin
    Log('Checking for '+ExpandConstant('{src}')+'ServerHook.sql ');
    if FileExists(ExpandConstant('{src}')+'ServerHook.sql') then begin
      Log('Running '+ExpandConstant('{src}') +'ServerHook.sql (osql '+OSQL_PATH+')');
      Exec(OSQL_PATH+'OSQL.EXE', '-b -d EnablerDB -E -S'+SQLQUERY+' -i "'+ExpandConstant('{src}')+'ServerHook.sql" -o ' + ExpandConstant('{app}')+'ServerHook.log', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
      Log('Completed ServerHook (return code '+inttostr(ResultCode)+ ')');
    end;
    //check service psrvr
  end;

  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER\Client', 'Applications', APPLICATIONS);
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'Components', COMPONENTS);
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'SDK', SDK);
end;

//========================================
//functions for Read Me/Release Notes page
//========================================

procedure OpenBrowser(Url:String);
var
  ErrorCode:Integer;
begin
  ShellExec('open', Url, '','', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end; 

procedure releaseNotesButtonOnClick(Sender:TObject);
begin
  OpenBrowser('{#SourcePath}\Input\Release Notes.htm');
end; 

procedure createReadMePage();
  
begin
  readMePage:=CreateOutputMsgMemoPage(wpInfoBefore, 'ReadMe File', 'Please read the following important information before continuing.',
  'When you are ready to continue with Setup, click Next.',
  'Enabler V4.6.3.6087'#13#10 #13#10'1) If you are upgrading from an Enabler version prior to V3.4x, we suggest you remove the previous installation using Add/Remove Programs before installing this software.'#13#10 #13#10'2) The installation will now automatically install the SQL Server Express Edition when installing on systems without an SQL Server installed.'#13#10 #13#10'3) Check for newer pump drivers on our website http://www.integration.co.nz/'#13#10 #13#10'4) Where possible we have documented known issues in the Release Notes document.');
  releaseNotesButton:=TNewButton.Create(readMePage);
  releaseNotesButton.Parent:=readMePage.Surface;
  releaseNotesButton.Caption:='View Release Notes';
  releaseNotesButton.Left := readMePage.SurfaceWidth - ScaleX(500);
  releaseNotesButton.Top := readMePage.SurfaceHeight - ScaleY(40);
  releaseNotesButton.Width := ScaleX(150);
  releaseNotesButton.Height := ScaleY(23);
  releaseNotesButton.Anchors := [akRight, akBottom]
  releaseNotesButton.onclick:=@releaseNotesButtonOnClick;  
end;

//========================================
//functions for install type selection page
//========================================

procedure RadioClientClicked(Sender: TObject);
begin
  components := 'A';  // Client install.
  Log(components);
end; 

procedure RadioServerClicked(Sender: TObject);
begin
  components := 'B';  // Server install.
  Log(components);
end;

procedure SDKOptionClicked(Sender: TObject);
begin
  sdk:='A';
end;

procedure createPageInstallType();
  
begin
  pageInstallType := CreateCustomPage(wpSelectComponents, 'Select Installation Type', 'Select the type of install you would like from the radio buttons. SDK is optional.');

  radioClient := TRadioButton.Create(pageInstallType);
  radioClient.Parent := pageInstallType.Surface;
  radioClient.Caption := 'Client Install';
  radioClient.OnClick := @RadioClientClicked;

  CHECKED:= 'A';
  if APPLICATIONS = '' then begin
    //set default applications setting
    if COMPONENTS = 'A' then begin
      APPLICATIONS:='B';
    end
    else begin
      APPLICATIONS:='ABCDE';
    end;
  end;
  
  //COMMENT THIS OUT OR DELETE IT ONCE STARTUPPROCESSING() IS ADDED!!!!!!!!!!!!!!!!!!!!!!!!!!!
  //components:='A';  

  lblClient := TLabel.Create(pageInstallType);
  lblClient.Parent := pageInstallType.Surface;
  lblClient.Caption := 'Install the Enabler Client components to connect to connect to an Enabler Server, Enabler Server Desktop or Enabler Embedded.';
  lblClient.Top := radioClient.Top+20;
  lblClient.Left := 20;
  lblClient.Height := 40;
  lblClient.Width := 500;
  lblClient.WordWrap := True;

  radioServer := TRadioButton.Create(pageInstallType);
  radioServer.Parent := pageInstallType.Surface;
  radioServer.Caption := 'Server Install';
  radioServer.Top := lblClient.Top+50;
  radioServer.OnClick := @RadioServerClicked;
  //see which radio button should be selected by deafult based on startupProcessing()
  if COMPONENTS = 'A' then begin
    radioClient.Checked := True;
    end
  else begin
    radioServer.Checked := True;
  end;

  lblServer := TLabel.Create(pageInstallType);
  lblServer.Parent := pageInstallType.Surface;
  lblServer.Caption := 'Install the Enabler Server Desktop - Enabler Card REQUIRED. SQL Server will be installed if none found.';
  lblServer.Top := radioServer.Top+20;
  lblServer.Left := 20;
  lblServer.Height := 40;
  lblServer.Width := 500;
  lblServer.WordWrap := True;

  sdkCheckBox:=TNewCheckBox.Create(pageInstallType);
  sdkCheckBox.Parent:=pageInstallType.Surface;
  sdkCheckBox.Caption:= 'SDK Add-ons';
  sdkCheckBox.Top := lblServer.Top+50;
  sdkCheckBox.Left := 0;
  sdkCheckBox.Height := 40;
  sdkCheckBox.Width := 500;
  sdkCheckBox.onClick:= @SDKOptionClicked;  

  lblSDK := TLabel.Create(pageInstallType);
  lblSDK.Parent := pageInstallType.Surface;
  lblSDK.Caption := 'Install the Enabler SDK Documents, Tools (MPPSim, PumpDemo, etc). If UNTICKED, previous SDK will be removed.';
  lblSDK.Top := sdkCheckBox.Top+40;
  lblSDK.Left := 0;
  lblSDK.Height := 40;
  lblSDK.Width := 500;
  lblSDK.WordWrap := True;
end;

//========================================
//functions for Enabler Server Name page
//========================================

procedure EmbeddedOptionClicked(Sender: TObject);
begin
  embedded:=true;
end;

procedure createClientSelectedPage();  
begin
  serverNameEntryPage:= CreateInputQueryPage(pageInstallType.ID, 'Enter the Name or IP Address of the Enabler Server System',
  '', 'The Enabler Client you are installing will access an Enabler Server (Enabler Server Desktop or Enabler Embedded) during operation.'#13#10 #13#10'Please enter the name or IP Address of the Enabler Server System this Client should connect to.' #13#10 #13#10'Tick Embedded if the Enabler Server is an Enabler Embedded system.' #13#10 #13#10 'Name can be left blank, but refer to the Enabler documentation on how to change the Enabler Server System Name or IP Address setting later.'); 
  serverNameEntryPage.Add('Enabler Server Name:', False);
  serverName:=serverNameEntryPage.Values[0];

  embeddedCheckBox:=TNewCheckBox.Create(serverNameEntryPage);
  embeddedCheckBox.Parent:=serverNameEntryPage.Surface;
  embeddedCheckBox.Caption:= 'Embedded?';
  embeddedCheckBox.Top := 225;
  embeddedCheckBox.Left := 0;
  embeddedCheckBox.Height := 40;
  embeddedCheckBox.Width := 500;
  embeddedCheckBox.onClick:= @EmbeddedOptionClicked; 
end;

//========================================
//functions for Instance Name page
//========================================

procedure createInstanceNamePage();
begin
  instanceNamePage:= CreateInputQueryPage(serverNameEntryPage.ID, 'Enabler Server SQL Instance Name',
  '', 'For Enabler installations using a non-default SQL Server instance name, please enter the Instance name below, otherwise leave the field blank and select Next.'); 
  instanceNamePage.Add('Instance Name:', False);
  instanceName:=instanceNamePage.Values[0];

  if not CMD_INSTANCE then begin
    CLIENT_SQL_INSTANCE:=SQL_INSTANCE;
  end;
end;

//========================================
//functions for install warning page
//========================================

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String; 
begin
  if SQL_NEEDED then begin
    if COMPONENTS = 'B' then begin
      if SQLEXPRESSNAME = 'SQL2005' then begin
        SQLTITLE:= ' and SQL Server 2005 Express';
      end;
      if SQLEXPRESSNAME = 'SQL2008R2' then begin
        SQLTITLE:= ' and SQL Server 2008 Express';
      end;
    end;
  end;
  Result:='You are now ready to install The Enabler.'#13#10#13#10'Click the Install button to begin the installation,'#13#10'or the Back button to change your Installation options.'#13#10#13#10'If you have an existing Enabler installation you can select the database backup checkbox below'#13#10'to back up Enabler as part of the installation.';
end;

//========================================
//functions for No Microsoft SQL Server Installed page
//========================================

procedure createNoServerInstalledPage();
begin
  noServerInstalledPage:=CreateOutputMsgPage(instanceNamePage.ID,'No Microsoft SQL Server is installed.'#13#10'Install the default SQL Server (SQL2104 Express)?', '', 'Your install selection of the Enabler Server requires an SQL Database.'#13#10#13#10'If you continue, the Default SQL Server (SQL2014 Express) will be installed before installing the Enabler software.'#13#10#13#10'If you do not want the Enabler to use the SQL2014 Express Database Server, you MUST EXIT NOW and install your preferred Microsoft Database Server before re-running this setup.');
end;

//========================================
//functions for Server Password page
//========================================

procedure createSAPasswordPage();
begin
  SAPasswordPage:=CreateInputQueryPage(noServerInstalledPage.ID, 'To install the SQL Server SQL2014Express, SA password is required.', '','To install the SQL Server SQL2014Express, SA password is required. Please choose a strong password and keep it for future reference.');
  SAPasswordPage.Add(SetupMessage(msgPasswordEditLabel),True);
  SAPasswordPage.Add('Re-enter password:',True);
  SA_PASSWORD:=SAPasswordPage.Edits[0].Text;
end;

//========================================
//functions for Network Port/Domain page
//========================================

procedure createNetworkPortPage();   
begin
  portPage:= CreateInputQueryPage(SAPasswordPage.ID, 'Confirm the Network Port and Domain for Enabler Web Server.', '', '');
  portPage.Add('Port', False);
  portPage.Add('Network Domain', False);
  lblPort := TLabel.Create(portPage);
  lblPort.Parent := portPage.Surface;
  lblPort.Caption := 'Default port is 8081.'#13#10#13#10'Use your local domain if you have one.'#13#10#13#10'Depending on your network and firewall configuration, you may need to change the port number here to Ensure Enabler Web Server uses an available port.'#13#10#13#10'NOTE: Refer to the installation instructions for information about firewall configuration.';
  lblPort.Top := sdkCheckBox.Top+20;
  lblPort.Left := 0;
  lblPort.Height := 40;
  lblPort.Width := 500;
  lblPort.WordWrap := True;
  portPage.Values[0] := '8081';
  portPage.Values[1] := 'mydomain.com';
  portNum:= portPage.Values[0];
  domainName:= portPage.Values[1];
end;

//========================================
//Install user docs
//========================================

procedure basicPDFFiles();
begin
  if FileExists(ExpandConstant('{src}')+'\Documentation\ENABLER Demonstration POS Application Reference Manual.pdf') then begin
    FileCopy(ExpandConstant('{src}')+'\Documentation\ENABLER Demonstration POS Application Reference Manual.pdf', WizardDirValue+'\Docs\ENABLER Demonstration POS Application Reference Manual.pdf', False)
  end
  else begin
    Log('Enabler POS Documentation not found')
  end;
  if FileExists(ExpandConstant('{src}')+'\Documentation\ENABLER Web Reference Manual.pdf') then begin
    FileCopy(ExpandConstant('{src}')+'\Documentation\ENABLER Web Reference Manual.pdf', WizardDirValue+'\Docs\ENABLER Web Reference Manual.pdf', False)
  end
  else begin
    Log('Enabler Web Documentation not found')
  end;
end;

    //TODO - create shortcuts from pdfs to {group}\manuals\pdfs.lnk
    //Couldn't get the old installer to do this on my PC so I could see what's happening


//================
//install SDK docs
//=================

procedure DirectoryCopy(SourcePath, DestPath: string);
var
  FindRec: TFindRec;
  SourceFilePath: string;
  DestFilePath: string;
begin
  if FindFirst(SourcePath + '\*', FindRec) then
  begin
    try
      repeat
        if (FindRec.Name <> '.') and (FindRec.Name <> '..') then
        begin
          SourceFilePath := SourcePath + '\' + FindRec.Name;
          DestFilePath := DestPath + '\' + FindRec.Name;
          if FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY = 0 then
          begin
            if FileCopy(SourceFilePath, DestFilePath, False) then
            begin
              Log(Format('Copied %s to %s', [SourceFilePath, DestFilePath]));
            end
              else
            begin
              Log(Format('Failed to copy %s to %s', [SourceFilePath, DestFilePath]));
            end;
          end
            else
          begin
            if DirExists(DestFilePath) or CreateDir(DestFilePath) then
            begin
              Log(Format('Created %s', [DestFilePath]));
              DirectoryCopy(SourceFilePath, DestFilePath);
            end
              else
            begin
              Log(Format('Failed to create %s', [DestFilePath]));
            end;
          end;
        end;
      until not FindNext(FindRec);
    finally
      FindClose(FindRec);
    end;
  end
    else
  begin
    Log(Format('Failed to list %s', [SourcePath]));
  end;
end;

procedure SDKFiles();
var
  ResultCode:Integer;
  PDF:String;
  MICROSOFT_HELP:String;
begin
  //install SDK documentation
  if pos('C',SDK_OPTIONS) <> 0 then begin
  //remove old SDK documentation
    if dirExists(ExpandConstant('{src}')+'\SDK') then begin
      DelTree(ExpandConstant('{app}')+'\SDK\Doc', true, true, true);
      DelTree(ExpandConstant('{app}')+'\SDK\DotNetPCAPI', true, true, true);
      DelTree(ExpandConstant('{app}')+'\SDK\Samples', true, true, true);
      //Install new SDK documentation
      if FileExists(ExpandConstant('{win}')+'hh.exe') then begin
        MICROSOFT_HELP:= ExpandConstant('{win}')+'hh.exe';
        Log('Microsoft help location is '+ MICROSOFT_HELP);
      end;
      DirectoryCopy(ExpandConstant('{src}\SDK'), ExpandConstant('{app}\SDK'));
      ExtractTemporaryFile('InnovaHxReg.exe');
      FileCopy(ExpandConstant('{tmp}\InnovaHxReg.exe'), ExpandConstant('{app}\SDK\Doc\VisualStudio\InnovaHxReg.exe'),false);
      if ((OS=64) and (strtoint(OPERATING_SYSTEM) >= 6)) then begin
        Exec('C:\WINDOWS\Sysnative\CMD.EXE /c ' + ExpandConstant('{app}')+'\SDK\Doc\VisualStudio\registerhelp2.bat', '', '', SW_SHOW, ewWaitUntilTerminated, ResultCode)
        Log('Execute path: C:\WINDOWS\Sysnative\CMD.EXE /c ' + ExpandConstant('{app}')+'\SDK\Doc\VisualStudio\unregisterhelp2.bat')
      end
      else begin
        Exec('CMD.EXE /c ' + ExpandConstant('{app}')+'\SDK\Doc\VisualStudio\registerhelp2.bat', '', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
        Log('Execute path: C:\WINDOWS\Sysnative\CMD.EXE /c ' + ExpandConstant('{app}')+'\SDK\Doc\VisualStudio\unregisterhelp2.bat'); 
      end;

      if pos('B',ICONS) <> 0 then begin
        //create a bunch of links to manuals in {group}, not sure about this
        deleteFile(ExpandConstant('{group}\SDK\Database Dictionary.lnk'));
        deleteFile(ExpandConstant('{group}\SDK\Developers Guide.lnk'));
        deleteFile(ExpandConstant('{group}\SDK\Developers Reference.lnk'));
        deleteFile(ExpandConstant('{group}\SDK\Hardware Setup and Installation Manual.lnk'));
        deleteFile(ExpandConstant('{group}\SDK\Embedded Getting Started Guide.lnk'));
        deleteFile(ExpandConstant('{group}\SDK\Site Installation Checklist.lnk'));
        deleteFile(ExpandConstant('{group}\SDK\Embedded Site Installation Checklist.lnk'));
        deleteFile(ExpandConstant('{group}\SDK\Embedded REST API Reference.lnk'));

        //TODO - create replacement links
      end;
    end
    else begin
      Log('SDK folder not present in installer folder');
    end;
  end
  else begin
  //not installing SDK - remove any existing files and start menu links
    delTree(ExpandConstant('{app}\SDK'), true, true, true);
    if not dirExists(ExpandCOnstant('{app}\SDK\Samples')) then begin
      delTree(ExpandConstant('{group}\SDK'),true, true, true);
    end;
  end;

  //Remove OPT Simulator and DLL
  if FileExists(ExpandConstant('{app}')+'\ITLOPTSim.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\ITLOPTSim.exe')
    DeleteFile(ExpandConstant('{group}')+'\ITLOPTSim.lnk')
    DeleteFile(ExpandConstant('{userdesktop}')+'\ITLOPTSim.lnk')
  end;
  if FileExists(ExpandConstant('{app}')+'ITLOPTSim.dll') then begin
    DeleteFile(ExpandConstant('{app}')+'ITLOPTSim.dll')
  end;

  //Remove Legacy Startmenu Link
  DeleteFile(ExpandConstant('{group}')+'\Forecourt Manager.lnk')
  
  //Enabler v4 always removes the CLIENT version of PSRVR
  if FileExists(ExpandConstant('{app}')+'\psrvr.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\psrvr.exe')
  end;

  if COMPONENTS = 'A' then begin
  //Client Install to Enabler (Desktop or Embedded)
    Exec(SETX_PATH, ENABLER_SERVER + ' ' + SERVER_NAME + ' -M', '', SW_SHOW, ewWaitUntilTerminated, ResultCode)
  end;

  //Always install ActiveX client utility - most useful for client installs.
  if FileExists(ExpandConstant('{app}')+'\bin\enbclient.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\bin\enbclient.exe')
  end;
  if FileExists(ExpandConstant('{app}')+'\bin\Interop.IWshRuntimeLibrary.dll') then begin
    DeleteFile(ExpandConstant('{app}')+'\bin\Interop.IWshRuntimeLibrary.dll')
  end;

  //Setup PDF files to link to Sumatra PDF if there is no existing reader
  PDF:= '';
  RegQueryStringValue(HKEY_CLASSES_ROOT, '.pdf', '(Default)', PDF);
    if PDF = '' then begin
    Log('There is no current PDF reader - setting up Sumatra PDF')
    //Edit 5 registry keys
    RegWriteStringValue(HKEY_CLASSES_ROOT, 'ITLPDF.Document', '(Default)', 'ITL PDF Document');
    RegWriteStringValue(HKEY_CLASSES_ROOT, 'ITLPDF.Document\DefaultIcon', '(Default)', ExpandConstant('{app}')+'bin\PDFViewer.exe');
    RegWriteStringValue(HKEY_CLASSES_ROOT, 'ITLPDF.Document\Shell\Open\Command', '(Default)', ExpandConstant('{app}')+'bin\PDFViewer.exe'+ ' %%1');

    RegWriteStringValue(HKEY_CLASSES_ROOT, '.pdf', '(Default)', 'ITLPDF.Document');
    Log('Sumatra pdf is now default pdf reader')
  end;
end;

//====================
//create Beta License
//====================
procedure createLicense();
var
  ResultCode:integer;
begin
  Log('Check for V4 Beta License');
  if Exec(WizardDirValue+'\ConvertV4BetaLicense.exe', '/c', '',SW_SHOW, ewWaitUntilTerminated, ResultCode) then begin
    Log('Result code from COnvertV4BetaLicense was '+inttostr(ResultCode));
    if ResultCode = 0 then begin
      Log('v4.0 Beta License converted');
    end;
  end;
end;

//=============================================
//Setup Environment Variables and Registry Keys
//==============================================

procedure setupEnvVars();
var
  ResultCOde:integer;
begin
    if OS = 64 then begin
      SETX_PATH:=ExpandConstant('{app}')+'\bin\setx64.exe'
    end
    else begin
      SETX_PATH:=ExpandConstant('{app}')+'\bin\setx32.exe';
    end;

    Exec(SETX_PATH, ENABLER_ROOT+ ' ' + ExpandCOnstant('{app}')+ ' -M', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    Exec(SETX_PATH, ENABLER_LOG+ ' ' + ExpandCOnstant('{app}')+ '\Log -M', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    Exec(SETX_PATH, ENABLER_DB_INSTANCE_NAME + ' ' + SQL_INSTANCE + ' -M', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);

    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'DatabaseInstanceName', SQL_INSTANCE);
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'Enabler_Log', ExpandConstant('{app}')+'Log');
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'Root', ExpandConstant('{app}'));

    //and now the files
    if WINDOWS_BASE_VERSION < 5 then begin
      //should we install these to SYSTEM32?
      Log('Installing on Windows '+ WINDOWS_VERSION + ' installing extra DLLs');
    end;

    DeleteFile(ExpandConstant('{app}')+'Release Notes.html');   
end;

//================================
//update system config
//================================

//TODO - whatever this is?
//All OCX/DLL/EXE files that are self-registered
//Self-Register OCXs/DLLs/EXEs

//Enabler v4 configure default regsitry key for Client Username and Password
procedure updateSystemConfig();
begin
  if COMPONENTS = 'B' then begin
    //SERVER installation
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER\Client', 'Hostname', 'localhost');
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER\Client', 'Password', 'Default');
  end
  else begin
    //client intallation
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\ENABLER\Client', 'Hostname', SERVER_NAME);
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\ENABLER\Client', 'Password', 'Default');
  end;
end;


//=====================================================
// Setup Access Permission
//=====================================================
procedure setupAccessPermission();
var 
  LOGTIME:String;
  LOGTIME2:String;
  ResultCode:Integer;
  CLIENTEMBEDDED:String;//remain problem
  SERVER:String;   //not sure

Begin

  Exec('net.exe', 'localgroup /add EnablerAdministrators', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
  if SILENT = false then begin
    MsgBox('The Enabler', mbinformation, mb_OK);
  End;
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

  Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', ' /file'+ExpandConstant('{sys}')+'\eventvwr.msc /grant='+BUILTIN_USERS_GROUP+'= /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
  Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', ' /file'+ExpandConstant('{sys}')+'\config\Enabler.evt /grant='+BUILTIN_USERS_GROUP+'= /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
  Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', ' /subdirectories=directoriesonly '+ExpandConstant('{app}')+'\log /grant=EnablerAdministrators=F /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
  Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', ' /subdirectories=directoriesonly '+ExpandConstant('{app}')+'\log\*.* /grant=EnablerAdministrators=F /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);

  Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', ' /subdirectories=directoriesonly '+ExpandConstant('{app}')+'\ /grant=EnablerAdministrators=F', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
  Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', ' /file'+ExpandConstant('{app}')+' /grant=EnablerAdministrators=F', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);

  Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', '/subdirectories=filesonly'+ExpandConstant('{app}')+'\*.* /grant=EnablerAdministrators=F /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
  Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', '/file'+ExpandConstant('{sys}')+'%\eventvwr.msc /grant=EnablerAdministrators=E /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
  Exec(ExpandConstant('{app}') + '\bin\subinacl.exe', '/file'+ExpandConstant('{sys}')+'\config\Enabler.evt /grant=EnablerAdministrators=F /pathexclude=C:\*.*', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);

  LOGTIME2 := GetDateTimeString('dd/mm/yyyy hh:nn:ss', '-', ':');
  Log(Format('End of setting permissions %s', [LOGTIME2]));

  if SILENT = false then Begin
    MsgBox('The Enabler', mbinformation, mb_OK);
  End;

  if COMPONENTS = 'B' then Begin
    MsgBox('Skip', mbinformation, mb_OK);
    //Log('Installing or Updating EnablerDB');
    //if SILENT = false then Begin
    //  MsgBox('The Enabler', mbinformation, mb_OK);
    //End;
    //Exec(ExpandConstant('{app}') + '\bin\psrvr4.exe', '/servuce', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    //Exec(ExpandConstant('{app}') + '\bin\enbweb.exe', '/install', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    //Log('Update Services Start timout setting');
    //RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control','WaitToKillServiceTimeout','180000');
    //if SILENT = false then Begin
    //  MsgBox(' ', mbinformation, mb_OK);
    //End;
  End
  Else Begin
    if SILENT = false then begin
      MsgBox(APPTITLE, mbinformation, mb_OK);
    End;
    Log('Registering Enabler objects');
    Exec('rsgsvr32.exe', '/s '+ExpandConstant('{app}')+'\EnbSessionX2.OCX', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    if CLIENTEMBEDDED <> 'A' then begin
      sleep(2000);
      Log('Configuring DCOM');
      If SERVER_NAME = '' then begin
        Log('WARNING: no server name given - setting to default value SERVER');
        SERVER := SERVER_NAME
      End;

      if SQL_INSTANCE = '' then begin
        Exec(ExpandConstant('{app}')+'\bin\odbcnfg.exe', '/s '+SERVER_NAME, '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
        if OS = 64 then begin
          Exec(ExpandConstant('{app}')+'\bin\odbcnfg64.exe', '/s '+SERVER_NAME, '', SW_SHOW, ewWaitUntilTerminated, ResultCode);      
        End;
      End 
      else begin
        Exec(ExpandConstant('{app}')+'\bin\odbcnfg.exe', '/s '+SERVER_NAME+ '/i'+ SQL_INSTANCE, '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
        if OS = 64 then begin
          Exec(ExpandConstant('{app}')+'\bin\odbcnfg64.exe', '/s '+SERVER_NAME+ '/i'+ SQL_INSTANCE, '', SW_SHOW, ewWaitUntilTerminated, ResultCode);      
        End;
      end;
    End;

    if SILENT = false then begin
      MsgBox('', mbinformation, mb_OK);
    end
  End;

End;
  
//=======================================================================
//Reboot system to disable fast startup and change system power settings
//This should be the last thing to do.
//=========================================================================

function NeedRestart():Boolean;
begin
  if RESTART_DECISION then begin
    Result:=True;
  end
  else
    Result:=False;
end;

procedure decideReboot();
var
  ResultCode:integer;
begin
  //Only change setting for server
  if COMPONENTS = 'B' then begin
    //SERVER INSTALL
    //Get registry value for fast startup
    RegQueryStringValue(HKEY_LOCAL_MACHINE, 'System\CurrentCOntrolSet\Control\Power', 'HibernateEnabled', FAST_STARTUP);
  
    Log('Fast startup setting is: ' + FAST_STARTUP);
    if FAST_STARTUP <> '0' then begin
      //use powercfg to disable Fast startup. Editing of registry does NOT work for all OS
      Exec('CMD.EXE', '/C powercfg.exe -H off', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
      Log('Updating registry setting to disable fast startup');
    end;

    //force to disable ALL other sleep settings for all devices
    Exec('CMD.EXE', '/C powercfg.exe -change -standby-timeout-ac 0', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    Exec('CMD.EXE', '/C powercfg.exe -change -standby-timeout-dc 0', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    Log('Update standby TO to 0 to prevent system going to sleep');

    Exec('CMD.EXE', '/C powercfg.exe -change -hibernate-timeout-ac 0', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    Exec('CMD.EXE', '/C powercfg.exe -change -hibernate-timeout-dc 0', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    Log('Update hibernate TO to 0 to prevent system hibernation');
  end;

  //log silent setting
  Log('Silent setting is '+inttostr(integer(SILENT)));

  //finalizes the install
  //if UNATTENDED = '0' then begin
    //show custom dialog 'FINISHED' - inno does this for us
  //end;

  Log('Install is finished');
  //Add uninstall details to the registry...
  //NOTE: This registry edit does the setup for Windows Add/Remove Programs, so these will be redundant
  //for the new install script. Though if you're upgrading and these keys are present they should
  //probably be removed (after installing the new version you can't uninstall the old one).
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\'+APPTITLE, 'Comments', 'Windows-based Forecourt Control by Integration Technologies Limited.');
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\'+APPTITLE, 'Publisher', 'Integration Technologies Limited.');
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\'+APPTITLE, 'URLInfoAbout', 'https://www.integration.co.nz/support/');
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\'+APPTITLE, 'DisplayIcon', ExpandConstant('{app}')+'itl.ico,-0');

  RESTART_DECISION:=false;
  //reboot the PC
  if FAST_STARTUP <> '0' then begin
    if SILENT = false then begin
    Log('Rebooting system to disable fast startup');
    //reboot system
    //!!!This should be the ONLY TIME IN THE SCRIPT THAT THIS VARIABLE CAN BE SET TO TRUE
    RESTART_DECISION:=True;
    end
    else begin
    Log('Reboot required to disable fast startup');
    Abort();
    end;
  end;

  if SILENT = true then begin
    //this error code only for silent mode install
    ERROR_RTN := false;
  end;

  //decide whether we should start things
  DO_START_ACTIONS:= 1;
  If COMPONENTS = 'B' then begin
    //for server installs we only start things if the server is running
    if pos('Running', RUNNING) = 0 then begin
      DO_START_ACTIONS:= 0;
    end;
  end;

  //start things the installer asked for
  if DO_START_ACTIONS = 1 then begin
    if pos('A', START_MPP) <> 0 then begin
      Exec(ExpandConstant('{app}')+'mppsim.exe', '', '', SW_SHOW, ewNoWait, ResultCode);
    end;
    if pos('A', START_PUMP) <> 0 then begin
      Exec(ExpandConstant('{app}')+'PumpDemoWPF.exe', '', '', SW_SHOW, ewNoWait, ResultCode);
    end;
    if pos('A', OPEN_WEB) <> 0 then begin
      if SERVER_NAME = '' then begin
        Exec('CMD.EXE', '/C start http://localhost:'+ENBWEB_PORT, '', SW_SHOW, ewNoWait, ResultCode);
      end
      else begin
        //Note that this could be a PC server (port 8081) or EMB (port 80)
        Exec('CMD.EXE', '/C start http://'+SERVER_NAME+ENBWEB_PORT_STR, '', SW_SHOW, ewNoWait, ResultCode);
      end;
    end;
  end;
end;

//========================================
//initialize setup
//========================================

//runs first
function InitializeSetup(): Boolean;
begin
  variableInitialisation();
  parseCommandLineOptions();
  startupProcessing();
  returnFromRestart();
  checkWindowsVersion();
  checkFileSystem();
  checkDiskSpace();

  Result := True; // Inno setup doesn't proceed to next step if true is not returned.  
end;

//=========================
//Initialize Wizard
//=========================
procedure InitializeWizard();
begin
  createReadMePage();
  createPageInstallType();
  createClientSelectedPage();
  createInstanceNamePage();
  createNoServerInstalledPage();
  createSAPasswordPage();
  createNetworkPortPage();
end;


//========================================
// PrepareToInstall. The last wizard page before installation (stays hidden).
//========================================
function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  // Set the main and backup directory as the last step in the wizard. 
  MAINDIR:=ExpandConstant('{app}');
  BACKUP:=MAINDIR+'\BACKUP';

end;

//================================================================
//performs tasks just before and just after the bulk of the install
//================================================================

procedure CurStepChanged(CurStep:TSetupStep);
begin
  
  

  if CurStep = ssInstall then begin
    //this is commented out for now due to a bug in this module
    //saveConfig();
    installNet3Point5();
  end;
  if CurStep = ssPostInstall then begin
    //cplusplus();
    removeRegistryVars();
    installEnablerFiles();
    createLicense();
    setupEnvVars();
    basicPDFFiles();
    SDKFiles();    
    updateSystemConfig();
    //setupAccessPermission();
    logUninstallItems();
    decideReboot();
  end;  
end;

//========================================
// Deinitialise setup. Called just before install finishes.
//========================================
procedure DeinitializeSetup();
begin
  basicPDFFiles();
  MoveLogFile();
end;

  