[Code]

//=============================
//Install 2008 SP1 C++ Redistributables
//=============================

procedure cplusplus();
var
  ResultCode:integer;
begin
  if SILENT = false then begin
    MsgBox('Installing VS C++ 2008 SP1 Redistributables', mbinformation, mb_OK);
  end;

  Exec(ExpandConstant('{app}\MsiQueryProduct.exe'), '{9A25302D-30C0-39D9-BD6F-21E6EC160475}', '', SW_SHOW, ewwaituntilterminated, ResultCode);

  if ResultCode = 5 then begin
    Log('INFO: Skipping VS C++ 2008 SP1 runtime - already installed');
  end
  else begin
    //try to install the runtime
    Log('Installing VS C++ SP1 Redistributables');
    Exec('CMD.exe', '/C ' + ExpandConstant('{app}\vcredist_x86.exe') + ' /q', '', SW_SHOW, ewwaituntilterminated, ResultCode);
    if ResultCode <> 0 then begin
      if ResultCode <> 3010 then begin
        if SILENT = false then begin
          MsgBox('VS C++ SP1 Redistributables install failed', mbinformation, MB_OK);
        end;
      Log('ERROR: VS C++ SP1 Redistributables install failed');
      Abort();
      end
      else begin
        Log('INFO: VS C++ SP1 Redistributables Installation reported error 3010, Reboot pending');
      end
    end    
  end
end

//old Wise script had a section 'INSTALL VS 2015 C++ REDISTRIBUTABLES' here, but it was entirely commented out