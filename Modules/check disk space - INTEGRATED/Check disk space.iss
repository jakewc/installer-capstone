[Code]

//=============================
//Check disk space requirements
//=============================

//Hardcoded to  800MB plus the COMPONENTS. 800MB is to cover space for Applications, SDK doc, SDK app, SQL Server, MIS, .NET
//SQL 2016 - 1480MB for enginel
//SQL 2008/2012/2014 - 820MB for engine 3.8GB for complete install
//SQL 2005 - 280MB for engine, 2.0GB for complete install 
//SQL 2000 - 270MB (obsolete) 
//MPPSim - 192KB 
//Pumpdemo - 200KB 
//.NET 3.5 - 30MB 
//MSI 4.5 - 3MB - based on installer size 
//SDK Docs - 2.08MB 
//Sample Apps - 8.55MB 
//Documentation - 5.2MB

procedure checkDiskSpace();
var
  DISK_SPACE:Cardinal;
  FreeMB, TotalMB:Cardinal;
begin
  GetSpaceOnDisk(ExpandConstant('{autopf}'), true, FreeMB, TotalMB);
  DISK_SPACE:=FreeMB;
  Log('Checking disk space');
  if DISK_SPACE < 1480 then begin
    if SILENT = false then begin
      Log('Installation failed');
      MsgBox('Install failed - not enough space', mbInformation, MB_OK);
    end;
    Log('Not enough install space');
  end;
end;