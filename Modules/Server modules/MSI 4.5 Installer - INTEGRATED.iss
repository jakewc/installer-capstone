[Code]

//========================
//Check MSI4.5 Install
//========================

const
  MinMSIVersionMS= (4 shl 16) or 50;
  MinMSIVersionLS= (0 shl 16) or 0;

function CheckInstallMSI: Boolean;

var
  MSIVersionMS: Cardinal;
  MSIVersionLS: Cardinal;

begin
  Result := True;

  if GetVersionNumbers(ExpandConstant('{sys}\msi.dll'), MSIVersionMS, MSIVersionLS) then
    if MSIVersionMS >= MinMSIVersionMS then
      Result := False;
end;

procedure MSIInstaller();

var
  ResultCode:integer;

begin
  if COMPONENTS = 'B' then begin
    if SQL_NEEDED = true then begin
      // Check the version of MSI installed - .NET3.5 requires 4.5 
      if not CheckInstallMSI() then begin
        Log('SQL2008R2 requires MSI 4.5 and .NET 3.5 SP1 - MSI will be installed and will require a reboot.');
        //Check if we need to install the latest MSI 4.5 Installer 914 
        if not fileExists(ExpandCOnstant('{src}\Win\MSI\4.5\WindowsXP-KB942288-v3-x86.exe')) then begin
          if SILENT = false then begin
            MsgBox('MSI 4.5 Installer failed', mbinformation, MB_OK);
          end;
          Log('Missing MSI 4.5 Installer');
          Abort();
        end;

        if SILENT = false then begin
          //TODO - progress messages??
          //Display Progress message "Installing MSI 4.5 Installer" 
        end;
        Log('Installing MSI 4.5');
        
        if OPERATING_SYSTEM = '5.1' then begin
          //5.1 = Windows XP
          if OS = 32 then begin
            Exec('CMD.exe', '/C '+ExpandConstant('{src}\Win\MSI\4.5\WindowsXP-KB942288-v3-x86.exe') + ' /quiet /passive /norestart', '', SW_SHOW, ewwaituntilterminated, ResultCode);
          end
          else begin
            Exec('CMD.exe', '/C '+ExpandConstant('{src}\Win\MSI\4.5\WindowsServer2003-KB942288-v4-x64.exe') + ' /quiet /passive /norestart', '', SW_SHOW, ewwaituntilterminated, ResultCode);
          end;
        end;

        if OPERATING_SYSTEM = '5.2' then begin
          //5.2 = Windows 2003
          if OS = 32 then begin
            Exec('CMD.exe', '/C '+ExpandConstant('{src}\Win\MSI\4.5\WindowsServer2003-KB942288-v4-x86.exe') + ' /quiet /passive /norestart', '', SW_SHOW, ewwaituntilterminated, ResultCode);
          end
          else begin
            Exec('CMD.exe', '/C '+ExpandConstant('{src}\Win\MSI\4.5\WindowsServer2003-KB942288-v4-x64.exe') + ' /quiet /passive /norestart', '', SW_SHOW, ewwaituntilterminated, ResultCode);
          end;
        end;

        if OPERATING_SYSTEM = '6.0' then begin
          //6.0 = Windows Vista or Server 2008
          //msu files do not support /passive
          if OS = 32 then begin
            Exec('CMD.exe', '/C '+ExpandConstant('{src}\Win\MSI\4.5\Windows6.0-KB942288-v2-x86.msu') + ' /quiet /norestart', '', SW_SHOW, ewwaituntilterminated, ResultCode);
          end
          else begin
            Exec('CMD.exe', '/C '+ExpandConstant('{src}\Win\MSI\4.5\Windows6.0-KB942288-v2-x64.msu') + ' /quiet /norestart', '', SW_SHOW, ewwaituntilterminated, ResultCode);
          end;
        end;

        if OPERATING_SYSTEM >= '6.1' then begin
          //6.1 = Windows 7 and Windows 2008 R2
          Log('Found either Windows 7, Windows Server 2008 or Later Windows - so don''t need a newer version of MSI installed');
        end;

        if OPERATING_SYSTEM = '' then begin
          Log('Could not determine OS current version, so that we can install the correct edition of MSI 4.5');
          if SILENT = false then begin
            msgbox('Could not determine OS current version, so that we can install the correct edition of MSI 4.5, Install Aborting.', mbinformation, mb_OK);
          end;
          Abort();
        end;

        if ResultCode = 0 then begin
          Log('MSI 4.5 already installed');
        end
        else begin
          //3010 means Reboot is required. Set Runonce to Enabler Installer
          if ResultCode = 3010 then begin
            if SILENT = false then begin
              msgbox('Rebooting after MSI 4.5 Install', mbinformation, mb_ok);
            end;
            //add registry keys before rebooting
            RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler', 'Restart', 'True');
            //Stop adding this entry to the Log file. This stops this being doing on uninstall.
            //If the RunOnce key is deleted on uninstall and then Enabler is reinstalled the driver will fail its install
            //As windows requires the runonce key to be present to install drivers
            RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\Microsoft\Windows\CurrentVersion\RunOnce', 'Enabler Install', ExpandConstant('{src}')+'\Enabler4Setup.exe');
            Log('MSI 4.5 Installed - reboot pending');
            RESTART_DECISION:=TRUE;
            Abort();
          end;
          //1603 means Windows OS platform is not supported.
          if ResultCode = 1603 then begin
            if SILENT = false then begin
              msgbox('MSI 4.5 Installer Failed', mbinformation, mb_OK);
            end;
            Log('MSI 4.5 Installation Failed - Windows OS Platform not supported.');
            Abort();
          end
          else begin
            if SILENT = false then begin
              msgbox('MSI 4.5 Installer Failed', mbinformation, mb_OK);
            end;
            Log('MSI 4.5 Installation Failed');
          end;
          Abort();
        end;
      end
      else begin
        Log('The version of MSI is OK');
      end;
    end;
  end;
end;









