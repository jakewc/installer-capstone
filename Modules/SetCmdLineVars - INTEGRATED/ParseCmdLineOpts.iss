[Code]
//==========================
  //parse command line options
  //==========================
  CMDLINE_LOG:String;
  CMDLINEUPPER: String;
  CMDLINEVAL: String;
  CMDOPTION: String;
  CMDUPPER: String;
  CMDSTART:String;
  CMDEND: String;



procedure parseCommandLineOptions();
begin
  CMDLINEUPPER:= ExpandConstant('{param:CMDLINEVAL|}');  //  NOTE!!! You need /CMDLINEVAL='' to specify a command line command
  if CMDLINEUPPER <> '' then begin
    CMDOPTION:= CMDLINEUPPER;
    CMDUPPER:= CMDLINEUPPER;
    //Rem !!! DEBUG ONLY - COMMENT OUT FOR RELEASE !!! MAKES PASSWORD VISIBLE!!!!
    Log('Option = '+CMDUPPER);
    //Rem !!! DEBUG ONLY - COMMENT OUT FOR RELEASE !!!
    CMDSTART:= CMDUPPER;
    CMDEND:= CMDUPPER;

    //Check for /? or /h or -? or -h  - AT THE START OF THE STRING
    if CMDSTART = '-H' then begin
      Log('User requested usage -H')
      SHOW_USAGE:= true
    end;
    if CMDSTART = '-?' then begin
      Log('User requested usage -?')
      SHOW_USAGE:= true
    end;
    if CMDSTART = '/H' then begin
      Log('User requested usage /H')
      SHOW_USAGE:= true
    end;
    if CMDSTART = '/?' then begin
      Log('User requested usage /?')
      SHOW_USAGE:= true
    end;

    //Silent unattended install
    if pos('/S',CMDUPPER) <> 0 then begin
      Log('SILENT install selected')
      UNATTENDED:=true
      SILENT:=true
      //error code only for silent mode install
      ERROR_RTN:=true
    end;
    //automatic server install
    if pos('/FULL',CMDUPPER) <> 0 then begin
      Log('FULL Enabler Server install selected')
      UNATTENDED:=true
      COMPONENTS:='B'
      APPLICATIONS:='ABCDEF'
      if pos('/CLIENT', CMDLINEUPPER) <> 0 then begin
        Log('ERROR: Cannot use /CLIENT and /FULL together')
        ExitProcess(0)
      end;
    end;
    //automatic client install
    if pos('/CLIENT', CMDUPPER) <> 0 then begin
      Log('CLIENT install selected')
      UNATTENDED:=true;
      COMPONENTS:='A'
      if pos('/FULL', CMDLINEUPPER) <> 0 then begin
        Log('ERROR: Cannot use /CLIENT and /FULL together')
        ExitProcess(0)
      end;
      if pos('/PASSWORD', CMDLINEUPPER) <> 0 then begin
        Log('ERROR: Cannot use /CLIENT and /PASSWORD together')
        ExitProcess(0)
      end;

      //THESE THREE OPTIONS WITH PARAMETERS (/CLIENT:servername) MUST BE ENTERED WITHOUT A SPACE
      if pos('/CLIENT:', CMDUPPER) <> 0 then begin
        JUNK:=copy(CMDUPPER, 9, Length(CMDUPPER)-1)
        SERVER_NAME:=copy(CMDUPPER, 9, Length(CMDUPPER)-1)
        Log('Enabler Server name has been entered: '+SERVER_NAME)
      end;
    end;
    //Get SA password (used for Server installs with pre-existing SQL server)
    if pos('/PASSWORD:', CMDUPPER) <> 0 then begin
      JUNK:=copy(CMDUPPER, 11, Length(CMDUPPER)-1)
      SA_PASSWORD:=copy(CMDUPPER, 11, Length(CMDUPPER)-1)
      //this could be a problem but the .wse says this is literally the string '*****'
      CMDUPPER:='/PASSWORD:*****'
      Log('PASSWORD for SA has been entered')
    end;
    //get the sql instance name
    if pos('/INSTANCE:', CMDUPPER) <> 0 then begin
      JUNK:=copy(CMDUPPER, 11, Length(CMDUPPER)-1)
      SQL_INSTANCE:=copy(CMDUPPER, 11, Length(CMDUPPER)-1)
      //'*****' string appears here too
      CMDUPPER:= '/INSTANCE:*****'
      Log('SQL Named Instance - ' + SQL_INSTANCE)
      CMD_INSTANCE:=true;
      //Configure SQL query for the default instance or the instance name passed in the command line
      SQLQUERY:= PC_NAME + '\' + SQL_INSTANCE;
    end;
    //The APPS option is no longer supported
    if pos('/APPS:', CMDUPPER) <> 0 then begin
      Log('The /APPS option was ignored - this option no longer supported.')
    end;
    //Option to install simulators WITHOUT SDK
    if pos('/MPPSIM', CMDUPPER) <> 0 then begin
      Log('Install Simulator EXE and DLL')
      SDK_OPTIONS := 'AF'
    end;
    //Option to install but NOT start Enabler services
    if pos('/NOSTART', CMDUPPER) <> 0 then begin
      Log('Not starting Enabler services - NOSTART selected.')
      NOSTART:=true;
    end;
    //Option to install SDK automatically
    if pos('/ENABLERSDK', CMDUPPER) <> 0 then begin
      Log('Install full SDK')
      SDK_OPTIONS:='ABC'
      SDK:='A'
    end;
    //Rebuild representation of cmdline suitable for logging
    CMDLINE_LOG:=CMDUPPER;

    //Supplying the parameter /BACKUPDB will initiate a Pre-Upgrade Backup
    if pos('/BACKUPDB', CMDUPPER) <> 0 then begin
      if COMPONENTS = 'A' then begin
        Log('INFO: /BACKUPDB option ignored. Cannot backup DB on /CLIENT install.')
      end
      else begin
        PRE_UPGRADE_BACKUP:='A';
      end;
    end;
  end;

  if (SHOW_USAGE) then begin
    Log('WARNING: Install stopped to show usage.');
    
    //TODO - create dialog box "INSTALL USAGE"
    MsgBox('Install stopped to show usage', mbinformation, MB_OK);

    ExitProcess(0);
  end;

  Log('CMD ' + CMDLINE_LOG)
end;