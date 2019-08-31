[Code]

//=======================================================================
//Reboot system to disable fast startup and change system power settings
//This should be the last thing to do.
//=========================================================================

function NeedRestart():Boolean;
begin
  if RESTART_DECISION then begin
    Result:=True;
  end
  else
    Result:=False;
end;

procedure decideReboot();
var
  ResultCode:integer;
begin
  //Only change setting for server
  if COMPONENTS = 'B' then begin
    //SERVER INSTALL
    //Get registry value for fast startup
    RegQueryStringValue(HKEY_LOCAL_MACHINE, 'System\CurrentCOntrolSet\Control\Power', 'HibernateEnabled', FAST_STARTUP);
  
    Log('Fast startup setting is: ' + FAST_STARTUP);
    if FAST_STARTUP <> '0' then begin
      //use powercfg to disable Fast startup. Editing of registry does NOT work for all OS
      Exec('CMD.EXE', '/C powercfg.exe -H off', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
      Log('Updating registry setting to disable fast startup');
    end;

    //force to disable ALL other sleep settings for all devices
    Exec('CMD.EXE', '/C powercfg.exe -change -standby-timeout-ac 0', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    Exec('CMD.EXE', '/C powercfg.exe -change -standby-timeout-dc 0', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    Log('Update standby TO to 0 to prevent system going to sleep');

    Exec('CMD.EXE', '/C powercfg.exe -change -hibernate-timeout-ac 0', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    Exec('CMD.EXE', '/C powercfg.exe -change -hibernate-timeout-dc 0', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    Log('Update hibernate TO to 0 to prevent system hibernation');
  end;

  //log silent setting
  Log('Silent setting is '+inttostr(integer(SILENT)));

  //finalizes the install
  //if UNATTENDED = '0' then begin
    //show custom dialog 'FINISHED' - inno does this for us
  //end;

  Log('Install is finished');
  //Add uninstall details to the registry...
  //NOTE: This registry edit does the setup for Windows Add/Remove Programs, so these will be redundant
  //for the new install script. Though if you're upgrading and these keys are present they should
  //probably be removed (after installing the new version you can't uninstall the old one).
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\'+APPTITLE, 'Comments', 'Windows-based Forecourt Control by Integration Technologies Limited.');
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\'+APPTITLE, 'Publisher', 'Integration Technologies Limited.');
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\'+APPTITLE, 'URLInfoAbout', 'https://www.integration.co.nz/support/');
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\'+APPTITLE, 'DisplayIcon', ExpandConstant('{app}')+'itl.ico,-0');

  RESTART_DECISION:=false;
  //reboot the PC
  if FAST_STARTUP <> '0' then begin
    if SILENT = false then begin
    Log('Rebooting system to disable fast startup');
    //reboot system
    //!!!This should be the ONLY TIME IN THE SCRIPT THAT THIS VARIABLE CAN BE SET TO TRUE
    RESTART_DECISION:=True;
    end
    else begin
    Log('Reboot required to disable fast startup');
    Abort();
    end;
  end;

  if SILENT = true then begin
    //this error code only for silent mode install
    ERROR_RTN := false;
  end;

  //decide whether we should start things
  DO_START_ACTIONS:= 1;
  If COMPONENTS = 'B' then begin
    //for server installs we only start things if the server is running
    if pos('Running', RUNNING) = 0 then begin
      DO_START_ACTIONS:= 0;
    end;
  end;

  //start things the installer asked for
  if DO_START_ACTIONS = 1 then begin
    if pos('A', START_MPP) <> 0 then begin
      Exec(ExpandConstant('{app}')+'mppsim.exe', '', '', SW_SHOW, ewNoWait, ResultCode);
    end;
    if pos('A', START_PUMP) <> 0 then begin
      Exec(ExpandConstant('{app}')+'PumpDemoWPF.exe', '', '', SW_SHOW, ewNoWait, ResultCode);
    end;
    if pos('A', OPEN_WEB) <> 0 then begin
      if SERVER_NAME = '' then begin
        Exec('CMD.EXE', '/C start http://localhost:'+ENBWEB_PORT, '', SW_SHOW, ewNoWait, ResultCode);
      end
      else begin
        //Note that this could be a PC server (port 8081) or EMB (port 80)
        Exec('CMD.EXE', '/C start http://'+SERVER_NAME+ENBWEB_PORT_STR, '', SW_SHOW, ewNoWait, ResultCode);
      end;
    end;
  end;
end;




