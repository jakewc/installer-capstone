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



  CMDLINEUPPER: ExpandConstant('{param:CMDLINEVAL|''}');  //  NOTE!!! You need CMDLINEVAL= to specific a command line command
  if CMDLINEVAL <> '' then begin
    CMDOPTION:= CMDLINEUPPER;
    CMDUPPER:= CMDLINEUPPER;
    CMDSTART:= CMDUPPER;
    CMDEND:= CMDUPPER;

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
    if pos('/S',CMDUPPER) then begin
      Log('SILENT install selected')
      UNATTENDED:=true
      SILENT:=true
      ERROR_RTN:=true
    end;
    if pos('/FULL',CMDUPPER) then begin
      Log('FULL Enabler Server install selected')
      UNATTENDED:=true
      COMPONENTS:='B'
      APPLICATIONS:='ABCDEF'
      if pos('/CLIENT', CMDLINEUPPER) then begin
        Log('ERROR: Cannot use /CLIENT and /FULL together')
        ExitProcess(0)
      end;
    end;
    
    if pos('/CLIENT', CMDUPPER) then begin
      Log('CLIENT install selected')
      UNATTENDED:=true;
      COMPONENTS:='A'
      if pos('/FULL', CMDLINEUPPER) then begin
        Log('ERROR: Cannot use /CLIENT and /FULL together')
        ExitProcess(0)
      end;
      if pos('/PASSWORD', CMDLINEUPPER) then begin
        Log('ERROR: Cannot use /CLIENT and /PASSWORD together')
        ExitProcess(0)
      end;
      if pos('/CLIENT:', CMDUPPER) then begin
        JUNK:=CMDOPTION
        SERVER_NAME:=CMDOPTION
        Log('Enabler Server name has been entered: '+SERVER_NAME)
      end;
    end;

    if pos('/PASSWORD', CMDUPPER) then begin
      JUNK:=CMDOPTION
      SERVER_NAME:=CMDOPTION
      CMDUPPER:='/PASSWORD:*****'
      Log('PASSWORD for SA has been entered')
    end;
    if pos('/INSTANCE', CMDUPPER) then begin
      JUNK:=CMDOPTION
      SERVER_NAME:=CMDOPTION
      CMDUPPER:= '/INSTANCE:*****'
      Log('SQL Named Instance - ' + SQL_INSTANCE)
      CMD_INSTANCE:=true;
      SQLQUERY:= PC_NAME + '\' + SQL_INSTANCE;
    end;
    if pos('/APPS:', CMDUPPER) then begin
      Log('The /APPS option was ignored - this option no longer supported.')
    end;
    if pos('/MPPSIM', CMDUPPER) then begin
      Log('Install Simulator EXE and DLL')
      SDK_OPTIONS := 'AF'
    end;
    if pos('/NOSTART', CMDUPPER) then begin
      Log('Not starting Enabler services - NOSTART selected.')
      NOSTART:=true;
    end;
    if pos('/ENABLERSDK', CMDUPPER) then begin
      Log('Install full SDK')
      SDK_OPTIONS:='ABC'
      SDK:='A'
    end;
    CMDLINE_LOG:=CMDUPPER;

    if pos('/BACKUPDB', CMDUPPER) then begin
      if COMPONENTS = 'A' then begin
        Log('INFO: /BACKUPDB option ignored. Cannot backup DB on /CLIENT install.')
      else
        PRE_UPGRADE_BACKUP:='A';
      end;
    end;
  end;

  if (SHOW_USAGE) then begin
    Log('WARNING: Install stopped to show usage.')
    
    //TODO - create dialog box "INSTALL USAGE"

    ExitProcess(0)
  end;

  Log('CMD ' + CMDLINE_LOG)