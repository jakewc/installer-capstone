[Code]  
//=================================================================
//Return from a restart
//=================================================================

//See if we are restarting because of an MSDE or MSI Installer or .NET restart

//!!!!NOTE: THE RESTART KEY IS CREATED IN THE 'REBOOT' MODULE
//!!!!IF THE RESTART KEY EXISTS AND ISN'T DELETED BEFORE SETUP FINISHES, WE WILL ALWAYS HIT THIS BLOCK - THE KEY MUST BE DELETED LATER ON IN .NET 3.5 SP1 MODULE IF IT EXISTS

procedure returnFromRestart();
begin
  RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler', 'Restart',RESTART)
  RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler', 'InstallComponents',LAST_COMPONENTS)
  if RESTART <> '' then begin
    Log('Restarting from previous installation reboot.');
    PHASE2:=True;
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler','Restart', 'True');
    //load the variables from the registry. Components, SDK and Applications have done this already by this point
    RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler', 'Backup',PRE_UPGRADE_BACKUP);
    RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler', 'SA',SA_PASSWORD);
    RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler', 'UnattendedInstall',UNATTENDED);
    RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler', 'InstanceName',SQL_INSTANCE);
  end
  else if LAST_COMPONENTS <> '' then begin
    Log('Restarting from MSDE 2000 reboot.');
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler','InstallComponents', COMPONENTS);
    if SQL_NEEDED then begin
      if UNATTENDED = '0' then begin
        MsgBox('Could not locate MSDE', mbInformation, MB_OK);
      end;
      Log('ERROR:Continuing a previous install - MSDE was not located');
      Abort();
    end;
    PHASE2:=true;
    COMPONENTS:=LAST_COMPONENTS; 

    if SILENT then begin
      MsgBox(APPTITLE +' - Continuing Install', mbinformation, mb_OK);
    end;
    Log('Continuing Install' );

    sleep(5000);

    if SILENT then begin
      MsgBox('Not sure what this is for', mbinformation, mb_OK);
    end;
  end;

  //The SDK option is available if the SDK folder is present
  if DirExists(ExpandConstant('{src}\SDK')) then begin
    SDK_APPS:= 1;
  end;
end;


//==========================================
//End
//==========================================