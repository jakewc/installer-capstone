[Code]

//=============================================
//save configuration settings in case of reboot
//=============================================
procedure saveConfig();
var
  ResultCode:integer;
  INSTALL_RESULT:integer;
begin
  //Save install options selected by the user so we can re-load these if the installer is restarted

  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'Applications', APPLICATIONS);
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'Backup', PRE_UPGRADE_BACKUP);
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'Components', COMPONENTS);
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'EnbWebDomain', ENBWEB_DOMAIN);
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'EnbWebPort', ENBWEB_PORT);
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'InstanceName', SQL_INSTANCE);
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'SA', SA_PASSWORD);
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'SDK', SDK);
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER', 'UnattendedInstall', UNATTENDED);

  //set client install variable
  if COMPONENTS = 'B' then begin
    Log('Server was chosen');
    //Checking to see if the C: drive is compressed. SQL server doesn't like the EnablerDB files in a compressed location
    if strtoint(OPERATING_SYSTEM) >= 5.1 then begin
      if ((strtoint(OPERATING_SYSTEM) >= 6) and (OS=64)) then begin
        Exec('C:\WINDOWS\Sysnative\CMD.EXE', ' /C '+ExpandConstant('{app}')+'\bin\DriveCompressed.exe', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
        INSTALL_RESULT:=ResultCode;
      end
      else begin
        Exec('CMD.EXE', ' /C '+ExpandConstant('{app}')+'\bin\DriveCompressed.exe', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
        INSTALL_RESULT:=ResultCode;
      end;
      
      // A 0 means it is not compressed, 1 is compressed, -1 is an error occured during the application 

      if INSTALL_RESULT > 0 then begin
        if SILENT = false then begin
          MsgBox('C: drive compressed, which is not supported. Installation exiting.', mbINFORMATION, MB_OK);
        end;
        Log('Result Code = ' +inttostr(INSTALL_RESULT)+', C: drive is compressed, which is not supported');
        Abort();
      end
      else if INSTALL_RESULT < 0 then begin
        Log('Error running DriveCompressed utility, continuing install');
      end
      else begin
        Log('C: drive is not compressed');
      end;
    end;
  end
  else begin
    Log('Client was chosen');
  end;
end;
