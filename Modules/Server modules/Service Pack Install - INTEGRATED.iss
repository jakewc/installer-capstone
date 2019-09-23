[Code]

procedure checkSP();

var
  VISTASP:string;

begin
  if COMPONENTS = 'B' then begin
    if SQL_NEEDED = true then begin
      if SQLEXPRESSNAME = 'SQL2012' then begin
        if OPERATING_SYSTEM = '6' then begin
          RegQueryStringValue(HKEY_LOCAL_MACHINE, 'Software\Microsoft\Windows NT\CurrentVersion', 'CSDBuildNumber', VISTASP);
          Log('Vista build number is ' + VISTASP);
          // NOTE: 6.0 = Windows Vista or Windows Server 2008 1171
          // NOTE: msu files do not support the /passive switch
          if VISTASP = '2' then begin
            //no SP installed
            //installing SP1
            MsgBox('SQL2012 prerequisites not met - Vista Service Pack 1 not installed', mbinformation, MB_OK);
            Log('ERROR: Vista has no required Service Packs installed, exiting installation.');
            Abort();
          end
          else if VISTASP = '1616' then begin
            //no SP2 installed
            MsgBox('SQL2012 prerequisites not met - Vista Service Pack 2 not installed', mbinformation, MB_OK);
            Log('ERROR: Vista does not have required Service Pack 2 installed, exiting installation.');
            Abort();
          end;
        end;
      end;
    end;
  end;
end;