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

  // MAINDIR is the variable that holds the default destination directory
  MAINDIR : string;

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
 
  // SQL Named Instance name
  SQL_SERVERS: string;

  // SQL Named Instance name
  SQL_INSTANCE: string;
  CLIENT_SQL_INSTANCE: string;
  PC_NAME: string;
  SQLQUERY: string;
  INSTANCE_NAME_NEEDED: integer;
  INSTANCE_NAME_LIST: integer;
  CMD_INSTANCE: string;
  SQL_INSTANCES: string;

 // OSQL_PATH stores the path to OSQL.EXE
  OSQL_PATH: string;

  SQL_NEEDED: integer;

  SQLEXPRESSNAME: string;

  SQLEXPRESSFULLNAME: string;

// A variable for displaying progress message
  ProgressPage: TOutputProgressWizardPage;


//This will store the value of the OS 

function CommandPromptExecutor(Command: String): Integer;
  var 
     ResultCode: Integer;
     INSTALL_RESULT: Integer;
     Check: Boolean;
  begin
      Check:= Exec('CMD.EXE', Command, 'C:\WINDOWS\Sysnative\', SW_SHOW, ewWaitUntilTerminated, ResultCode);
      if Check then
        begin
          INSTALL_RESULT:= 1;
        end
      else
        begin
          INSTALL_RESULT:= 0;
        end;
      Result := INSTALL_RESULT;

  end;



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
    INSTALL_RESULT: Integer;
begin
             if SQLEXPRESSNAME = 'SQL2016' then
                begin
                  Log('Checking SQL2016 requirements for Windows 8.1 or Server 2012 64 bit'); 
                  //Execute C:\WINDOWS\Sysnative\CMD.EXE /C wmic qfe get HotFixId | find "KB2919355" (Wait);
                  INSTALL_RESULT:= CommandPromptExecutor('/C wmic qfe get HotFixId | find "KB2919355"');
                  KB_FIND1:= INSTALL_RESULT;
                  //570 /* Execute C:\WINDOWS\Sysnative\CMD.EXE /C wmic qfe get HotFixId | find "KB2919442" (Wait)
                  INSTALL_RESULT:= CommandPromptExecutor('/C wmic qfe get HotFixId | find "KB2919442"');
                  KB_FIND2:= INSTALL_RESULT;
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

//This will display progress message
procedure DisplayMessage(Caption: String; Description: String; Duration: Integer);
    var
      I: Integer;
    begin
        if SILENT =0 then
           begin
                ProgressPage.SetText(Caption, Description);
                ProgressPage.SetProgress(0, 0);
                ProgressPage.Show;
              try
                  for I := 0 to Duration do begin
                    ProgressPage.SetProgress(I, Duration);
                    Sleep(100);
                  end;
              finally
                  ProgressPage.Hide;
                end;
           end;
    end;

function getTemporaryFilenameIntoInstances(): Integer;
  var
    path: string;
    INSTALL_RESULT: Integer;
  begin
     //Rem Server SQL ettings
     // Get Registry Key SOFTWARE\Microsoft\Microsoft SQL Server place in
     // Variable SQL_INSTANCES If SQL_INSTANCES <> '' then Get Temporary Filename into INSTANCES
     if (OS = 64) and (OPERATING_SYSTEM >= 6) then
        begin
            path:= '/C ' + '%' + MAINDIR + '%\Instances.bat%TEMP%\%INSTANCES%';
            INSTALL_RESULT:= CommandPromptExecutor(path);
        end
     else
        begin
            INSTALL_RESULT:= CommandPromptExecutor(path);
        end;
     Result:= INSTALL_RESULT;

  end;


procedure SetInstanceNameNeeded();
  var
    INSTALL_RESULT: Integer;
    LINE: string;
    NAME: string;
    SQL_INSTANCES: string;

  begin
     INSTALL_RESULT:= getTemporaryFilenameIntoInstances();
     if INSTALL_RESULT <> 0 then
        begin
             Log('Unable to get SQL Instance Name registry key. '+ IntToStr(INSTALL_RESULT));
             INSTANCE_NAME_NEEDED:= 1;
        end
     else
        begin
          
          //Read lines of file %TEMP%\%INSTANCES% into variable LINE Start
          //Block
          // If Expression True "Instr(LINE,"!") Or Instr(Line,"\") Or  Line=""" then
          // Else
          //Parse String "%LINE%" into NAME and
          if NAME='MSSQLSERVER' then if INSTANCE_NAME_NEEDED=1 then
            begin
              INSTANCE_NAME_NEEDED:= 0;
            end
          else if NAME='SQLEXPRESS' then if NAME='MSSQLSERVER' then if INSTANCE_NAME_NEEDED = 1 then
            begin
              SQL_INSTANCE:= 'SQLEXPRESS';
              SQLQUERY:= PC_NAME + '\' + SQL_INSTANCE;
              INSTANCE_NAME_NEEDED:= 0;
            end;
          //Build list of instances names in case they need to be displayed
          SQL_INSTANCES:= NAME + '\n';
        end;
  end;

  

procedure CheckKnownInstances();
  begin
      //Check if we found a known instance, if we haven't do we have
      //a list of instances
      if INSTANCE_NAME_NEEDED=1 then if Length(Trim(SQL_INSTANCES)) > 0 then
        begin
          //We have fouind instance names, if we haven't found a default one we need to display the list
          INSTANCE_NAME_LIST:= 1;
        end;
      if Length(Trim(SQL_INSTANCES)) <= 0 then
        begin
          Log('No SQL Instance names found');

        end;
  end;

// do this iff we found no available instances
procedure OsqlDetectDefaultSqlNamedInstances();   
  begin
    if INSTANCE_NAME_LIST <> 1 then if INSTANCE_NAME_NEEDED = 1 then

  end;

procedure GetListOfNamedInstances();

  begin
     GetTemporaryFilenameIntoInstances();
     SetInstanceNameNeeded();
     CheckKnownInstances();
     OsqlDetectDefaultSqlNamedInstances();     
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

              Log('OSQL has been found SQL SERVER ALREADY INSTALLED');
              SQL_NEEDED := 0;
              DisplayMessage('The Enabler', 'The Enabler', 5);
              GetListOfNamedInstances();

              
           end 
    end;


//LINE 904-1010
//MSI4.5 Install
procedure InstallMSI();
  var 
    MSI_VERSION: string;
    INSTALL_RESULT: Integer;

  begin

    if components='B' then  if SQL_NEEDED<>0 then
        //Check the version of MSI installed - .NET3.5 requires 4.5
        GetVersionNumbersString(GetSystemDir+'\msi.dll', MSI_VERSION);
        Log('MSI version: ' + MSI_VERSION);
        if StrToFloat(MSI_VERSION) < 4.5 then
            begin
                Log('SQL2008R2 requires MSI 4.5 and .NET 3.5 SP1 - MSI will be installed and will require a reboot.')
                //Check if we need to install the latest MSI 4.5 Installer
                if (FileExists('{app}\Win\MSI\4.5\WindowsXP-KB942288-v3-x86.exe'))<>'True' then
                  begin
                    if SILENT=0 then
                      begin
                       MsgBox('MSI 4.5 Installer Failed', mbInformation, MB_OK);
                       Log('Missing MSI 4.5 Installer');
                       //Exit Installation
                       Abort();
                      end
                  end
                if SILENT=0 then
                  begin
                     MsgBox('Installing MSI 4.5 Installer');
                     Log('Installing MSI 4.5');
                     if OPERATING_SYSTEM=5.1 then
                       begin
                        //NOTE: 5.1 = Windows XP
                        if OS = 32 then
                          begin
                              INSTALL_RESULT := CommandPromptExecutor('{app}\Win\MSI\4.5\WindowsXP-KB942288-v3-x86.exe');
                          end
                        else
                          begin
                              INSTALL_RESULT := CommandPromptExecutor('{app}\Win\MSI\4.5\WindowsServer2003-KB942288-v4-x64.exe');
                          end
                       end
                     if OPERATING_SYSTEM = 5.2 then
                        begin
                           //NOTE 5.2 = Windows 2003
                           if OS = 32 then
                              begin
                                 INSTALL_RESULT := CommandPromptExecutor('{app}\Win\MSI\4.5\WindowsServer2003-KB942288-v4-x86.exe');
                              end
                           else
                              begin
                                 INSTALL_RESULT := CommandPromptExecutor('{app}\Win\MSI\4.5\WindowsServer2003-KB942288-v4-x64.exe');
                              end
                        end
                     if OPERATING_SYSTEM = 6.0 then
                        //NOTE: 6.0 = Windows Vista or Windows Server 2008
                        //NOTE: msu files do not support the /passive switch
                        begin
                          if OS = 32 then
                            begin
                                INSTALL_RESULT := CommandPromptExecutor('{app}\Win\MSI\4.5\Windows6.0-KB942288-v2-x86.msu');

                            end
                          else
                            begin
                                INSTALL_RESULT := CommandPromptExecutor('{app}\Win\MSI\4.5\Windows6.0-KB942288-v2-x64.msu');
                            end
                        end
                     if OPERATING_SYSTEM >= 6.0 then
                        //NOTE: NOTE: 6.1 = Windows 7 and Windows 2008 R2
                        begin
                            Log('Found either Windows 7, Windows Server 2008 or Later Windows - so dont need a newer version of MSI installed');
                            if SILENT = 0 then
                              begin
                                 MsgBox('Exiting', mbInformation, MB_OK);
                              end
                            //Exit Installation 
                            Abort(); 
                        end
                     if INSTALL_RESULT = 0 then
                        begin
                           Log('MSI 4.5 already installed');
                        end
                     else
                        // 3010 means Reboot is required. Set Runonce to Enabler Installer
                        if INSTALL_RESULT = 3010 then
                            begin
                               if SILENT = 0 then
                                  begin
                                     MsgBox('Rebooting', mbInformation, MB_OK); 
                                  end
                               // Add Registry Keys before rebooting
                               RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler', 'InstallPath', ExpandConstant('{app}');
                               //Stop adding this entry to the log file. This stops this being doing on uninstall.
                               //Rem If the RunOnce key is deleted on uninstall and then Enabler is reinstalled the driver will fail its install
                               //windows requires the runonce key to be present to install drivers
                               //Stop writing to installation log
                               // Registry Key SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce =
                               Log('MSI 4.5 installed - reboot pending');
                               //Reboot System
                               //Exit Installation

                            end
                        // 1603 means Windows OS platform is not supported.
                        if INSTALL_RESULT = 1603 then
                          begin
                             if SILENT = 0 then
                                begin
                                   MsgBox('MSI 4.5 Installer Failed');
                                   Log('MSI 4.5 Installation Failed - Windows OS Platform not supported.');
                                   //Exit Installation
                                end
                          end
                        else 
                          begin
                            if SILENT = 0 then
                                begin
                                   MsgBox('MSI 4.5 Installer Failed');
                                   Log('MSI 4.5 Installion Failed');
                                   //Exit Installation
                                end
                          end
                  end
            end
        else
          begin
             Log('The version of MSI is OK - '+ MSI_VERSION);
          end
               
  end;

function InitializeSetup(): Boolean;
begin
  appName := '{#SetupSetting("AppName")}';

  //===================================
  // Initialise variables.
  //===================================

  Log('Initialising variables.');
  INSTANCE_NAME_NEEDED:= 1;
  INSTANCE_NAME_LIST:= 0;
  MAINDIR:= 'C:\%MAINDIR%';
  PC_NAME:= GetComputerNameString();


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
