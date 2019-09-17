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
;Source: "InputClientInstall\*"; DestDir: "{app}"; Flags: ignoreversion createallsubdirs recursesubdirs; Check: IsInstallType('A');
Source: "ForTestPurposesOnly\SqlServerMockInstall.exe"; DestDir: "{app}\ForTestPurposesOnly"; Check: IsInstallType('B');
Source: "InputServerInstallFiles\Instances.bat"; DestDir: "{app}"; Check: IsInstallType('B');

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

  // The default is for none of the apps to be installed without the SDK option selected
  SDK_OPTIONS: integer;

  //OS_ARCHITECTURE variable to store the os architecture (32 or 64)
  OS: integer;
  OS_ARCHITECTURE: string;
  OS_ARCHITEW6432: string;
  OPERATING_SYSTEM: Longint;
  //Initialise unattended variables

  UNATTENDED: integer;
  SILENT: integer;
  PHASE2: integer;

  // Installation Type page variables.
  pageInstallType: TwizardPage;
  radioClient,radioServer: TRadioButton;
  lblClient, lblServer: TLabel;
 
 // OSQL_PATH stores the path to OSQL.EXE
  OSQL_PATH: string;

  SQL_NEEDED: integer;

  SQLEXPRESSNAME: string;

  SQLEXPRESSFULLNAME: string;

//This will store the value of the OS 
procedure SetArchictureVariables();
   begin
      if ProcessorArchitecture  = paX64 then
          begin
              OS_ARCHITECTURE := 'paX64';
              OS:= 64;
          end
      else if ProcessorArchitecture = paIA64 then
          begin
             OS_ARCHITECTURE := 'paIA64';
             OS:= 64;
          end
      else if ProcessorArchitecture = paX86 then
          begin
             if IsWin64 then
                begin
                   //Installing driver from 32-bit installer on 64-bit OS (WOW64)
                   OS:= 64;
                   OS_ARCHITEW6432:= 'AMD64';
                end
             else
                begin
                   //Installing driver from 32-bit installer on 32-bit OS
                   OS:= 32;
                end
          end
   end;

//checks if windows is 8.1 or later
function IsWindows8OrLater: Boolean;
begin
  Result := (GetWindowsVersion >= $06020000);
end;

function CheckWindowsVersion: Longint;
  var versionString: string;
  var versionInt: Longint;
  begin
     versionString := GetWindowsVersionString;
     versionInt:= StrToInt(versionString); 
     Result:= versionInt;
  end;

//sets the operating system variable
procedure setOperatingSystemVariable();
   begin
      (* We will set this variable according to the 'Windows Current Version'Registry Key 87 
         NOTE: The Registry Key is: \\HKLM\Software\Microsoft\Windows NT\CurrentVersion\(CurrentVersion) - it contains a number.
         NOTE: Windows 10 returns a value of 6.3 for backwards compatibility. Indicates its Windows 8.1 *)
            OPERATING_SYSTEM:= CheckWindowsVersion;
   end;
    
//SQL SERVER SETUP

//checks if sql 2016 can be installed
procedure CheckIfSQL2016CanBeInstalled();
    begin
       if  SQLEXPRESSNAME <> 'SQL2014' then
          begin
             //If SQL2016 available and 64bit and not Windows 7 then use it instead
             if DirExists('SQL2016') then
                if OS = 64 then
                   if IsWindows8OrLater then
                      begin
                          SQLEXPRESSNAME:= 'SQL2016';
                          Log('Folder SQL2016 found, so this will be installed.');
                      end    
          end
    end;


procedure UpdateSystem();
  var
    ResultCode: Integer;
    KB_FIND1: Integer;
    KB_FIND2: Integer;
begin
             if SQLEXPRESSNAME = 'SQL2016' then
                begin
                  Log('Checking SQL2016 requirements for Windows 8.1 or Server 2012 64 bit'); 
                  //Execute C:\WINDOWS\Sysnative\CMD.EXE /C wmic qfe get HotFixId | find "KB2919355" (Wait);
                  Exec('CMD.EXE', '/C wmic qfe get HotFixId | find "KB2919355"', 'C:\WINDOWS\Sysnative\', SW_SHOW, ewWaitUntilTerminated, ResultCode);
                  KB_FIND1:= ResultCode;
                  //570 /* Execute C:\WINDOWS\Sysnative\CMD.EXE /C wmic qfe get HotFixId | find "KB2919442" (Wait)
                  Exec('CMD.EXE', '/C wmic qfe get HotFixId | find "KB2919442"', 'C:\WINDOWS\Sysnative\', SW_SHOW, ewWaitUntilTerminated, ResultCode);
                  KB_FIND2:= ResultCode;
                  Log('Result of Windows update finds %KB_FIND1%');
                  if KB_FIND1 = 1 then
                     begin
                       MsgBox('Requirements for SQL2016 not met', mbError, MB_OK);
                       Log('Windows 8.1 or Server 2012 requires system updates to install SQL2016 (KB2919355)"');
                       Exit;
                     end;
           end;
end;

procedure DoesSystemNeedWindowsUpdates();
(* - Check if the system needs Windows updates before runing Enabler
install
   - Windows 8.1 64 bit & Windows Server 2012 require updates before
SQL2016 installed*)

  begin
     if IntToStr(OPERATING_SYSTEM)='6.3.9200' then
        begin
         if OS = 64 then
           begin
            UpdateSystem();
           end;
        end;
  end;


procedure SqlServerSetup();
    begin
       //Some initial checks are required to determine the wizard flow relating to the SQL install
       OSQL_PATH := FileSearch('osql.exe', GetEnv('PATH'));
       Log('Location of OSQL.EXE is' + OSQL_PATH + ' (Initial Checks)');
       if OSQL_PATH = '' then
          begin
            // DETECT SQL SERVERS AVAILABLE TO INSTALL
             //SQL NEEDED
            
            SQL_NEEDED:= 1;
            // Try SQL2014 first
            if DirExists('SQL2014') then
               begin
               SQLEXPRESSNAME:= 'SQL2014';
               Log('Folder SQL2014 found, so this will be installed.');
               end
            //Try SQL2012 next
            else if DirExists('SQL2012') then
                begin
                  SQLEXPRESSNAME:= 'SQL2012';
                  Log('Folder SQL2012 found, so this will be installed.');
                end
            //Try SQL2008R2 next
            else if DirExists('SQL2008R2') then
                begin
                  SQLEXPRESSNAME:= 'SQL2008R2';
                  Log('Folder SQL2008R2 found, so this will be installed.');
                end
            //Try SQL2005 next
            else if DirExists('SQL2005') then
                begin
                   SQLEXPRESSNAME := 'SQL2005';
                   Log('Folder SQL2005 found, so this will be installed.');
                end
            //Try MSDE finally
            else if DirExists('MSDE2000') then
                begin
                       SQLEXPRESSNAME := 'MSDE2000';                  
                       Log('Folder MSDE2000 found, so this will be installed.');
                end
            else
                begin
                       Log('ERROR: MSDE not found - cannot install server without SQL (Expected in MSDE2000)');
                       SQLEXPRESSNAME:= '';
                end;   
          //If SQL2014 already detected, then no more additional checks. Otherwise, check if we can use SQL Server 2016 
          CheckIfSQL2016CanBeInstalled();
          Log ('SQL server folders parsed SQL server to install ' + SQLEXPRESSNAME  + ' Architecture=' + IntToStr(OS) +  ' Windows version= ' + GetWindowsVersionString ); 
          SQLEXPRESSFULLNAME := SQLEXPRESSNAME;
          if SQLEXPRESSNAME<> 'MSDE2000' then
             begin
                  SQLEXPRESSFULLNAME:= SQLEXPRESSNAME;
             end;
          Log ('SQLEXPRESSNAME ' + SQLEXPRESSNAME);
          DoesSystemNeedWindowsUpdates(); 
          end
        else
           begin       
              Log('SQL SERVER ALREADY INSTALLED');
              Exit; 
           end 
    end;

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
  SqlServerSetup(); //calls the procedure to setup sql
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