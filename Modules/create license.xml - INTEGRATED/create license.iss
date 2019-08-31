//====================
//create Beta License
//====================
[Code]
procedure createLicense();
var
  ResultCode:integer;
begin
  Log('Check for V4 Beta License');
  if Exec(ExpandConstant('{app}\ConvertV4BetaLicense.exe'), '/c', '',SW_SHOW, ewWaitUntilTerminated, ResultCode) then begin
    Log('Result code from COnvertV4BetaLicense was '+inttostr(ResultCode));
    if ResultCode = 0 then begin
      Log('v4.0 Beta License converted');
    end;
  end;
end;