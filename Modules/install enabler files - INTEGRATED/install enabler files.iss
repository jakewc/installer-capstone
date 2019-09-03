[Code]

//=============================
//INSTALL ENABLER FILES
//=============================

procedure installEnablerFiles();
var
  ResultCode:integer;
begin
//Load registry settings required to add start menu items

//if system has windows 95 shell interface
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','StartUp',STARTUPDIR);
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','Desktop',DESKTOPDIR);
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','Start Menu',STARTMENUDIR);
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','Programs',GROUPDIR);
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','Common Startup',CSTARTUPDIR);
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','Common Desktop',CDESKTOPDIR);
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','Common Start Menu',CSTARTMENUDIR);
  RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','Common Programs',CGROUPDIR);

  CGROUP_SAVE:=GROUP;
  DESKTOPDIR:=CDESKTOPDIR;
  GROUP:=CGROUPDIR+'\'+GROUP;

  //else begin
  //Just being paranoid really - we should never get here because we check the OS Version earlier on
  //Log('ERROR: Cannot add Start Menu items');
  //Abort();
  //end;


  if COMPONENTS = 'B' then begin  
    if FileExists(ExpandConstant('{app}')+'\psrvr4.exe') then begin
      Exec(ExpandConstant('{app}')+'\scutil.exe', '/STOP psrvr','',SW_SHOW,ewWaitUntilTerminated, ResultCode);
      if ResultCode <> 0 then begin
        Log('INFO: Could not stop PSRVR (rc='+inttostr(ResultCode) + ')');
      end;
    end;
    if FileExists(ExpandConstant('{app}')+'\bin\psrvr4.exe') then begin
      Exec(ExpandConstant('{app}')+'\scutil.exe', '/STOP psrvr','',SW_SHOW,ewWaitUntilTerminated, ResultCode);
      if ResultCode <> 0 then begin
        Log('INFO: Could not stop PSRVR (rc='+inttostr(ResultCode) + ')');
      end
    end
    else begin
      if FileExists(ExpandConstant('{app}')+'\psrvr.exe') then begin
        Exec(ExpandConstant('{app}')+'\scutil.exe', '/STOP psrvr','',SW_SHOW,ewWaitUntilTerminated, ResultCode);
        if ResultCode <> 0 then begin
          Log('INFO: Could not stop PSRVR (rc='+inttostr(ResultCode)+')');
        end;
      end;
    end;
    if FileExists(ExpandConstant('{app}')+'\bin\WebHost.exe') then begin
      Exec(ExpandConstant('{app}')+'\scutil.exe', '/STOP WebHost','',SW_SHOW,ewWaitUntilTerminated, ResultCode);
      if ResultCode <> 0 then begin
        Log('INFO: Could not stop Enabler Web (rc='+inttostr(ResultCode)+')');
      end;
    end;
    if FileExists(ExpandConstant('{app}')+'\bin\EnbWeb.exe') then begin
      Exec(ExpandConstant('{app}')+'\scutil.exe', '/STOP psrvr','',SW_SHOW,ewWaitUntilTerminated, ResultCode);
      if ResultCode <> 0 then begin
        Log('INFO: Could not stop Enabler Web (rc='+inttostr(ResultCode)+')');
      end;
    end;
  end;
end;