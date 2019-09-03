[Code]

//=============================================
//Setup Environment Variables and Registry Keys
//==============================================

procedure setupEnvVars();
var
  ResultCOde:integer;
begin
    if OS = 64 then begin
      FileCopy('{#SourcePath}\Input\bin\setx64.exe',ExpandConstant('{app}')+'\bin\setx64.exe', false)
      SETX_PATH:=ExpandConstant('{app}')+'\bin\setx64.exe'
    end
    else begin
      FileCopy('{#SourcePath}\Input\bin\setx32.exe',ExpandConstant('{app}')+'\bin\setx32.exe', false);
      SETX_PATH:=ExpandConstant('{app}')+'\bin\setx32.exe';
    end;

    Exec(SETX_PATH, ENABLER_ROOT+ ' ' + ExpandCOnstant('{app}')+ ' -M', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    Exec(SETX_PATH, ENABLER_LOG+ ' ' + ExpandCOnstant('{app}')+ '\Log -M', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    Exec(SETX_PATH, ENABLER_DB_INSTANCE_NAME + ' ' + SQL_INSTANCE + ' -M', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);

    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'DatabaseInstanceName', SQL_INSTANCE);
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'Enabler_Log', ExpandConstant('{app}')+'Log');
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'Root', ExpandConstant('{app}'));

    //and now the files
    if WINDOWS_BASE_VERSION < 5 then begin
      //should we install these to SYSTEM32?
      Log('Installing on Windows '+ WINDOWS_VERSION + ' installing extra DLLs');
      FileCopy('{#SourcePath}\Input\Extra\ATL.dll',ExpandConstant('{app}')+'\ATL.DLL', false);
      FileCopy('{#SourcePath}\Input\Extra\mfc42.dll',ExpandConstant('{app}')+'\mfc42.DLL', false);
      FileCopy('{#SourcePath}\Input\Extra\mfc42u.dll',ExpandConstant('{app}')+'\mfc42u.dll', false);
    end;

    DeleteFile(ExpandConstant('{app}')+'Release Notes.html');
    if FileExists('{#SourcePath}\Input\Release Notes.htm') then begin
      FileCopy('{#SourcePath}\Input\Release Notes.htm',ExpandConstant('{app}')+'\Release Notes.htm', false);
    end;
    if FileExists('{#SourcePath}\Input\Update\PumpUpdate.htm') then begin
      FileCopy('{#SourcePath}\Input\Update\PumpUpdate.htm',ExpandConstant('{app}')+'\PumpUpdate.htm', false);
    end;
    FileCopy('{#SourcePath}\Input\bin\atutil.exe',ExpandConstant('{app}')+'\atutil.exe', false);
    FileCopy('{#SourcePath}\Input\bin\odbcnfg.exe',ExpandConstant('{app}')+'\bin\odbcnfg.exe', false);
    FileCopy('{#SourcePath}\Input\bin\ODBCnfg64.exe',ExpandConstant('{app}')+'\ODBCnfg64.exe', false);
    FileCopy('{#SourcePath}\Input\EnbKick.exe',ExpandConstant('{app}')+'\EnbKick.exe', false);
end;