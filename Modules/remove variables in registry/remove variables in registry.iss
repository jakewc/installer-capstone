[Code]

//===================================
//remove variables in windows registry
//===================================

RegDeleteKeyIncludingSubkeys(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler\Applications');
RegDeleteKeyIncludingSubkeys(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler\Backup');
RegDeleteKeyIncludingSubkeys(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler\Components');
RegDeleteKeyIncludingSubkeys(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler\SA');
RegDeleteKeyIncludingSubkeys(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler\SDK');
RegDeleteKeyIncludingSubkeys(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler\UnattendedInstall');


//When the BACKUP feature is enabled, the BACKUPDIR is initialized
If DOBACKUP = 'A' then begin
  BACKUPDIR:=BACKUP;
end;

//Rem Check free disk space calculates free disk space as well as component sizes.
//Rem It should be located before all Install File actions.
//Check free disk space

//===========================
//Remove ATL.DLL hook if preset to prevent automatic activation of MSDE setup
RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\Classes\CLSID\{44EC053A-400F-11D0-9DCD-00A0C90391D3}\InprocServer32', '(Default)', ')1pFEf=hI=DBiz@GgPxz>w.''b9VZqf(g6u.Q(31aR');