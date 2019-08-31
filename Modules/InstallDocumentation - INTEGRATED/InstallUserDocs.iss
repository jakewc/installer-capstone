[Code]
//================
//install SDK docs
//=================

procedure DirectoryCopy(SourcePath, DestPath: string);
var
  FindRec: TFindRec;
  SourceFilePath: string;
  DestFilePath: string;
begin
  if FindFirst(SourcePath + '\*', FindRec) then
  begin
    try
      repeat
        if (FindRec.Name <> '.') and (FindRec.Name <> '..') then
        begin
          SourceFilePath := SourcePath + '\' + FindRec.Name;
          DestFilePath := DestPath + '\' + FindRec.Name;
          if FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY = 0 then
          begin
            if FileCopy(SourceFilePath, DestFilePath, False) then
            begin
              Log(Format('Copied %s to %s', [SourceFilePath, DestFilePath]));
            end
              else
            begin
              Log(Format('Failed to copy %s to %s', [SourceFilePath, DestFilePath]));
            end;
          end
            else
          begin
            if DirExists(DestFilePath) or CreateDir(DestFilePath) then
            begin
              Log(Format('Created %s', [DestFilePath]));
              DirectoryCopy(SourceFilePath, DestFilePath);
            end
              else
            begin
              Log(Format('Failed to create %s', [DestFilePath]));
            end;
          end;
        end;
      until not FindNext(FindRec);
    finally
      FindClose(FindRec);
    end;
  end
    else
  begin
    Log(Format('Failed to list %s', [SourcePath]));
  end;
end;

procedure SDKFiles();
var
  ResultCode:Integer;
  PDF:String;
  MICROSOFT_HELP:String;
begin
SDK_OPTIONS:='C';
  //install SDK documentation
  if pos('C',SDK_OPTIONS) <> 0 then begin
  //remove old SDK documentation
    if dirExists(ExpandConstant('{src}')+'\SDK') then begin
      DelTree(ExpandConstant('{app}')+'\SDK\Doc', true, true, true);
      DelTree(ExpandConstant('{app}')+'\SDK\DotNetPCAPI', true, true, true);
      DelTree(ExpandConstant('{app}')+'\SDK\Samples', true, true, true);
      //Install new SDK documentation
      if FileExists(ExpandConstant('{win}')+'hh.exe') then begin
        MICROSOFT_HELP:= ExpandConstant('{win}')+'hh.exe';
        Log('Microsoft help location is '+ MICROSOFT_HELP);
      end;
      DirectoryCopy(ExpandConstant('{src}\SDK'), ExpandConstant('{app}\SDK'));
      if ((OS=64) and (strtoint(OPERATING_SYSTEM) >= 6)) then begin
        Exec('C:\WINDOWS\Sysnative\CMD.EXE /c ' + ExpandConstant('{app}')+'\SDK\Doc\VisualStudio\registerhelp2.bat', '', '', SW_SHOW, ewWaitUntilTerminated, ResultCode)
        Log('Execute path: C:\WINDOWS\Sysnative\CMD.EXE /c ' + ExpandConstant('{app}')+'\SDK\Doc\VisualStudio\unregisterhelp2.bat')
      end
      else begin
        Exec('CMD.EXE /c ' + ExpandConstant('{app}')+'\SDK\Doc\VisualStudio\registerhelp2.bat', '', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
        Log('Execute path: C:\WINDOWS\Sysnative\CMD.EXE /c ' + ExpandConstant('{app}')+'\SDK\Doc\VisualStudio\unregisterhelp2.bat'); 
      end;

      if pos('B',ICONS) <> 0 then begin
        //create a bunch of links to manuals in {group}, not sure about this
        deleteFile(ExpandConstant('{group}\SDK\Database Dictionary.lnk'));
        deleteFile(ExpandConstant('{group}\SDK\Developers Guide.lnk'));
        deleteFile(ExpandConstant('{group}\SDK\Developers Reference.lnk'));
        deleteFile(ExpandConstant('{group}\SDK\Hardware Setup and Installation Manual.lnk'));
        deleteFile(ExpandConstant('{group}\SDK\Embedded Getting Started Guide.lnk'));
        deleteFile(ExpandConstant('{group}\SDK\Site Installation Checklist.lnk'));
        deleteFile(ExpandConstant('{group}\SDK\Embedded Site Installation Checklist.lnk'));
        deleteFile(ExpandConstant('{group}\SDK\Embedded REST API Reference.lnk'));

        //TODO - create replacement links
      end;
    end
    else begin
      Log('SDK folder not present in installer folder');
    end;
  end
  else begin
  //not installing SDK - remove any existing files and start menu links
    delTree(ExpandConstant('{app}\SDK'), true, true, true);
    if not dirExists(ExpandCOnstant('{app}\SDK\Samples')) then begin
      delTree(ExpandConstant('{group}\SDK'),true, true, true);
    end;
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
    Exec(SETX_PATH, ENABLER_SERVER + ' ' + SERVER_NAME + ' -M', '', SW_SHOW, ewWaitUntilTerminated, ResultCode)
  end;

  //Always install ActiveX client utility - most useful for client installs.
  if FileExists(ExpandConstant('{app}')+'\bin\enbclient.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\bin\enbclient.exe')
  end;
  if FileExists(ExpandConstant('{app}')+'\bin\Interop.IWshRuntimeLibrary.dll') then begin
    DeleteFile(ExpandConstant('{app}')+'\bin\Interop.IWshRuntimeLibrary.dll')
  end;


  //Setup PDF files to link to Sumatra PDF if there is no existing reader
  PDF:= '';
  RegQueryStringValue(HKEY_CLASSES_ROOT, '.pdf', '(Default)', PDF);
    if PDF = '' then begin
    Log('There is no current PDF reader - setting up Sumatra PDF')
    //Edit 5 registry keys
    RegWriteStringValue(HKEY_CLASSES_ROOT, 'ITLPDF.Document', '(Default)', 'ITL PDF Document');
    RegWriteStringValue(HKEY_CLASSES_ROOT, 'ITLPDF.Document\DefaultIcon', '(Default)', ExpandConstant('{app}')+'bin\PDFViewer.exe');
    RegWriteStringValue(HKEY_CLASSES_ROOT, 'ITLPDF.Document\Shell\Open\Command', '(Default)', ExpandConstant('{app}')+'bin\PDFViewer.exe'+ ' %%1');

    RegWriteStringValue(HKEY_CLASSES_ROOT, '.pdf', '(Default)', 'ITLPDF.Document');
    Log('Sumatra pdf is now default pdf reader')
  end;
end;
