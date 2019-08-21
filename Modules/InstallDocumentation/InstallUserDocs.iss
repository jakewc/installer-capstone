[Code]
procedure SDKFiles();
var
  ResultCode:Integer;
  PDF:String;
  MICROSOFT_HELP:String;

begin
  //=================
  //SDK documentation
  //=================
  //install SDK documentation
  if pos('C',SDK_OPTIONS) <> 0 then begin
  //remove old SDK documentation
    if dirExists(ExpandConstant('{src}')+'\SDK') then begin
      DelTree(ExpandConstant('{app}')+'\SDK', true, true, true);
      if FileExists(ExpandConstant('{win}')+'hh.exe') then begin
  //install new SDK documentation
        MICROSOFT_HELP:= ExpandConstant('{win}')+'hh.exe'
        Log('Microsoft help location is '+ MICROSOFT_HELP)
      end;
      FileCopy('{#SourcePath}\Input\Extra\InnovaHxReg.exe', ExpandConstant('{app}')+'\SDK\Doc\VisualStudio\InnovaHxReg.exe', False);
      if (OS=64) then begin
        if OPERATING_SYSTEM >= 6 then begin
          Exec('C:\WINDOWS\Sysnative\CMD.EXE /c ' + ExpandConstant('{app}')+'\SDK\Doc\VisualStudio\registerhelp2.bat', '', '', SW_SHOW, ewWaitUntilTerminated, ResultCode)
          Log('Execute path: C:\WINDOWS\Sysnative\CMD.EXE /c ' + ExpandConstant('{app}')+'\SDK\Doc\VisualStudio\unregisterhelp2.bat') 
        end;
      end
      else begin
        Exec('CMD.EXE /c ' + ExpandConstant('{app}')+'\SDK\Doc\VisualStudio\registerhelp2.bat', '', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
        Log('Execute path: C:\WINDOWS\Sysnative\CMD.EXE /c ' + ExpandConstant('{app}')+'\SDK\Doc\VisualStudio\unregisterhelp2.bat'); 
      end;

    //TODO - if pos('B',ICONS) then begin
      //create a bunch of links to manuals in {group}, not sure about this
    else begin
      Log('SDK folder not present in installer folder');
    end;
  else begin
  //not installing SDK
  //old script deletes some directories if empty here, this is done in [Dirs] now
  end;

  //Remove OPT Simulator and DLL
  if FileExists(ExpandConstant('{app}')+'\ITLOPTSim.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\ITLOPTSim.exe')
    DeleteFile(ExpandConstant('{group}')+'\ITLOPTSim.lnk')
    DeleteFile(ExpandConstant('{userdesktop}')+'\ITLOPTSim.lnk')
  end;
  if FileExists(ExpandConstant('{app}')+'ITLOPTSim.dll') then begin
    DeleteFile(ExpandConstant('{app}')+'ITLOPTSim.dll')
  end;

  //Remove Legacy Startmenu Link
  DeleteFile(ExpandConstant('{group}')+'\Forecourt Manager.lnk')
  
  //Enabler v4 always removes the CLIENT version of PSRVR
  if FileExists(ExpandConstant('{app}')+'\psrvr.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\psrvr.exe')
  end;

  if COMPONENTS = 'A' then begin
  //Client Install to Enabler (Desktop or Embedded)
    Exec(SETX_PATH + ' ' + ENABLER_SERVER + ' ' + SERVER_NAME + ' -M', '', '', SW_SHOW, ewWaitUntilTerminated, ResultCode)
  end;

  //Always install ActiveX client utility - most useful for client installs.
  FileCopy('{#SourcePath}\Input\\bin\enbclient.exe', ExpandConstant('{app}')+'\enbclient.exe', False);
  if FileExists(ExpandConstant('{app}')+'\bin\enbclient.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\bin\enbclient.exe')
  end;
  FileCopy('{#SourcePath}\Input\bin\Interop.IWshRuntimeLibrary.dll', ExpandConstant('{app}')+'\Interop.IWshRuntimeLibrary.dll', False);
  if FileExists(ExpandConstant('{app}')+'\bin\Interop.IWshRuntimeLibrary.dll') then begin
    DeleteFile(ExpandConstant('{app}')+'\bin\Interop.IWshRuntimeLibrary.dll')
  end;


  //Setup PDF files to link to Sumatra PDF if there is no existing reader
  PDF:= '';
  //TODO - get reg key .pdf place in PDF
  if PDF = '' then begin
    Log('There is no current PDF reader - setting up Sumatra PDF')
    //Edit 5 registry keys
    RegWriteStringValue(HKEY_CLASSES_ROOT, 'ITLPDF.Document', '(Default)', 'ITL PDF Document');
    RegWriteStringValue(HKEY_CLASSES_ROOT, 'ITLPDF.Document\DefaultIcon', '(Default)', ExpandConstant('{app}')+'bin\PDFViewer.exe');
    RegWriteStringValue(HKEY_CLASSES_ROOT, 'ITLPDF.Document\Shell\Open\Command', '(Default)', ExpandConstant('{app}')+'bin\PDFViewer.exe'+ ' %%1');

    //registry key .pdf = ITLPDF.Document
    Log('Sumatra pdf is now default pdf reader')
  end;
end;
end;
end;
