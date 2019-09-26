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
RestartIfNeededByRun=yes

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

  //SQL Server Major Product Number
  SQLVER_MAJOR : string;
  // MAINDIR is the variable that holds the default destination directory
  MAINDIR : string;
  
  // SA_PASSWORD stores the SA password (if any)
  SA_PASSWORD: string;

  // The default is for none of the apps to be installed without the SDK option selected
  SDK_OPTIONS: integer;

  //OS_ARCHITECTURE variable to store the os architecture (32 or 64)
  OS: integer;
  OS_ARCHITECTURE: string;
  OS_ARCHITEW6432: string;
  OPERATING_SYSTEM: Longint;
  //Initialise unattended variables

  DRIVERCODE : integer;
  UNATTENDED: integer;
  SILENT: integer;
  PHASE2: integer;


  //APPTITLE is the application title of the installation
  APPTITLE: string;

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
                if (FileExists('{app}\Win\MSI\4.5\WindowsXP-KB942288-v3-x86.exe'))<>True then
                  begin
                    if SILENT=0 then
                      begin
                       MsgBox('MSI 4.5 Installer Failed', mbInformation, MB_OK);
                       Log('Missing MSI 4.5 Installer');
                       //Exit Installation
                       Abort();
                      end
                  end;
                if SILENT=0 then
                  begin
                     MsgBox('Installing MSI 4.5 Installer', mbInformation, MB_OK);
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
                       end;
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
                        end;
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
                        end;
                     if OPERATING_SYSTEM >= 6.0 then
                        //NOTE: NOTE: 6.1 = Windows 7 and Windows 2008 R2
                        begin
                            Log('Found either Windows 7, Windows Server 2008 or Later Windows - so dont need a newer version of MSI installed');
                            if SILENT = 0 then
                              begin
                                 MsgBox('Exiting', mbInformation, MB_OK);
                              end;
                            //Exit Installation 
                            Abort(); 
                        end;
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
                                  end;
                               // Add Registry Keys before rebooting
                               RegWriteStringValue(HKEY_AUTO, 'Software\ITL\Enabler', 'InstallPath', ExpandConstant('{app}'));
                               //Stop adding this entry to the log file. This stops this being doing on uninstall.
                               //Rem If the RunOnce key is deleted on uninstall and then Enabler is reinstalled the driver will fail its install
                               //windows requires the runonce key to be present to install drivers
                               //Stop writing to installation log
                               // Registry Key SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce =
                               Log('MSI 4.5 installed - reboot pending');
                               //Reboot System
                               //Exit Installation

                            end;
                        // 1603 means Windows OS platform is not supported.
                        if INSTALL_RESULT = 1603 then
                          begin
                             if SILENT = 0 then
                                begin
                                   MsgBox('MSI 4.5 Installer Failed', mbInformation, MB_OK);
                                   Log('MSI 4.5 Installation Failed - Windows OS Platform not supported.');
                                   //Exit Installation
                                end
                          end
                        else 
                          begin
                            if SILENT = 0 then
                                begin
                                   MsgBox('MSI 4.5 Installer Failed', mbInformation, MB_OK);
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


//line 1160-1192
//  Checking installed Service Pack for Vista /Server 2008 when installing SQL 2012 only

procedure ServicePackInstallSQL2012();
  var
    VISTASP : string;
  begin
     if components = 'B' then
        begin
           if SQL_NEEDED =1 then
              begin
                 if SQLEXPRESSNAME = 'SQL2012' then
                    begin
                       if OPERATING_SYSTEM = 6.0 then
                            begin
                                  RegQueryStringValue(HKLM, 'Software\Microsoft\Windows NT\CurrentVersion', '', VISTASP);
                                  Log('Vista Build Number is ' + VISTASP);
                                  //NOTE: 6.0 = Windows Vista or Windows Server 2008
                                  //NOTE: msu files do not support the /passive switch
                                  if StrToInt(VISTASP) = 2 then
                                      begin
                                         //No SP installed
                                         //Installing SP1
                                         MsgBox('SQL2012 prerequisites not met', mbInformation, MB_OK);
                                         Log('ERROR: Vista has no required Service Packs installed, exiting installation');
                                         //EXIT INSTALLATION 
                                         Abort();
                                      end;
                                  if StrToInt(VISTASP) = 1616 THEN
                                      begin
                                          //No SP2 installed
                                          MsgBox('SQL2012 prerequisites not met', mbInformation, MB_OK);
                                          Log('ERROR: Vista does not have required Service Pack 2 installed, exiting installation');
                                          //EXIT INSTALLATION
                                          Abort();
                                      end
                            end
                    end
              end
        end
  end;


procedure DetectVersionSQLServersInstalled();
  // Make sure OSQL_PATH does not end in '\'
  var 
    TEMP : string;
    SQLINFO : string;
    INSTALL_RESULT : integer;
    CREATE_TEMP_FILE_RESULT : boolean; 
    LINE : AnsiString;

  begin
     (*Find out the version of SQL installed.block
      SQL 2000 and newer support the following method of getting the version
      Older versions do not. The Microsoft documentation for this method is at the link below
      http://support.microsoft.com/default.aspx?scid=kb;en-us;321185#3
      Create a temporary file to store the SQL results in.  *)
      TEMP := GetTempDir();
      SQLINFO := '\SQLINFO';
      SaveStringToFile(TEMP+SQLINFO, '', False);
      if SILENT = 0 then
        begin
           MsgBox('SQL Version', mbInformation, MB_OK);
           //Execute the sql to get the SQL version of a default instance or the instance name passed by the command line
           Log('Query database for version using server and instance name ' + SQLQUERY);
           INSTALL_RESULT := CommandPromptExecutor(OSQL_PATH + '\OSQL.EXE -b -E -S ' + SQLQUERY + ' -dmaster -h-1 -Q "select SERVERPROPERTY('+ '"productversion"' + ')" -o ' + TEMP + SQLINFO);
           if INSTALL_RESULT <> 0 then
              begin
                 if SILENT = 0 then
                    begin
                       MsgBox('SQL VERSION', mbInformation, MB_OK);
                       MsgBox('OSQL failed to execute', mbError, MB_OK);
                       Log(SQLQUERY + ' SQL server is not configured correctly the osql query failed');
                       Abort();
                    end
              end;
            //Read each line of the SQL query results
            LoadStringFromFile(TEMP + SQLINFO, LINE);
            if SQLVER_MAJOR = '' then
                begin
                   SQLVER_MAJOR := LINE;
                end;
            //Is SQL Server major revision greator than or equal to the number 8 (version 2000)
            if StrToFloat(SQLVER_MAJOR) >= 8 then
              begin
                Log('SQL Version found ' + SQLVER_MAJOR );
              end
            else
              //If the line read is greator than or equal to the number it is 2000 or newe
              begin
                 if StrToFloat(LINE) >= 8 then
                    begin
                       Log('SQL Version found ' + LINE);
                    end
                 else
                    begin
                       //Display the message to exit
                       if SILENT = 0 then
                          begin
                             MsgBox('A newer SQL Server is required', mbInformation, MB_OK);
                             Log('Exiting installation as Enabler requires newer version than ' + SQLVER_MAJOR + ' of SQL Server');
                             Abort();
                          end
                    end
              end
        end
  end;


procedure IsThereAnExistingEnablerInstall();
//Does the enabler database already exist?
  var
    PRE_UPGRADE_BACKUP : string;
    INSTALL_RESULT : integer;
  begin
     if PRE_UPGRADE_BACKUP = 'A' then
        begin
           INSTALL_RESULT := CommandPromptExecutor(OSQL_PATH + '\OSQL.EXE -d EnablerDB -E -S' + SQLQUERY + ' -Q "select count(*) from global_settings" -b');
           if INSTALL_RESULT = 0 then
              begin
                 Log('Preupgrade backup check for Enabler DB: Database FOUND');
              end
           else
              begin
                 Log('Preupgrade backup check for Enabler DB: Database NOT found');
                 PRE_UPGRADE_BACKUP := '';
              end
        end
  end;

procedure SQLServerIsRequired();
  //SQL SERVER IS REQUIRED
  var
    MSI_VERSION : string;
    DOTNET_VERSION : string;
    MDAC_VERSION : string;
    IEXPLORE_VERSION : double;

  begin
     //We know what if SQLServer is required and what version will be installed, so that optionally install MSI 4.5 and .NET
     if UNATTENDED = 0 then
        begin
           //SQL2005 PREREQUISITES
           if SQLEXPRESSNAME = 'SQL2005' then
              begin
                 Log('SQLServer2005 Express will be installed');
                 //Check SQL EXPRESS 2005 required components before SQL installation
                 //Fetch MSI version, .NET version information and MDAC version
                 GetVersionNumbersString(GetSystemDir+'\msi.dll', MSI_VERSION);
                 RegQueryStringValue('HKEY_LOCAL_MACHINE', 'SOFTWARE\Microsoft\.NETFramework\policy\v2.0\', 'Default', DOTNET_VERSION);
                 RegQueryStringValue('HKEY_LOCAL_MACHINE', 'SOFTWARE\Microsoft\DataAccess', 'Version', MDAC_VERSION);
                 //MDAC 2.8?
                 if StrToFloat(MDAC_VERSION) < StrToFloat('2.80.1022.3') then
                    begin
                       if SILENT = 0 then
                          begin
                             MsgBox('MDAC 2.8 Required by SQL2005', mbInformation, MB_OK);
                             Abort();
                          end
                    end;
                 //IE6 SP1?
                 if IEXPLORE_VERSION < StrToFloat('6.0.2800.1106') then
                   begin
                      if SILENT = 0 then
                          begin
                             MsgBox('IE 6.0 Service Pack 1 Required by SQL2005', mbInformation, MB_OK);
                             Log('IE 6.0 SP1 Required for SQL2005 Express');
                             Abort();
                          end
                   end
                   //THIS BLOCK OF CODE HAS BEEN COMMENTED OUT IN THE ORIGINAL SCRIPT
                (* /* Rem ==========================================
1344 /* Rem MSI 3.1?
1345 /* Rem ==========================================
1346 /* If MSI_VERSION Less Than "3.1.400.2435" then
1347 /* If File or Directory doesn't exist
%INST%\Win\MSI\3.1\WindowsInstaller-KB893803-v2-x86.exe ...
1348 /* If SILENT Equals "0" then
1349 /* Display Message "MSI 3.1 Installer Failed"
1350 /* End
1351 /* Add "Missing MSI 3.1 Installer" to INSTALL.LOG
1352 /* Exit Installation
1353 /* End
1354 /* If SILENT Equals "0" then
1355 /* Display Progress Message "Installing MSI 3.1 Installer"
1356 /* End
1357 /* Add "Installing MSI 3.1" to INSTALL.LOG
1358 /* Execute CMD.EXE /C
""%INST%\Win\MSI\3.1\WindowsInstaller-KB893803-v2-x86.ex...
1359 /* If INSTALL_RESULT Equals "0" then
1360 /* Add "MSI 3.1 Already Installed" to INSTALL.LOG
1361 /* Else
1362 /* Rem 3010 means Reboot is required. Set Runonce to Enabler
Installer
1363 /* If INSTALL_RESULT Equals "3010" then
1364 /* If SILENT Equals "0" then
1365 /* Display Message "Rebooting"
1366 /* End
1367 /* Rem Add Registry Keys before rebooting
1368 /* Registry Key Software\ITL\Enabler = %UNATTENDED%
1369 /* Rem Stop adding this entry to the Log file. This stops this
being doing on uninstall.
1370 /* Rem If the RunOnce key is deleted on uninstall and then
Enabler is reinstalled the driver will fail its install
1371 /* Rem As windows requires the runonce key to be present to
install drivers
1372 /* Stop writing to installation log
1373 /* Registry Key
SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce = %INS...
1374 /* Continue/Start writing to installation log
1375 /* Add "MSI 3.1 installed - reboot pending" to INSTALL.LOG
1376 /* Exit Installation
1377 /* End
1378 /* Rem 1603 means Windows OS platform is not supported.
1379 /* If INSTALL_RESULT Equals "1603" then
1380 /* If SILENT Equals "0" then
1381 /* Display Message "MSI 3.1 Installer Failed"
1382 /* End
1383 /* Add "MSI 3.1 Installation Failed - Windows OS Platform not
supported." to INSTALL.LOG
1384 /* Exit Installation
1385 /* Else
1386 /* If SILENT Equals "0" then
1387 /* Display Message "MSI 3.1 Installer Failed"
1388 /* End
1389 /* Add "MSI 3.1 Installion Failed" to INSTALL.LOG
1390 /* End
1391 /* Exit Installation
1392 /* End
1393 /* End
1394
1395 /* Rem ==========================================
1396 /* Rem .NET 2.0 Framework? no longer require since we now
install 3.5 by default
1397 /* Rem ==========================================
1398 /* If DOTNET_VERSION Equals "" then
1399 /* If File or Directory doesn't exist
%INST%\Win\DotNetFX\2.0\install.exe then
1400 /* If SILENT Equals "0" then
1401 /* Display Message ".NET 2.0 Framework Installer Failed"
1402 /* End
1403 /* Add "Missing .NET 2.0 Framework Installer" to INSTALL.LOG
1404 /* Rem Remove the registry keys added by MSI reboot
1405 /* Remove Registry Key Software\ITL\Enabler
1406 /* Exit Installation
1407 /* End
1408 /* If SILENT Equals "0" then
1409 /* Display Progress Message "Installing .NET 2.0 Framework"
1410 /* End
1411 /* Add "Installing .NET 2.0 Framework" to INSTALL.LOG
1412 /* Execute CMD.EXE /C ""%INST%\Win\DotNetFX\2.0\install.exe""
/Q (Wait)
1413 /* Rem 3010 means already installed.
1414 /* If INSTALL_RESULT Equals "3010" then
1415 /* Add ".NET 2.0 Framework Already Installed" to INSTALL.LOG
1416 /* Else
1417 /* If INSTALL_RESULT Not Equal "0" then
1418 /* Rem 4121 means MSI is required
1419 /* If INSTALL_RESULT Equals "4121" then
1420 /* If SILENT Equals "0" then
1421 /* Display Message ".NET 2.0 Framework Installer Failed"
1422 /* End
1423 /* Add ".NET 2.0 requires MSI 3.1" to INSTALL.LOG
1424 /* Else
1425 /* If SILENT Equals "0" then
1426 /* Display Message ".NET 2.0 Framework Installer Failed"
1427 /* End
1428 /* Add ".NET 2.0 Framework Installation Failed" to INSTALL.LOG
1429 /* End
1430 /* Rem Remove the registry keys added by MSI reboot
1431 /* Remove Registry Key Software\ITL\Enabler
1432 /* Exit Installation
1433 /* End
1434 /* End
1435 /* End*)
              end
        end
  end;
// lines 1193-1446
//INSTALL SERVER COMPONENTS

procedure InstallServerComponents();
    var
      TRUSTED_CONNECTION: integer;
      INSTALL_RESULT: integer;
    begin
       if components = 'B' then
          begin
             if SQL_NEEDED = 0 then                             
                begin
                   SQLQUERY := PC_NAME + '\' + SQL_INSTANCE;
                   Log('SQLQUERY = ' + SQLQUERY);

                   //TRUSTED CONNECTION
                   TRUSTED_CONNECTION := 1;
                   Log('About to query sysobjects ' +  OSQL_PATH + ' with Trusted Connection');
                   INSTALL_RESULT := CommandPromptExecutor(OSQL_PATH + '\OSQL.EXE -b -d master -E -S ' + SQLQUERY +  ' -Q ' +  '"select count(*) from sysobjects"');
                   if INSTALL_RESULT = 0 then
                      begin
                         Log('Trusted Connection Succeed !!!');
                      end
                   else 
                      begin
                         TRUSTED_CONNECTION := 0;
                      end;
                   if TRUSTED_CONNECTION = 0 then
                      begin
                         if SILENT = 0 then
                            begin
                               MsgBox('Installation failed', mbInformation, MB_OK);
                               Log('Trusted Connection Failed ! SQL server might not have installed correctly. Or the Named instance was incorrect rc');
                               //EXIT INSTALLATION
                               Abort();
                            end
                      end;
                    DetectVersionSQLServersInstalled();
                    IsThereAnExistingEnablerInstall();
                end
              else
                begin
                   SQLServerIsRequired();
                end
             

                
          end
    end; 
 //line 1447 to 1463
 // Blank Password checks for SQL2005, SQL2008, SQL2012, SQL2014 and SQL2016
procedure SQLServerBlankPasswordChecks();

  begin
     if components = 'B' then
        begin
            if SQL_NEEDED = 1 then
                begin
                    if SQLEXPRESSNAME <> 'MSDE2000' then
                        begin
                           if Length(SA_PASSWORD) = 0 then
                              begin
                                 Log('Blank passwords not allowed for ' + SQLEXPRESSFULLNAME);
                                 if SILENT = 0 then
                                    begin
                                       MsgBox('Passwords blank', mbInformation, MB_OK);
                                       //EXIT INSTALLATION
                                       Abort();
                                    end
                              end
                        end
                end
        end
  end;


//lines 1464 to 1763
(*INSTALL SQL SERVER or CHECK SA LOGIN
  The Server Component requires either a preinstalled DB Server, or to install our own
*)

function NeedRestart(): Boolean;
begin
    Result:= True;
end;

function GetRegKeyValue(): Integer;
external'GetRegKeyValue@files:EnablerInstall.dll stdcall';


procedure InstallSQLServerOrCheckSALogin();
    var
      INST_DRIVE: string;
      USER_DOMAIN: string;
      USER_NAME: string;
      SQL_SYSADMIN_USER: string;
      INSTALL_RESULT: integer;
      REG_KEY_IN: string;
      SUB_KEY_IN: string;
      REGKEY: integer;
      POSQL_PATH: string;

    begin
       //If enabler server install selected  
       if components = 'B' then
          begin
             if SQL_NEEDED = 1 then
                begin
                    INST_DRIVE := '{app}';
                    INST_DRIVE := INST_DRIVE + ':';              
                    CreateDir(MAINDIR);
                    if SQLEXPRESSNAME = 'MSDE2000' then
                      begin
                         //MSDE2000 Installation
                         FileCopy('{app}\scripts\MSDEInstall.bat', MAINDIR + '\MSDEInstall.bat', False);
                         //Install MSDE2000 now
                         if SILENT = 0 then
                            begin
                               MsgBox('Installing SQL Server (MSDE2000)', mbInformation, MB_OK);
                               Log('Starting MSDE2000 install from ' + '{app}\MSDE2000');
                               CommandPromptExecutor('/C {MAINDIR}\MSDEInstall.bat {INST_DRIVE} "{app}\MSDE2000" "{SA_PASSWORD}"');
                            end;
                         if DirExists('{MAINDIR}\MSDE_REBOOT_PENDING') OR FileExists('{MAINDIR}\MSDE_REBOOT_PENDING') then
                            begin
                               if UNATTENDED = 0 then
                                  begin
                                     MsgBox('Rebooting', mbInformation, MB_OK);
                                     Log('MSDE installed - reboot pending');
                                     Abort();
                                  end
                            end
                      end
                    else
                        begin
                          // Install SQL2016 / 2014 / 2012 / 2008 /2005
                            USER_DOMAIN:= GetEnv('USERDOMAIN');
                            USER_NAME:= GetEnv('USERNAME');
                            SQL_SYSADMIN_USER:= USER_DOMAIN + '\' + USER_NAME;
                            Log('Assigning system administrator privileges to ' + SQL_SYSADMIN_USER);
                            //Install the SQLInstall batch file.
                            FileCopy('{app}\scripts\SQLInstall.bat', MAINDIR + '\SQLInstall.bat', False);
                            if SILENT = 0 then
                              begin
                                 MsgBox('Installing SQL Server ' + SQLEXPRESSNAME, mbInformation, MB_OK);
                                 Log('Starting {SQLEXPRESSNAME} install from {INST}\{SQLEXPRESSNAME}');
                              end;
                            if SQLEXPRESSNAME =  'SQL2016' then
                              begin
                                 //Extra checks for SQL2016 - Must be 64 bit and Windows greater than Windows 7
                                 if OPERATING_SYSTEM < 6.2 then
                                    begin
                                       if UNATTENDED = 0 then
                                          begin
                                             MsgBox('{SQLEXPRESSFULLNAME} Install', mbInformation, mb_OK);
                                             Log('ERROR: {SQLEXPRESSFULLNAME} not supported on Windows 7');
                                             Abort();
                                          end
                                    end;
                                 if OS <> 64 then
                                    begin
                                       if UNATTENDED = 0 then
                                          begin
                                             MsgBox('{SQLEXPRESSFULLNAME} Install', mbInformation, mb_OK);
                                             Log('ERROR: {SQLEXPRESSFULLNAME} not supported on 32 bit installs');
                                             Abort();
                                          end
                                    end;
                                 //SQL2016 Express Install
                                 //Path to setup exe depends on whether 32 or 64 bit OS is found ( Only 64 bit for SQL2016)
                                 INSTALL_RESULT:=  CommandPromptExecutor('/C '+MAINDIR+'\SQLInstall.bat '+ INST_DRIVE + '"{app}\SQL2016\{OS}" "{SA_PASSWORD}" "{SQL_SYSADMIN_USER}"');                                
                              end
                            else if SQLEXPRESSNAME =  'SQL2014' then
                               begin
                                 //Path to setup exe depends on whether 32 or 64 bit OS is found
                                  INSTALL_RESULT:=  CommandPromptExecutor('/C '+MAINDIR+'\SQLInstall.bat '+ INST_DRIVE + '"{app}\SQL2014\{OS}" "{SA_PASSWORD}" "{SQL_SYSADMIN_USER}"');                                

                               end
                            else if SQLEXPRESSNAME =  'SQL2012' then
                               begin
                                 //Path to setup exe depends on whether 32 or 64 bit OS is found
                                  INSTALL_RESULT:=  CommandPromptExecutor('/C '+MAINDIR+'\SQLInstall.bat '+ INST_DRIVE + '"{app}\SQL2012\{OS}" "{SA_PASSWORD}" "{SQL_SYSADMIN_USER}"');                                

                               end
                            else if SQLEXPRESSNAME =  'SQL2008  ' then
                               begin
                                 //Path to setup exe depends on whether 32 or 64 bit OS is found
                                  Log('About to issue command: /C '+MAINDIR+'\SQLInstall.bat '+ INST_DRIVE + '"{app}\SQL2008R2\{OS}" "{SA_PASSWORD}" "{SQL_SYSADMIN_USER}"');
                                  INSTALL_RESULT:=  CommandPromptExecutor('/C '+MAINDIR+'\SQLInstall.bat '+ INST_DRIVE + '"{app}\SQL2008R2\{OS}" "{SA_PASSWORD}" "{SQL_SYSADMIN_USER}"');                                

                               end
                            else
                              begin
                                //SQL2005 Express Install
                                INSTALL_RESULT:=  CommandPromptExecutor('/C '+MAINDIR+'\SQLInstall.bat '+ INST_DRIVE + '"{app}\SQL2005\{OS}" "{SA_PASSWORD}"');                                
                                Log('Result of SqlInstall {INSTALL_RESULT}');
                              end;
                            //Error 1 - Password not strong
                            if INSTALL_RESULT = 1 then
                              begin
                                 if UNATTENDED = 0 then
                                    begin
                                       Log('{SQLEXPRESSFULLNAME} install failed due to SQL password not strong');
                                       Abort();
                                    end
                              end;
                            //Make sure the SQL Server doesn't need a reboot
                            if INSTALL_RESULT = 2 then
                              begin
                                 MsgBox('Reboot required', mbInformation, MB_OK);
                                 //Add Registry Keys before rebooting
                                 RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler', 'ITL', 'Enabler');
                                 //Stop writing to installation log                                 
                                 RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce', 'Enabler', '{INST}\Enabler4Setup.exe');
                                 Log('{SQLEXPRESSFULLNAME} installed - reboot pending');
                                 //Reboot system
                                 if MsgBox('Reboot system?', mbConfirmation, MB_YESNO) = IDYES then
                                   begin
                                       NeedRestart();
                                       //EXIT Installation;
                                   end;

                              end;
                            //Error 3 - Updates required
                            if INSTALL_RESULT = 3 then
                              begin
                                 if UNATTENDED = 0  then
                                    begin
                                       MsgBox('{SQLEXPRESSFULLNAME} Install', mbInformation, MB_OK);
                                       Log('ERROR: {SQLEXPRESSFULLNAME} install failed, updates are required');
                                       //EXIT INSTALLATION
                                       Abort();
                                    end
                              end;
                            //Error 4 or any other error - Failed Intall
                            //Make sure the SQL Server was installed
                            if INSTALL_RESULT <> 0 then
                              begin
                                 MsgBox('{SQLEXPRESSFULLNAME} Install', mbInformation, MB_OK);
                                 Log('ERROR: {SQLEXPRESSFULLNAME} install failed'); \
                                 //EXIT INSTALLATION
                                 Abort();
                              end;
                            //Make sure the SQL Server engine is running
                            //Start Service mssqlserver
                            if SILENT = 0 then
                              begin
                                 MsgBox('', mbInformation, MB_OK);
                              end;
                            //Set up Registry Key for SQL version client Setup
                            if SQLEXPRESSNAME = 'SQL2016' then
                              begin
                              REG_KEY_IN:= 'SOFTWARE\\Microsoft\\Microsoft SQLServer\\130\\Tools\\ClientSetup';
                              end
                            else if SQLEXPRESSNAME = 'SQL2014' then
                              begin
                                REG_KEY_IN:= 'SOFTWARE\\Microsoft\\Microsoft SQLServer\\120\\Tools\\ClientSetup';
                              end                              
                            else if SQLEXPRESSNAME = 'SQL2012' then
                              begin
                                REG_KEY_IN:= 'SOFTWARE\\Microsoft\\Microsoft SQLServer\\110\\Tools\\ClientSetup';
                              end
                            else if SQLEXPRESSNAME = 'SQL2008R2' then
                              begin
                                REG_KEY_IN:= 'SOFTWARE\\Microsoft\\Microsoft SQLServer\\100\\Tools\\ClientSetup';
                              end; 
                            //If we get here must send the full path to OSQL.EXE to DBInstall to make sure it can run properly
                            if REG_KEY_IN <> '' then
                              begin
                                   //This block of code were original remarks in the old script so I am just replicating them here
                                  (*1631 Rem == We are using a custom built DLL to get the registry key
                                  value from the windows registry
                                  1632 Rem == if installing on a 64-bit OS the DLL will get the key from
                                  the 64-bit side of the registry.
                                  1633 Rem == This is required because this installer (which is a 32-bit
                                  app) would otherwise incorrectly retrieve keys from the 32-...
                                  1634 Rem == FYI - - - On a 64-bit system there would be a \Program
                                  Files\ folder for 64-bit apps
                                  1635 Rem == FYI - - - ...and a \Program Files (x86)\ folder for 32-bit
                                  apps
                                  1636 Rem*)
                                  if OS = 64 then
                                    begin
                                      SUB_KEY_IN:= GetEnv('PATH'); 
                                      Log('64-bit OS therefore copying EnablerInstall.dll');
                                      FileCopy('{app}\bin\enablerinstall.dll', MAINDIR + '\bin\EnablerInstall.dll', False);
                                      REGKEY:= GetRegKeyValue();
                                      Log('The path to OSQL.EXE for this 64-bit install of SQL Server is: ' + IntToStr(REGKEY));
                                      OSQL_PATH:= IntToStr(REGKEY);
                                      Log('OSQL_PATH is currently set to ' + OSQL_PATH);
                                    end
                                  else if OS = 32 then
                                    begin
                                       Log('32-bit OS therefore will use standard WISE way to get key from registry');
                                       RegQueryStringValue('HKEY_AUTO', REG_KEY_IN, 'Default', OSQL_PATH);
                                       Log('OSQL_PATH is ' + OSQL_PATH);
                                       
                                    end;
                                  Log('Processor bit size (e.g. 32/64 bit), the variable OS is ' + IntToStr(OS));
                              end
                            else
                              begin
                                  //Locate OSQL for SQL2005 and MSDE2000
                                  RegQueryStringValue('HKEY_AUTO', 'Software\Microsoft\Windows\CurrentVersion', 'Default', POSQL_PATH);
                                  //Try SQL2005 Path first
                                  OSQL_PATH := POSQL_PATH+ '\Microsoft SQLServer\90\Tools\Binn';
                                  if FileExists(OSQL_PATH +'\OSQL.EXE')=False then
                                      begin
                                         //Try MSDE Path second
                                         OSQL_PATH := POSQL_PATH+ '\Microsoft SQLServer\80\Tools\Binn';
                                      end;
                                  Log('Location of OSQL.EXE is %OSQL_PATH% (SQL2005 Installation in progress)');
                                  
                              end;
                            //In case we can't find OSQL.EXE anywhere
                            if FileExists(OSQL_PATH +'\OSQL.EXE')=False then
                                begin
                                   Log('ERROR: Cannot find OSQL.EXE');
                                   Abort();
                                end;
                            //OSQL should work now, we will test it now to make sure.
                            Log('Making sure that OSQL works ' + OSQL_PATH);
                            INSTALL_RESULT := CommandPromptExecutor(OSQL_PATH+'\OSQL.EXE -b -d master -E -S%SQLQUERY% -Q "select count(*) from sysobjects"');
                            if INSTALL_RESULT = 0 then
                                begin
                                  //Ok we can run oSQL properly now, so remove Registry entries to restart after reboot
                                  RegDeleteKeyIncludingSubkeys('HKLM', 'Software\ITL\Enabler');
                                  (*1678 Rem Stop adding this entry to the Log file. This stops this being doing on uninstall.
                                    1679 Rem If the RunOnce key is deleted on uninstall and then Enabler is reinstalled the driver will fail its install
                                    1680 Rem As windows requires the runonce key to be present to install drivers*);
                                    //Stop writing to installation log
                                  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce', 'Enabler', '{INST}\Enabler4Setup.exe');
                                  Log('OSQL working OK');  
                                end
                            else
                                begin
                                  //We cannot continue with install now because OSQL is not working correctly, a reboot is required'):
                                   if UNATTENDED = 0 then
                                      begin
                                         MsgBox(APPTITLE, mbInformation, MB_OK);
                                      end;
                                   Log('OSQL not working, rebooting...');
                                   NeedRestart();
                                   //EXIT INSTALLATION
                                   Abort();
                                end
                        end
                end
            else
               begin
                  //If a SQL already installed Make sure the SQL server is running
                  if SQL_INSTANCE = '' then
                      begin
                          CommandPromptExecutor('net start mssqlserver');
                      end
                  else
                      begin
                          CommandPromptExecutor('net start MSSQL$'+SQL_INSTANCE);

                      end
               end;
            //INSTALL WINDOWS DRIVER FOR ENABLER
            if DirExists('{app}\Driver') then
              begin
                if SILENT = 0 then
                  begin
                     MsgBox('Installing', mbInformation, MB_OK);
                     //Delete All Drivers before copy the latest
                     DelTree(MAINDIR+'\Driver\*', False, True, True);
                     //Copy Installation files across
                     FileCopy('{app}\Driver\DriverInstaller.exe', MAINDIR+'\Driver\DriverInstaller.exe', False);
                     if OS = 64 then
                        begin
                            FileCopy('{app}\Driver\x64\EnablerPCI.inf', MAINDIR+'\Driver\EnablerPCI.inf', False);
                            FileCopy('{app}\Driver\x64\Enbx64.sys', MAINDIR+'\Driver\Enbx64.sys', False);
                            FileCopy('{app}\Driver\x64\enbamd64.cat', MAINDIR+'\Driver\enbamd64.cat', False);
                            FileCopy('{app}\Driver\x64\DPInst.exe', MAINDIR+'\Driver\DPInst.exe', False);
                            FileCopy('{app}\Driver\x64\DPInst.xml', MAINDIR+'\Driver\DPInst.xml', False);
                            FileCopy('{app}\Driver\x64\d5c4eb30-04db-4831-9b5c-6b4c1bfdd34c\EnablerExpressamd64.cat', MAINDIR+'\Driver\EnablerExpressamd64.cat', False);
                            FileCopy('{app}\Driver\x64\d5c4eb30-04db-4831-9b5c-6b4c1bfdd34c\EnablerExpressx64.inf', MAINDIR+'\Driver\EnablerExpressx64.inf', False);
                            FileCopy('{app}\Driver\x64\d5c4eb30-04db-4831-9b5c-6b4c1bfdd34c\EnablerExpressx64.sys', MAINDIR+'\Driver\EnablerExpressx64.sys', False);

                        end
                     else
                          begin
                            FileCopy('{app}\Driver\x86\EnablerPCI.inf', MAINDIR+'\Driver\EnablerPCI.inf', False);
                            FileCopy('{app}\Driver\x86\Enbx32.sys', MAINDIR+'\Driver\Enbx32.sys', False);
                            FileCopy('{app}\Driver\x86\enbx86.cat', MAINDIR+'\Driver\enbx86.cat', False);
                            FileCopy('{app}\Driver\x86\DPInst.xml', MAINDIR+'\Driver\DPInst.xml', False);
                            FileCopy('{app}\Driver\x86\DPInst.exe', MAINDIR+'\Driver\DPInst.exe', False);
                            FileCopy('{app}\Driver\x64\dd6f1c9a-e12e-4635-ad02-38e3553533bf\EnablerExpressx32.inf', MAINDIR+'\Driver\EnablerExpressx32.inf', False);
                            FileCopy('{app}\Driver\x64\dd6f1c9a-e12e-4635-ad02-38e3553533bf\EnablerExpressx86.cat', MAINDIR+'\Driver\EnablerExpressx86.cat', False);
                            FileCopy('{app}\Driver\x64\dd6f1c9a-e12e-4635-ad02-38e3553533bf\EnablerExpressx32.sys', MAINDIR+'\Driver\EnablerExpressx32.sys', False);
                        end;
                     //Check that the RunOnce Key is present and create it if it doesn't
                     if RegKeyExists('HKLM', 'SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce')=False then
                        RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce', 'EnablerDriver', MAINDIR+'\Driver\DriverInstaller.exe');
; 
                     //Installs the Driver calling an application that returns a success or not
                     INSTALL_RESULT:= CommandPromptExecutor(MAINDIR+'\Driver\DriverInstaller.exe');
                     if INSTALL_RESULT = 1 then
                        begin
                           //requires reboot
                           DRIVERCODE := 1;

                        end
                     else if INSTALL_RESULT = 2 then
                        begin
                           //Failed Install
                           DRIVERCODE := 2;

                        end
                     else if INSTALL_RESULT = 3 then
                        begin
                           //No device present
                           DRIVERCODE:= 3;
                        end
                     else
                        begin
                           //Successful install
                           DRIVERCODE:= 0;
                        end;
                     if SILENT = 0 then
                        begin
                           MsgBox('Installing', mbInformation, MB_OK);

                        end
                  end

              end  
           else
              begin
                 MsgBox('Unable to install driver', mbInformation, MB_OK);
              end
          end
      //End installing server components
    end;                    

function InitializeSetup(): Boolean;
begin
  appName := '{#SetupSetting("AppName")}';

  //===================================
  // Initialise variables.
  //===================================

  Log('Initialising variables.');
  APPTITLE:= 'Enabler';
  INSTANCE_NAME_NEEDED:= 1;
  INSTANCE_NAME_LIST:= 0;
  MAINDIR:= 'C:\%MAINDIR%';
  PC_NAME:= GetComputerNameString();
  DRIVERCODE:= 0;


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
