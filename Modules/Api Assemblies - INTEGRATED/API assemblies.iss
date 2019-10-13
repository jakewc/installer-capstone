[Code]

//=================================
//API ASSEMBLIES
//==================================
begin
//FileCopy('{#SourcePath}\Input\API\ActiveX\EnbSessionX.ocx',ExpandConstant('{app}')+'\EnbSessionX.ocx', false);
//FileCopy('{#SourcePath}\Input\API\ActiveX\EnbOPTX.ocx',ExpandConstant('{app}')+'\EnbOPTX.ocx', false);
//FileCopy('{#SourcePath}\Input\API\ActiveX\EnbPumpX.ocx',ExpandConstant('{app}')+'\EnbPumpX.ocx', false);
//FileCopy('{#SourcePath}\Input\API\ActiveX\EnbAttendantX.ocx',ExpandConstant('{app}')+'\EnbAttendantX.ocx', false);
//Only include ActiveX2 controls if they're in the source directory

FileCopy('{#SourcePath}\Input\API\ActiveX\EnbSessionX2.ocx',ExpandConstant('{app}')+'\EnbSessionX2.ocx', false);
FileCopy('{#SourcePath}\Input\API\ActiveX\EnbPumpX2.ocx',ExpandConstant('{app}')+'\EnbPumpX2.ocx', false);
FileCopy('{#SourcePath}\Input\API\ActiveX\EnbAttendantX2.ocx',ExpandConstant('{app}')+'\EnbAttendantX2.ocx', false);
FileCopy('{#SourcePath}\Input\EnablerSoundEvents.reg',ExpandConstant('{app}')+'\EnablerSoundEvents.reg', false);
//Include EnbConfigX if available
if FileExists('{#SourcePath}\Input\API\EnbConfigX.ocx') then begin
  FileCopy('{#SourcePath}\Input\API\ActiveX\EnbConfigX.ocx',ExpandConstant('{app}')+'\EnbConfigX.ocx', false);
end;
//java assemblies

FileCopy('{#SourcePath}\Input\API\Java\enabler-api-1.0.jar',ExpandConstant('{app}')+'\enabler-api-1.0.jar', false);
FileCopy('{#SourcePath}\Input\Extra\joda-time-2.0.jar',ExpandConstant('{app}')+'\joda-time-2.0.jar', false);
FileCopy('{#SourcePath}\Input\Extra\joda-time-NOTICE.txt',ExpandConstant('{app}')+'\joda-time-NOTICE.txt', false);
FileCopy('{#SourcePath}\Input\Extra\joda-time-LICENSE.txt',ExpandConstant('{app}')+'\joda-time-LICENSE.txt', false);

//Enabler 4 .NET API assembly self installing package
//TODO COMMENT FOUND IN OLD WISE SCRIPT - 'update this MSI to install to different location'


if FileExists(ExpandConstant('{app}')+'InstallEnablerAPI.msi') then begin
  //uninstall the previous version before installign the new one
  Exec(ExpandCOnstant('{sys}')+'msiexec.exe' '/quiet /L+* '+ExpandConstant('{app}')+'log\APIInstall.log /uninstall {30876486-DB1A-41CE-95D0-58F1EEA13AE8}', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
  if ResultCode <> 0 then begin
    Log('INFO: Could not uninstall existing enabler API - ERRORLEVEL = ' + ResultCode);
  end;
end;

FileCopy('{#SourcePath}\API\NET\InstallEnablerAPI.msi', ExpandConstant('{app}')+'\InstallEnablerAPI.msi', false);
Exec(ExpandConstant('{sys}')+'msiexec.exe' '/quiet /L+* '+ExpandConstant('{app}')+'log\APIInstall.log /package '+ExpandConstant('{app}')+'InstallEnablerAPI.msi', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
if ResultCOde <> 0 then begin
    Log('INFO: Could not install enabler API - ERRORLEVEL = ' + ResultCode);   
    if SILENT = 0 then begin
      MsgBox('Could not install', mbinformation, mbok);
    end;
    ExitProcess(0);
  end;

//Enabler 2 WPF Controls for .NET API
FileCopy('{#SourcePath}\Input\API\NET\ITL.Enabler.WPFControls.dll',ExpandConstant('{app}')+'\ITL.Enabler.WPFControls.dll', false);
FileCopy('{#SourcePath}\Input\API\NET\System.Windows.Controls.DataVisualization.Toolkit.dll',ExpandConstant('{app}')+'\System.Windows.Controls.DataVisualization.Toolkit.dll', false);
FileCopy('{#SourcePath}\Input\API\NET\WPFToolkit.dll',ExpandConstant('{app}')+'\WPFToolkit.dll', false);








//===========================================
//uninstall previous enablerAPI.msi if exists
//===========================================

//this procedure brings up a windows installer command line options help popup IF there is an existing EnablerAPI.msi file

procedure uninstallAPIMSI();
var
  ResultCode:integer;
begin
  if (FileExists(ExpandConstant('{app}\InstallEnablerAPI.msi'))) then begin
    Exec(ExpandConstant('{sys}\msiexec.exe'), '/quiet /L+* '+ExpandConstant('{app}\log\APIInstall.log')+' /uninstall {30876486-DB1A-41CE-95D0-58F1EEA13AE8}', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    if ResultCode <> 0 then begin
      Log('INFO: Could not uninstall existing enabler API - ERRORLEVEL = ' + inttostr(ResultCode));
    end;
  end;
end;

//============================================
//install new enablerAPI.msi
//============================================
procedure installAPIMSI();
var
  ResultCode:integer;
begin
  Exec(ExpandConstant('{sys}\msiexec.exe'), '/quiet /L+* '+ExpandConstant('{app}\log\APIInstall.log')+' /package '+ExpandConstant('{app}\InstallEnablerAPI.msi'), '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
  if ResultCode <> 0 then begin
    Log('INFO: Could not install enabler API - ERRORLEVEL = ' + inttostr(ResultCode));   
    if SILENT = false then begin
      MsgBox('Could not install', mbinformation, mb_ok);
    end;
    Abort();
    end;
end;
