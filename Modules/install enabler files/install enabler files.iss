[Code]

//=============================
//INSTALL ENABLER FILES
//=============================

//TODO - gets lots of registry keys, not sure which to use

//else begin
//Just being paranoid really - we should never get here because we check the OS Version earlier on
//Log('ERROR: Cannot add Start Menu items');
//ExitProcess(0);
//end;

var
  ResultCode:integer;
if COMPONENTS = 'B' then begin
  FileCopy('{#SourcePath}\Input\bin\scutil.exe', ExpandConstant('{app}')+'\scutil.exe', false);
  if FileExists(ExpandConstant('{app}')+'\psrvr4.exe') then begin
    Exec(ExpandCOnstant('{app}')+'\scutil.exe', '/STOP psrvr','',SW_SHOW,ewWaitUntilTerminated, ResultCode);
    if ResultCode <> 0 then begin
      Log('INFO: Could not stop PSRVR (rc='+ResultCode + ')');
    end;
  end;
  if FileExists(ExpandConstant('{app}')+'\bin\psrvr4.exe') then begin
    Exec(ExpandCOnstant('{app}')+'\scutil.exe', '/STOP psrvr','',SW_SHOW,ewWaitUntilTerminated, ResultCode);
    if ResultCode <> 0 then begin
      Log('INFO: Could not stop PSRVR (rc='+ResultCode + ')');
    end;
  else begin
  if FileExists(ExpandConstant('{app}')+'\psrvr.exe') then begin
    Exec(ExpandCOnstant('{app}')+'\scutil.exe', '/STOP psrvr','',SW_SHOW,ewWaitUntilTerminated, ResultCode);
    if ResultCode <> 0 then begin
      Log('INFO: Could not stop PSRVR (rc='+ResultCode+')');
    end;
  end;
  end;
  if FileExists(ExpandConstant('{app}')+'\bin\WebHost.exe') then begin
    Exec(ExpandCOnstant('{app}')+'\scutil.exe', '/STOP WebHost','',SW_SHOW,ewWaitUntilTerminated, ResultCode);
    if ResultCode <> 0 then begin
      Log('INFO: Could not stop Enabler Web (rc='+ResultCode+')');
    end;
  end;
  if FileExists(ExpandConstant('{app}')+'\bin\EnbWeb.exe') then begin
    Exec(ExpandCOnstant('{app}')+'\scutil.exe', '/STOP psrvr','',SW_SHOW,ewWaitUntilTerminated, ResultCode);
    if ResultCode <> 0 then begin
      Log('INFO: Could not stop Enabler Web (rc='+ResultCode+')');
    end;
  end;
end;