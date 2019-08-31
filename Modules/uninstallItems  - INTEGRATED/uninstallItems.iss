[Code]

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