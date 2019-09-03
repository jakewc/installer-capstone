;Ricky added
Source: "Input\IsAdmin.exe"; DestDir:"{tmp}\IsAdmin.exe";
Source: "Input\AutoSupport.exe"; DestDir:"{app}\AutoSupport.exe";
Source: "Inpur\release.txt"; DestDir:"{tmp}\READMEFILE" ;

//Ricky added start
//-----------------------------------------------------
//Startup Processing
//-----------------------------------------------------

{Initialise unattended variables}
var
SILENT:Boolean;
UNATTENDED:Boolean;

procedure variableInitialisation ();
begin
  UNATTENDED:=False;
  SILENT:=False;

end;

//Check if the user is an admin first
//Should be Test
procedure CheckUserIsAdmin();
var
  ResultCode: Integer;
begin
  SILENT:=False;
  if Exec(ExpandConstant('{tmp}\IsAdmin.exe'), '', '', SW_SHOW,
     ewWaitUntilTerminated, ResultCode) then
  begin
     if ResultCode = 0 then
      begin
        //remain mistake
        if SILENT = False then 
          begin
              MsgBox('Not an administrator', mbInformation, MB_OK)
          end;
        Log('Install stopped - Not an administrator');
      end;
  end;
end;

function GetIEXPLORE_PATH():String;
var 
  IEXPLORE_PATH:String;  
begin
  IEXPLORE_PATH:='';
  if RegValueExists(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\IEXPLORE.EXE','Path')then
  begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\IEXPLORE.EXE','Path',IEXPLORE_PATH)
  end;
  Result:=IEXPLORE_PATH;
end;



function GetIEXPLORE_VERSION():String;
var 
  IEXPLORE_VERSION:String;  
begin
  IEXPLORE_VERSION:='';
  if RegValueExists(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Internet Explorer','Version')then
  begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Internet Explorer','Version',IEXPLORE_VERSION)
  end;
  Result:=IEXPLORE_VERSION;
end;

procedure writeLog();
var
SHOW_IE_VERSION:Boolean;
begin
UNATTENDED:=False;
Log('IE location'+GetIEXPLORE_PATH());
Log('IE Ver'+GetIEXPLORE_VERSION());
if GetIEXPLORE_VERSION() < '5'  then
  begin
    SHOW_IE_VERSION:=False;
    if FileOrDirExists('Input\Release Notes.htm') = True then
    begin
      Log('WARNING:A newer version of IE is required to display Release Notes');
      SHOW_IE_VERSION:=True;
    end;
    if SHOW_IE_VERSION = True then
    begin
      if UNATTENDED = True then
      begin
        Log('Install stopped - newer version of IE is required');
      end; 
    end;
  end;
end;

var
HTML_RELEASE_NOTES:Boolean;
procedure checkReleaceNote();
begin
  if FileOrDirExists('Input\Release Notes.htm')then
   begin
    HTML_RELEASE_NOTES:=True;
   end
   else
    HTML_RELEASE_NOTES:=False; 
   end; 
end;
//-----------------------------------------------------
//Ricky added end

