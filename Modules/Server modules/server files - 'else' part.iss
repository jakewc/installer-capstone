[files]

//====================
//Install Server files
//====================
// Install the DLL that contanis the message ids for the Enabler Windows custom log
Source:"{#SourcePath}\Input\bin\EnablerEvent.dll"; DestDir: "{app}\bin\EnablerEvent.dll";
// These files are needed later so install them here
Source:"{#SourcePath}\Input\bin\subinacl.exe"; DestDir:"{app}\bin\subinacl.exe" ;
Source:"{#SourcePath}\Input\CreateRegKeyEvent.bat"; DestDir:"{app}\CreateRegKeyEvent.bat";
// Create a variable to determine if the pdf reader needs associating
Source:"{#SourcePath}\Input\Extra\PDFViewer.exe"; DestDir:"{app}\bin\PDFViewer.exe";
//Install the SDK applications (based on client/server install)
//Install MPPSIM and Driver DLL
Source:"{#SourcePath}\Input\MPPSim.exe"; DestDir:"{app}\MPPSim.exe"; Check: IsSDK_OPTIONS('A');
Source:"{#SourcePath}\Input\ITLMPPSim.dll"; DestDir:"{app}\ITLMPPSim.dll"; Check: IsInstallType('B');
//Install Pumpdemo
Source:"{#SourcePath}\Input\pumpdemo.exe"; DestDir:"{app}\pumpdemo.exe"; Check: IsSDK_OPTIONS('B');
Source:"{#SourcePath}\Input\PumpDemoWPF.exe"; DestDir:"{app}\PumpDemoWPF.exe"; Check: IsSDK_OPTIONS('B');
Source:"{#SourcePath}\Input\SampleCom.exe"; DestDir:"{app}\SampleCom.exe"; Check: IsSDK_OPTIONS('B');
Source:"{#SourcePath}\Input\pumpdemo.jar"; DestDir:"{app}\pumpdemo.jar"; Check: IsSDK_OPTIONS('B');
Source:"{#SourcePath}\Input\enabler-pmp-ctrl-1.0.jar"; DestDir:"{app}\enabler-pmp-ctrl-1.0.jar"; Check: IsSDK_OPTIONS('B');
Source:"{#SourcePath}\Input\forms-1.3.0.jar"; DestDir:"{app}\forms-1.3.0.jar"; Check: IsSDK_OPTIONS('B');
Source:"{#SourcePath}\Input\glazedlists-1.8.0_java15.jar"; DestDir:"{app}\glazedlists-1.8.0_java15.jar"; Check: IsSDK_OPTIONS('B');
Source:"{#SourcePath}\Input\icu4j-49_1.jar"; DestDir:"{app}\icu4j-49_1.jar"; Check: IsSDK_OPTIONS('B');
Source:"{#SourcePath}\Input\miglayout15-swing.jar"; DestDir:"{app}\miglayout15-swing.jar"; Check: IsSDK_OPTIONS('B');



[code]

//========================================
//installer-wide functions
//========================================


function isSDK_OPTIONS(checkString: String):boolean;
begin
  if pos(checkString,SDK_OPTIONS) <> 0 then begin
    Result:=true;
  end
  else begin
    Result:=False;
  end;
end;


//================================================

procedure installServerFiles();
var
  ResultCode: Integer;
Begin
  if COMPONENTS = 'B' then begin
    MsgBox('skip', mbinformation, mb_OK);
  End
  else begin
    Exec(SETX_PATH, ENABLER_SERVER + ' ' + SERVER_NAME + ' -M', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    //Edit 4 Registry Keys
  end;

  Log('Group Path'+GROUP)
  Log('Group Directory'+GROUPDIR)
  Log('Desktop Path'+ DESKTOPDIR)
  Log('Start Menu Path'+STARTMENUDIR)

  DelTree(GROUP+'\',False,True,True);
  DelTree(GROUPDIR+'\The Enabler\',False,True,True);

  //TODO - Create shortcut to web apps

  // Remove old EXE applications (if they are present)
  if FileExists(ExpandConstant('{app}')+'\EnbConfig.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\EnbConfig.exe');
    DeleteFile(DESKTOPDIR+'\Enabler Configuration.Ink');
  End;
  if FileExists(ExpandConstant('{app}')+'\enbmaint.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\Enbmaint.exe');
    DeleteFile(DESKTOPDIR+'\Enabler Management.Ink');
  End;
  if FileExists(ExpandConstant('{app}')+'\EnbBlockMgr.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\EnbBlockMgr.exe');
    DeleteFile(DESKTOPDIR+'\Enabler Block Manager.Ink');
  End;
  if FileExists(ExpandConstant('{app}')+'\FCMan.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\FCMan.exe');
  End;
  if FileExists(ExpandConstant('{app}')+'\FuelReconReport.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\FuelReconReport.exe');
  End;
  if FileExists(ExpandConstant('{app}')+'\FuelRecon.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\FuelRecon.exe');
    DeleteFile(DESKTOPDIR+'\Fuel Reconciliation.Ink');
  End;
  if FileExists(ExpandConstant('{app}')+'\wetstk.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\wetstk.exe');
    DeleteFile(DESKTOPDIR+'\Wetstock Maintenance.Ink');
  End;

  //Create short cut
  if pos('A',SDK) <> 0 then begin
    SDK_OPTIONS := 'ABC'
    if pos('B',COMPONENTS) <> 0 then begin
      if pos('B',ICONS) <> 0 then begin
        if OS = 32 then begin
          //Create Shortcut from %MAINDIR%\ExpressUpdate.exe to %GROUP%\Tools\Firmware Update for Express.lnk
        end
        else
          //Create Shortcut from %MAINDIR%\ExpressUpdatex64.exe to %GROUP%\Tools\Firmware Update for Express-x64.lnk
        end;
        //Create Shortcut from %MAINDIR%\PCIUpdate.exe to %GROUP%\Tools\Firmware Update for PCI.lnk
      End;

      if pos('A',ICONS) <> 0 then begin
        if OS = 32 then begin
          //Create Shortcut from %MAINDIR%\ExpressUpdate.exe to %DESKTOPDIR%\Firmware Update for Express.lnk
        end
        else
          //Create Shortcut from %MAINDIR%\ExpressUpdatex64.exe to %DESKTOPDIR%\Tools\Firmware Update for Express-x64.lnk
        end;
        //Create Shortcut from %MAINDIR%\PCIUpdate.exe to %DESKTOPDIR%\Firmware Update for PCI.lnk
      End;
    End;
  End.

  //Install the SDK applications (based on client/server install)
  //Install MPPSIM and Driver DLL
  if pos('A',SDK_OPTIONS) then begin
    DeleteFile(GROUP+'\MPPSim.lnk');
    DeleteFile(GROUP+'\Pump Simulator.lnk');
    //TODO Create shortcut
  end
  else
    if FileExists(ExpandConstant('{app}')+'\ITLMPPSim.dll') then begin
      Exec('rsgsvr32.exe', '/u /s '+ExpandConstant('{app}')+'\ITLMPPSim.dll', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
      DeleteFile(ExpandConstant('{app}')+'ITLMPPSim.dll');
    end;
    if FileExists(ExpandConstant('{app}')+'\bin\ITLMPPSim.dll') then begin
      Exec('rsgsvr32.exe', '/u /s '+ExpandConstant('{app}')+'\bin\ITLMPPSim.dll', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
      DeleteFile(ExpandConstant('{app}')+'\bin\ITLMPPSim.dll');
    end;
    if FilsExists(ExpandConstant('{app}')+'\MPPSim.exe') then begin
      DeleteFile(ExpandConstant('{app}')+'\MPPSim.exe');
      DeleteFile(GROUP+'\MPPSim.lnk');
      DeleteFile(GROUP+'\Pump Simulator.lnk');
      DeleteFile(DESKTOPDIR+'\MPPSim.lnk');
      DeleteFile(DESKTOPDIR+'\Pump Simulator.lnk');
    end;
  end;

  if pos('B',SDK_OPTIONS) <> 0 then begin
    DeleteFile(GROUP+'Pump Demp.lnk');

    //TODO Create shortcut

  end
  else
    if FileExists(ExpandConstant('{app}')+'\pumpdemo.exe') then begin
      DeleteFile(ExpandConstant('{app}')+'\pumpdemo.exe');
      DeleteFile(GROUP+'\Pump Demo.lnk');
      DeleteFile(DESKTOPDIR+'\Pump Demo.lnk');
    end;
    if FileExists(ExpandConstant('{app}')+'\PumpDemoWPF.exe')then begin
      DeleteFile(ExpandConstant('{app}')+'\PumpDemoWPF.exe');
      DeleteFile(GROUP+'\Pump Demo WPF.lnk');
      DeleteFile(DESKTOPDIR+'\Pump Demo WPF.lnk');
    end;
    if FileExists(ExpandConstant('{app}')+'\SampleCom.exe')then begin
      DeleteFile(ExpandConstant('{app}')+'\SampleCom.exe');
      DeleteFile(GROUP+'\Sample COM.lnk');
      DeleteFile(DESKTOPDIR+'\Sample COM.lnk');      
    end;
    if FileExists(ExpandConstant('{app}')+'\pumpdemo.jar')then begin
      DeleteFile(ExpandConstant('{app}')+'\pumpdemo.jar');
      DeleteFile(GROUP+'\Pump Demo (Java).lnk');
      DeleteFile(DESKTOPDIR+'\Pump Demo (Java).lnk');  
    end;
  end;
  
  //Remove vbComOleAPI sample if it exists - this has been renamed to SampleCOM
  if FileExists(ExpandConstant('{app}')+'\vbcomapitest.exe')then begin
    DeleteFile(ExpandConstant('{app}')+'\vbcomapitest.exe');
    DeleteFile(GROUP+'\Pump COM/OLE API Test.lnk');
    DeleteFile(DESKTOPDIR+'\Pump COM/OLE API Test.lnk'); 
  end;

  DeleteFile(ExpandConstant('{app}')+'\pumpdemo2.exe')

End;

