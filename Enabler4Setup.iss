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
 
 
; This varaible forces applications to be installed even if the SDK options is not avaliable or selected
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
AppVersion=1.0
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


[Files]
;compresses the readme file into the intaller if client selected for testing purposes
Source: "{#SourcePath}\readme.md"; DestDir: "{app}"; Flags: ignoreversion createallsubdirs recursesubdirs; Check: IsInstallType('A');


[Run]
; Test the running of an executable file if a server installation is selected in the wizard.
Filename: "{#SourcePath}\ForTestPurposesOnly\SqlServerMockInstall.exe"; Check: IsInstallType('B');

[Messages]
;Change the message on the standard welcome page
WelcomeLabel1=Welcome to The Enabler Setup Program. %nThis Program will install The Enabler on your computer.
WelcomeLabel2=We Recommend that you exit all Windows programs before running this Setup Program. %n%nClick Cancel to quit Setup and close any programs you have running. Click Next to continue with the Setup program. %n%nWARNING: This program is protected by copyright law and international treaties. %n%nUnauthorized reproduction or distribution of this program, or any portion of it, may result in severe civil and criminal penalties, and will be prosecuted to the maximum extent possible under law.


[Code]

//========================================
//variable initializations
//========================================
var
  
  //Pages MUST be initialized here as they need to know each other to be presented in the right order

  // Installer variables.
  appName: string;
  components: string;

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
  SILENT:Boolean;
  PHASE2:Boolean;

  {Initialise fast startup variables}
  FAST_STARTUP:Boolean;

  {Initialise variables for detecting Adminstrator and User group}
  BUILTIN_USERS_GROUP:String;
  BUILTIN_ADMINISTRATORS_GROUP:String;

  {SHOW_USAGE indicates whether we should display a dialog describing the
   installer command-line usage}
  SHOW_USAGE:Boolean;

  //Read Me Page  
  readMePage: TOutputMsgMemoWizardPage;
  releaseNotesButton: TNewButton;

  //install type page
  pageInstallType: TwizardPage;
  radioClient,radioServer: TRadioButton;
  lblClient, lblServer, lblSDK: TLabel;
  sdkCheckBox: TNewCheckBox;
  sdk:Boolean;

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
//installer-wide functions
//======================================== 


// Returns true if the installation type is the type passed to the function.
function IsInstallType(installType: String): Boolean;
begin
  if components = installType then 
    Result := true
  else
    Result := false;
   
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


procedure variableInitialisation ();
begin
  DRIVERCODE:=0;
  APPNAME := '{#SetupSetting("AppName")}';
  APPTITLE:='The Enabler';
  GROUP:='The Enabler';
  DISABLED:='!';
  MAINDIR:='Enabler';
  MAINDIR:='C:\'+ MAINDIR;       
  BACKUP:=MAINDIR+'\BACKUP';
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
  SILENT:=False;
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
  sdk:=true;
end;

procedure createPageInstallType();
  
begin
  pageInstallType := CreateCustomPage(wpSelectComponents, 'Select Installation Type', 'Select the type of install you would like from the radio buttons. SDK is optional.');

  radioClient := TRadioButton.Create(pageInstallType);
  radioClient.Parent := pageInstallType.Surface;
  radioClient.Caption := 'Client Install';
  radioClient.Checked := True;  // Set the default to a client install
  components:='A';
  radioClient.OnClick := @RadioClientClicked;

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
end;

//========================================
//functions for install warning page
//========================================

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String; 
begin
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
  password:=SAPasswordPage.Edits[0].Text;
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
//functions for logger
//========================================

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


//========================================
//initialize/deinitialize setup
//========================================

//runs first
function InitializeSetup(): Boolean;
begin
  appName := '{#SetupSetting("AppName")}';
  Log('Initialising variables.');
  variableInitialisation();
    
  Result := True; // Inno setup doesn't proceed to next step if true is not returned.
end;

//runs wizard
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


// Called just before Setup terminates. 
procedure DeinitializeSetup();
begin
  MoveLogFile();
end;

  