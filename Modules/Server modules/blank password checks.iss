[Code]

procedure blankPasswordChecks();
begin
  if COMPONENTS = 'B' then begin
    if SQLEXPRESSNAME <> 'MSDE2000' then begin
      if SA_PASSWORD = '' then begin
        Log('Blank passwords are not allowed for ' + SQLEXPRESSFULLNAME);
        if SILENT = false then begin
          Msgbox('Passwords blank, aborting install', mbinformation, MB_OK);
        end;
        Abort();
      end;
    end;
  end;
end;