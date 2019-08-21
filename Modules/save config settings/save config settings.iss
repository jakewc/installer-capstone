[Code]

//===================================
//save configuration settings in case of reboot
//===================================


RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'Applications', APPLICATIONS);
RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'Backup', PRE_UPGRADE_BACKUP);
RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'Components', COMPONENTS);
RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'EnbWebDomain', ENBWEB_DOMAIN);
RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'EnbWebPort', ENBWEB_PORT);
RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'InstanceName', SQL_INSTANCE);
RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'SA', SQ_PASSWORD);
RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'SDK', SDK);
RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'UnattendedInstall', UNATTENDED);

//set client install variable
var
  ResultCode;integer;
  INSTALL_RESULT:integer;
if COMPONENTS = 'B' then begin
  Log('Server was chosen');
  if OPERATING_SYSTEM >= 5.1 then begin
    FileCopy('{#SourcePath}\Input\bin\DriveCompressed.exe', ExpandConstant('{app}')+'\bin\DriveCOmpressed.exe', false);
    if OPERATING_SYSTEM >= 6 and OS=64 then begin
      Exec('C:\WINDOWS\Sysnative\CMD.EXE', ' /C '+ExpandConstant('{app}')+'\bin\DriveCompressed.exe', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
      INSTALL_RESULT:=ResultCode;
    else begin
      Exec('CMD.EXE', ' /C '+ExpandConstant('{app}')+'\bin\DriveCompressed.exe', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
      INSTALL_RESULT:=ResultCode;
    end;
    
    // A 0 means it is not compressed, 1 is compressed, -1 is an error occured during the application 

    if INSTALL_RESULT > 0 then begin
      if SILENT = 0 then begin
        MsgBox('C: drive compressed', mbINFORMATION, MBOK);
      end;
      Log('C: drive is compressed, which is not supported');
      ExitProcess(0);
    else if INSTALL_RESULT < 0 then begin
      Log('Error running DriveCOmpressed utility, continuing install');
    end;
    else begin
      Log('C: drive is not compressed');
    end;
  end;
  else begin
    Log('Client was chosen');
end;

