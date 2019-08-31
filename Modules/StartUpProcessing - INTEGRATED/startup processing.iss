[Files]
//===================
//startup processing
//===================
Source: "{#SourcePath}\Input\IsAdmin.exe"; DestDir:"{tmp}";
//Install autosupport early on so that if an error occurs customers can use it
Source: "{#SourcePath}\Input\AutoSupport.exe"; DestDir:"{app}";
//copy readme and release notes files into TEMP folder
Source: "{#SourcePath}\Input\release.txt"; DestDir:"{tmp}" ;

[Code]
var
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
      if UNATTENDED then begin
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
    if UNATTENDED = true then begin
      if COMPONENTS = 'A' then begin
        Log('ERROR: Cannot install server on this version of windows');
        Abort();
      end;
    end;
  end;
end;


