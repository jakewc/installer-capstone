[Code]


//================================
//update system config
//================================

//All OCX/DLL/EXE files that are self-registered
//Self-Register OCXs/DLLs/EXEs

//Enabler v4 configure default regsitry key for Client Username and Password
procedure updateSystemConfig();
begin
  if COMPONENTS = 'B' then begin
    //SERVER installation
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER\Client', 'Hostname', 'localhost');
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER\Client', 'Password', 'Default');
  end
  else begin
    //client intallation
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER\Client', 'Hostname', SERVER_NAME);
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\ENABLER\Client', 'Passsword', 'Default');
  end;
end; 