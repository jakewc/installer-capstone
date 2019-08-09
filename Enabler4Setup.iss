[Setup]
AppName=Enabler4
AppVersion=1.0
AppId={{95EC957B-DB36-4EDD-9C7C-B19F896CC37D}
AppPublisher=Integration Technologies Limited
AppPublisherURL=https://integration.co.nz/
DefaultDirName={commonpf}\Enabler4
OutputBaseFilename=Enabler4Setup
SetupLogging=yes
DisableWelcomePage=no


[Files]
; The following two lines are for testing the installer adds the files applicable for the installation type (client or server).
Source: "InputClientInstall\*"; DestDir: "{app}"; Flags: ignoreversion createallsubdirs recursesubdirs; Check: IsInstallType('A');
Source: "ForTestPurposesOnly\SqlServerMockInstall.exe"; DestDir: "{app}\ForTestPurposesOnly"; Check: IsInstallType('B');

[Run]
; Test the running of an executable file if a server installation is selected in the wizard.
Filename: "{app}\ForTestPurposesOnly\SqlServerMockInstall.exe"; Check: IsInstallType('B');


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

[Code]
var
  // Installer variables. 
  appName: string;
  components: string;

  // Installation Type page variables.
  pageInstallType: TwizardPage;
  radioClient,radioServer: TRadioButton;
  lblClient, lblServer: TLabel;



function InitializeSetup(): Boolean;
begin
  appName := '{#SetupSetting("AppName")}';

  //===================================
  // Initialise variables.
  //===================================

  Log('Initialising variables.');
  
  Result := True;
end;


// Handle client radio button click on Installation Type page.
procedure RadioClientClicked(Sender: TObject);
begin
  components := 'A';  // Client install.
end;


// Handle server radio button click on Installation Type page.
procedure RadioServerClicked(Sender: TObject);
begin
  components := 'B';  // Server install.
end;


// Create the wizard page that asks the user for the type of install they want.
procedure CreateInstallationTypePage();
begin
  pageInstallType := CreateCustomPage(wpWelcome, 'Select Installation Type', 'Select the type of install you would like from the radio buttons.');

  radioClient := TRadioButton.Create(pageInstallType);
  radioClient.Parent := pageInstallType.Surface;
  radioClient.Caption := 'Client Install';
  radioClient.Checked := True;  // Set the default to a client install.
  components := 'A'; // 'A' components are client install components.
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

end;


procedure InitializeWizard();
begin
  CreateInstallationTypePage;
end;


// Returns true if the installation type is the type passed to the function.
function IsInstallType(installType: String): Boolean;
begin
  if components = installType then 
    Result := True
  else
    Result := False; 
end;


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


// Called just before Setup terminates. 
procedure DeinitializeSetup();
begin
  MoveLogFile();
end;

//SQL SETUP