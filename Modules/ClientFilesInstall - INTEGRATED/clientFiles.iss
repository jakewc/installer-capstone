[Files]
//=========================
//install Third-Party DLLs
//=========================
Source: "{#SourcePath}\ClientInstallInput\Extra\comdlg32.ocx"; DestDir: "{app}";
Source: "{#SourcePath}\ClientInstallInput\Extra\comct232.ocx"; DestDir: "{app}";
Source: "{#SourcePath}\ClientInstallInput\Extra\comctl32.ocx"; DestDir: "{app}";
Source: "{#SourcePath}\ClientInstallInput\Extra\Mscomm32.ocx"; DestDir: "{app}";
Source: "{#SourcePath}\ClientInstallInput\Extra\Msflxgrd.ocx"; DestDir: "{app}";
Source: "{#SourcePath}\ClientInstallInput\Extra\Msrdc20.ocx"; DestDir: "{app}";
Source: "{#SourcePath}\ClientInstallInput\Extra\Msrdo20.dll"; DestDir: "{app}";
Source: "{#SourcePath}\ClientInstallInput\Extra\Msvcp60.dll"; DestDir: "{app}";  


//==================
//Security components
//==================
Source: "{#SourcePath}\ClientInstallInput\EnbSecurityController.exe"; DestDir: "{app}"; Flags: skipifsourcedoesntexist;
Source: "{#SourcePath}\ClientInstallInput\SecurityModule.dll"; DestDir: "{app}"; Flags: skipifsourcedoesntexist;
Source: "{#SourcePath}\ClientInstallInput\AuditTrail.dll"; DestDir: "{app}"; Flags: skipifsourcedoesntexist;
Source: "{#SourcePath}\ClientInstallInput\itl.ico"; DestDir: "{app}";

//for modules not worked on yet
Source: "{#SourcePath}\ClientInstallInput\API\ActiveX\EnbSessionX2.ocx"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\bin\EnablerEvent.dll"; DestDir: "{app}\bin"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\Extra\PDFViewer.exe"; DestDir: "{app}\bin"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\bin\odbcnfg.exe"; DestDir: "{app}\bin"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\bin\odbcnfg64.exe"; DestDir: "{app}\bin"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\bin\setx64.exe"; DestDir: "{app}\bin"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\bin\subinacl.exe"; DestDir: "{app}\bin"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\bin\atutil.exe"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\enbkick.exe"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\autosupport.exe"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\CreateRegKeyEvent.bat"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\ConvertV4BetaLicense.exe"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\API\Java\enabler-api-1.0.jar"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\EnablerSoundEvents.reg"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\API\ActiveX\EnbAttendantX2.ocx"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\bin\enbclient.exe"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\EnbKick.exe"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\API\ActiveX\EnbPumpX2.ocx"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\scripts\Instances.bat"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\bin\Interop.IWshRuntimeLibrary.dll"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\API\NET\ITL.Enabler.WPFControls.dll"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\EnbSecurityController.exe"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\Extra\joda-time-2.0.jar"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\Extra\joda-time-LICENSE.txt"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\Extra\joda-time-NOTICE.txt"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\MsiQueryProduct.exe"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\API\NET\System.Windows.Controls.DataVisualization.Toolkit.dll"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\Extra\vcredist_x86.exe"; DestDir: "{app}"; Check: IsInstallType('A');
Source: "{#SourcePath}\ClientInstallInput\API\NET\WPFToolkit.dll"; DestDir: "{app}"; Check: IsInstallType('A');

//has several conditions to check
Source: "{#SourcePath}\ClientInstallInput\API\NET\InstallEnablerApi.msi"; DestDir: "{app}"; Check: IsInstallType('A');

[Dirs]
Name: "{app}\Docs";