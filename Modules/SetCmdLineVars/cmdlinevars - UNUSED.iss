[Code]
var
CMDLINE_LOG:String;
CMDLINEUPPER:String;
CMDOPTION:String
CMDUPPER:String;
CMDSTART:String;
CMDEND:String;
SHOW_USAGE:Integer;
UNATTENDED:Integer;
SILENT:Integer;
{This error return code is only for Silent Mode Install}
WISE_ERROR_RTN:Integer;

procedure variableInitialisation ();
begin
  CMDLINE_LOG:= '';
  CMDLINEUPPER:= ExpandConstant('{cmd}');
  CMDOPTION:= '';
  CMDUPPER:= '';
  CMDSTART:= '';
  CMDEND:= '';
  SHOW_USAGE:=0;

end;

while CMDLINE <> '' do
begin
   CMDOPTION:=ExpandConstant('{cmd}');
   CMDLINE:=ExpandConstant('{cmd}');
   CMDUPPER:= CMDOPTION;
   {DEBUG ONLY - comment out for release!!!}
   {Log("Option = " + CMDUPPER)}
   CMDSTART:=CMDUPPER
   CMDEND:=CMDUPPER

   {Check  for /? or /h or -? or -h  - AT THE START OF THE STRING }
   if CMDSTART = '-H' then
   begin
    Log('User requested usage -H');
    SHOW_USAGE:=1;
   end;
   if CMDSTART = '-?' then
   begin
    Log('User requested usage -?');
    SHOW_USAGE:=1;
   end;
   if CMDSTART = '/H' then
   begin
    Log('User requested usage /H');
    SHOW_USAGE:=1;
   end;
   if CMDSTART = '/?' then
   begin
    Log('User requested usage /?');
    SHOW_USAGE:=1;
   end;

   {Silent unattended install}

   if CMDSTART = '/S' then
   begin
      Log('SILENT install selected');
      UNATTENDED:=1;
      SILENT:=1;
      {This error return code is only for Silent Mode Install}
      WISE_ERROR_RTN:=1;
    end;

    {Automatic server install}
    if CMDSTART = '/FULL' then
    begin
      Log('FULL Enabler server install selected')
      UNATTENDED:=1;
      COMPONENTS:='B';
      APPLICATIONS:='ABCDEF'
      if '/CLIENT' in CMDLINEUPPER then {how the bloody hell do I do this}
      begin
        Log('ERROR: Cannot use /CLIENT and /FULL together');
        ExitProcess(0);
      end;
    end;

    {Automatic server install}







procedure ExitProcess(exitCode:integer);
  external 'ExitProcess@kernel32.dll stdcall';
   



