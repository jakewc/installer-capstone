[Files]

//Enabler Database scripts and batch files
Source: "{#SourcePath}\Input\scripts\DbInstall.bat"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\DbUpgrade.bat"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\AfterRestore.sql"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\attach.sql"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\checkdb.sql"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\config70.sql"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\DefaultData.sql"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\enabler.sql"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\eic.sql"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\Load.sql"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\mkUpgrade.sql"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\populate.sql"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\LOADEnbConfigX.sql"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\dbfix.sql"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\drop.sql"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\nightly.bat"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\nightly.sql"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\EnablerRestore.bat"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\sql70.bat"; DestDir: "{app}"; Check: IsInstallType('B');

//Enabler server executables
Source: "{#SourcePath}\Input\bin\ExpressUpdate.exe"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\ExpressUpdatex64.exe"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\PCIUpdate.exe"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\psrvr4.exe"; DestDir: "{app}\bin"; Check: IsInstallType('B');

//batch files
Source: "{#SourcePath}\Input\scripts\onmains.bat"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\onbatt.bat"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\Commslst.bat"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\commsest.bat"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\comlstbt.bat"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\battlow.bat"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\battgood.bat"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\scripts\battflat.bat"; DestDir: "{app}"; Check: IsInstallType('B');

//Copy version EIC.INF file - for USB connection to new hardware
Source: "{#SourcePath}\Input\EicGX.inf"; DestDir: "{app}"; Check: IsInstallType('B');

//Install Enabler E firmware
Source: "{#SourcePath}\Input\EicMain2.hex"; DestDir: "{app}"; Check: IsInstallType('B');

//Web Server files and assemblies
Source: "{#SourcePath}\Input\bin\OpenNETCF.SSL.dll"; DestDir: "{app}\bin"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\OpenNETCF.web.dll"; DestDir: "{app}\bin"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\OpenNETCF.web.html.dll"; DestDir: "{app}\bin"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\Utilities.dll"; DestDir: "{app}\bin"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\Newtonsoft.Json.dll"; DestDir: "{app}\bin"; Check: IsInstallType('B');
//SSL Files
Source: "{#SourcePath}\Input\bin\openssl.exe"; DestDir: "{app}\bin"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\libeay32.dll"; DestDir: "{app}\bin"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\ssleay32.dll"; DestDir: "{app}\bin"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\openssl.cnf"; DestDir: "{app}\bin"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\openssl-license.txt"; DestDir: "{app}\bin"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\SecureBlackbox.dll"; DestDir: "{app}\bin"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\SecureBlackbox.SSLCommon.dll"; DestDir: "{app}\bin"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\SecureBlackbox.SSLServer.dll"; DestDir: "{app}\bin"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\SecureBlackbox.Mail.dll"; DestDir: "{app}\bin"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\SecureBlackbox.MIME.dll"; DestDir: "{app}\bin"; Check: IsInstallType('B');

Source: "{#SourcePath}\Input\bin\enbweb.exe"; DestDir: "{app}\bin"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\enbweb.exe.config"; DestDir: "{app}\bin"; Check: IsInstallType('B');

//Assembly containing English resource strings
Source: "{#SourcePath}\Input\www\bin\WebPages.dll"; DestDir: "{app}\www\bin"; Check: IsInstallType('B');

//Assembly containing RestData API
Source: "{#SourcePath}\Input\bin\RESTData.dll"; DestDir: "{app}\bin"; Check: IsInstallType('B');

//Assembly containing English resource strings
Source: "{#SourcePath}\Input\bin\PageResources.dll"; DestDir: "{app}\bin"; Check: IsInstallType('B');
//Satellite assemblies for specific languages
Source: "{#SourcePath}\Input\bin\es\PageResources.resources.dll"; DestDir: "{app}\bin\es"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\fr\PageResources.resources.dll"; DestDir: "{app}\bin\fr"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\id\PageResources.resources.dll"; DestDir: "{app}\bin\id"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\it-IT\PageResources.resources.dll"; DestDir: "{app}\bin\it-IT"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\pt-BR\PageResources.resources.dll"; DestDir: "{app}\bin\pt-BR"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\ru\PageResources.resources.dll"; DestDir: "{app}\bin\ru"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\sl\PageResources.resources.dll"; DestDir: "{app}\bin\sl"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\th\PageResources.resources.dll"; DestDir: "{app}\bin\th"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\bin\zh-CHS\PageResources.resources.dll"; DestDir: "{app}\bin\zh-CHS"; Check: IsInstallType('B');

//Web Files
Source: "{#SourcePath}\Input\www\css\Enabler.css"; DestDir: "{app}\www\css"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\css\EnablerPrintReport.css"; DestDir: "{app}\www\css"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\css\EnablerReport.css"; DestDir: "{app}\www\css"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\css\EnablerSiteMonitor.css"; DestDir: "{app}\www\css"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\css\EnablerTable.css"; DestDir: "{app}\www\css"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\css\Login.css"; DestDir: "{app}\www\css"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\css\menu.css"; DestDir: "{app}\www\css"; Check: IsInstallType('B');
//images
Source: "{#SourcePath}\Input\www\images\bluecircle.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\down.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_ar.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_au.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_bo.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_br.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_ca.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_cl.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_cn.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_el.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_es.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_fi.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_fr.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_gb.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_gu.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_hk.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_id.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_in.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_ir.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_it.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_ml.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_mx.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_nz.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_om.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_pe.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_ph.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_pk.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_ru.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_si.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_th.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_us.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\flag_za.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\folder.gif"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\greenarrow.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\greentick.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\greenticksmall.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\incompletesmall.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\logo.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
//animations+gifs
Source: "{#SourcePath}\Input\www\images\pumpx-animate.gif"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\RedCross.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\RedCrossSmall.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\tools32.png"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\tableft.gif"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\tableft.jpg"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\tableftactive.gif"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\tableftactive.jpg"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\tabright.gif"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\tabright.jpg"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\tabrightactive.gif"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\tabrightactive.jpg"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\text.gif"; DestDir: "{app}\www\images"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\textfolder.gif"; DestDir: "{app}\www\images"; Check: IsInstallType('B');

//information icons
Source: "{#SourcePath}\Input\www\images\icons\critical.png"; DestDir: "{app}\www\images\icons"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\icons\error.png"; DestDir: "{app}\www\images\icons"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\icons\information.png"; DestDir: "{app}\www\images\icons"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\icons\warning.png"; DestDir: "{app}\www\images\icons"; Check: IsInstallType('B');

//pump pngs
Source: "{#SourcePath}\Input\www\images\pump\authed.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\autheddisabled.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\calling.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\calling1.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\callingdisabled.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\deliveringdisabled.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\deliverying.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\error.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\errordelivery.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\invalidprice.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\MECHANICAL.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\notinstalled.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\nozout.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\nozzle.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\nozzledisabled.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\nozzleoutdisabled1.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\nozzleoutdisabled2.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\PREAUTHAUTH.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\preauthautheddisabled.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\preauthdel.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\preauthDeliveringDisabled.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\preauthres.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\preauthreserveddisabled.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\prepayauth.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\prepayautheddisabled.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\prepaydel.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\prepaydeliveringdisabled.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\prepayres.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\prepayreserveddisabled.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\pricechange.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\pumpbusy.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\refundlost.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\refundlostdisabled.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\stopped.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\stopped1.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\stopped1disabled.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\stopped2.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\stopped2disabled.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\stoppeddisabled.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\totalslost.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\pump\undefinederror.png"; DestDir: "{app}\www\images\pump"; Check: IsInstallType('B');

//tank gauge
Source: "{#SourcePath}\Input\www\images\tankgauge\capacity.png"; DestDir: "{app}\www\images\tankgauge"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\tankgauge\ullage.png"; DestDir: "{app}\www\images\tankgauge"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\tankgauge\volume.png"; DestDir: "{app}\www\images\tankgauge"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\images\tankgauge\water.png"; DestDir: "{app}\www\images\tankgauge"; Check: IsInstallType('B');

Source: "{#SourcePath}\Input\www\reports\DailyTankReport.xsl"; DestDir: "{app}\www\reports"; Check: IsInstallType('B');

//scripts
Source: "{#SourcePath}\Input\www\scripts\ActivationScripts.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\AttendantTotalsScripts.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\BlockingScripts.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\CommonScripts.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\datepicker.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\EventReportScripts.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\FuelReconDataScripts.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\FuelReconMeter.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\FuelTransactionScripts.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\GradesScripts.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\GridSelector.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\jquery.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\PortScripts.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\PumpScripts.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\PumpTotalsScripts.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\SiteConfigurationScripts.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\SiteModesScripts.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\sitemonitor.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\TagControllersScripts.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\TankGaugeScripts.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\TankScripts.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\TankTotalsScripts.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\TerminalScripts.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\UsersScripts.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\WetstockPumpData.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\WetstockTankData.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\FuelReconDips.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\GradePrices.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\FuelReconMovements.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\scripts\AttendantScripts.js"; DestDir: "{app}\www\scripts"; Check: IsInstallType('B');

Source: "{#SourcePath}\Input\www\favicon.ico"; DestDir: "{app}\www"; Check: IsInstallType('B');

Source: "{#SourcePath}\Input\www\Activate.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\Attendants.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\AttendantTotals.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\Blocking.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\BlockingStatus.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\Cards.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\Contacts.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\DeliveryHistory.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\Events.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\Fallback.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\FuelReconData.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\FuelReconDips.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\FuelReconMeters.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\FuelReconMovements.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\FuelTransactionHistory.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\GradePricesScheduled.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\GradePrices.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\Grades.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\Language.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\Login.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\Logoff.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\MonitorState.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\Ports.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\Pumps.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\PumpTotals.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\SiteConfiguration.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\SiteModes.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\SiteModeChange.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\SiteMonitor.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\SiteSettings.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\SystemStatus.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\Tags.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\TagControllers.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\TankGauges.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\TankTotals.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\Tanks.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\Terminals.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\Users.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\wetstockpumpdata.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\www\wetstocktankdata.aspx"; DestDir: "{app}\www"; Check: IsInstallType('B');

//pump update install
Source: "{#SourcePath}\Input\update\PumpUpdate.exe"; DestDir: "{app}"; Check: IsInstallType('B');
Source: "{#SourcePath}\Input\update\PumpUpdate.ini"; DestDir: "{app}"; Check: IsInstallType('B');




[Code]


procedure serverFiles();

begin
  if COMPONENTS = 'B' then begin
    //Environment and Registry variables
    Exec(SETX_PATH, ENABLER_SERVER+ ' ' +ENV_COMPUTERNAME+ ' -M', '', SW_SHOW, ewwaituntilterminated, ResultCode);
    Exec(SETX_PATH, ENABLER_WEB+ ' ' +ExpandConstant('{app}\www')+ ' -M', '', SW_SHOW, ewwaituntilterminated, ResultCode);
    Exec(SETX_PATH, ENABLER_BIN+ ' ' +ExpandConstant('{app}\bin')+ ' -M', '', SW_SHOW, ewwaituntilterminated, ResultCode);
    Exec(SETX_PATH, ENABLER_DB+ ' ' +DBDIR+ ' -M', '', SW_SHOW, ewwaituntilterminated, ResultCode);


    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler', 'Bin', ExpandConstant('{app}\bin');
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler', 'Database', 'enablerdb');
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler', 'DatabasePath', 'C:\EnablerDB');
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler', 'ServerName', ENV_COMPUTERNAME);
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler', 'Web', ExpandConstant('{app}\www');

    if FileExists(ExpandCOnstant('{app}\nightly70.bat') then begin
      deleteFile(ExpandCOnstant('{app}\nightly70.bat');
      //Remove any schedule entry for the nightly backup (just in case the server software was previous installed)
      Exec(ExpandCOnstant('{app}\atutil.exe', '/d \Enalber\nightly','',SW_SHOW,ewwaituntilterminated,ResultCode);
    end;

    if FileExists(ExpandCOnstant('{app}\nightly.bat') then begin
      deleteFile(ExpandCOnstant('{app}\nightly.bat');
      //Remove any schedule entry for the nightly backup (just in case the server software was previous installed)
      Exec(ExpandCOnstant('{app}\atutil.exe', '/d '+ExpandConstant('{app}\Enalber\nightly'),'',SW_SHOW,ewwaituntilterminated,ResultCode);
    end;

    DeleteFile(ExpandCOnstant('{app}\Install.exe');
    DeleteFile(ExpandCOnstant('{app}\vsql.exe');


    //Customer or integrator branding; customer configurable files

    if FileExists(ExpandCOnstant('{src}\branding\integrator.xml')) then begin
      FileCopy(ExpandCOnstant('{src}\branding\integrator.xml'),ExpandCOnstant('{app}\integrator\integrator.xml'));
    end
    else begin
      deletefile(ExpandCOnstant('{app}\integrator\integrator.xml');
    end;

    //These are now combined into the EnbWeb/WebPages assembly by the obsfucator. Delete these files if they exists!

    deletefile(ExpandCOnstant('{app}\bin\DataAccess.dll');
    deletefile(ExpandCOnstant('{app}\bin\DataEntity.dll');
    deletefile(ExpandCOnstant('{app}\bin\DataModules.dll');
    deletefile(ExpandCOnstant('{app}\bin\DataValidation.dll');
    deletefile(ExpandCOnstant('{app}\bin\WebData.dll');

    if fileexists(ExpandCOnstant('{app}\bin\webhost.exe')) then begin
      Exec(ExpandCOnstant('{app}\bin\webhost.exe', '/uninstall','',SW_SHOW,ewwaituntilterminated,ResultCode);
    end;

    if fileexists(ExpandCOnstant('{app}\bin\enbweb.exe')) then begin
      Exec(ExpandCOnstant('{app}\bin\enbweb.exe', '/stop','',SW_SHOW,ewwaituntilterminated,ResultCode);
      Exec(ExpandCOnstant('{app}\bin\enbweb.exe', '/uninstall','',SW_SHOW,ewwaituntilterminated,ResultCode);
    end;

    //Insert line "DefaultPort="%ENBWEB_PORT%"" into text file %MAINDIR%\bin\EnbWeb.exe.config.
    //Insert line "Domain="%ENBWEB_DOMAIN%"" into text file %MAINDIR%\EnbWeb.exe.config.

    deletefile(ExpandCOnstant('{app}\WebHost.exe.config');
    deletefile(ExpandCOnstant('{app}\WebHost.exe');

    if fileexists(ExpandCOnstant('{src}\branding\logo-web.png')) then begin
      filecopy(ExpandCOnstant('{src}\branding\logo-web.png'), ExpandCOnstant('{app}\www\images\logo.png'));
    end;

    // Add firewall rules for Enabler Pump Server and EnbWeb 2410    
    //NOTE: 5.1 = Windows XP 2411    
    //NOTE: 5.2 = Windows 2003 2412    
    //NOTE: 6.0 = Windows Vista or Windows Server 2008
  
    if SILENT = false then begin
      //progress message 'Adding Firewall rules...'
    end;

    if OPERATING_SYSTEM >= 6.0 then begin
      Log('Updating Windows Advanced Firewall Rules');
      // New Advanced Firewall (Vista and later) - need to delete previous rules to avoid duplicates.
      Exec('netsh', 'advfirewall firewall delete rule name="Enabler Web Server" program='+ExpandConstant('{app}\bin\enbweb.exe'),'', SW_SHOW,ewwaituntilterminated,ResultCode);
      Log('Removed old Firewall rule for Web Server '+inttostr(ResultCOde));
      Exec('netsh', 'advfirewall firewall delete rule name="Enabler Pump Server" program='+ExpandConstant('{app}\bin\psrvr4.exe'),'', SW_SHOW,ewwaituntilterminated,ResultCode);
      Log('Removed old Firewall rule for Pump Server '+inttostr(ResultCOde));
      Exec('netsh', 'advfirewall firewall add rule name="Enabler Web Server" dir=in action=allow program='+ExpandConstant('{app}\bin\enbweb.exe')+ ' enable=yes','', SW_SHOW,ewwaituntilterminated,ResultCode);
      Log('Added Firewall rule for Web Server '+inttostr(ResultCOde));
      Exec('netsh', 'advfirewall firewall add rule name="Enabler Pump Server" dir=in action=allow program='+ExpandConstant('{app}\bin\psrvr4.exe')+ ' enable=yes','', SW_SHOW,ewwaituntilterminated,ResultCode);
      Log('Added Firewall rule for Pump Server '+inttostr(ResultCOde));
    end
    else begin
      //windows XP style firewall
      Log('Updating Windows Firewall Rules');
      Exec('netsh', 'firewall set allowedprogram program='+ExpandConstant('{app}\bin\enbweb.exe')+ ' name="Enabler Web Server" mode=enable', '', SW_SHOW, ewwaituntilterminated, resultcode);
      Log('Added Firewall rule for Web Server '+inttostr(ResultCOde));
      Exec('netsh', 'firewall set allowedprogram program='+ExpandConstant('{app}\bin\psrvr4.exe')+ ' name="Enabler Pump Server" mode=enable', '', SW_SHOW, ewwaituntilterminated, resultcode);
      Log('Added Firewall rule for Pump Server '+inttostr(ResultCOde));
    end;

    //obsolete or renamed file
    deletefile(ExpandConstant('{app}\www\Welcome.aspx'));

      
      
      



procedure installServerFiles();
var
  ResultCode: Integer;
Begin
  if COMPONENTS = 'B' then begin
    //Environment and Registry variables
    Exec(SETX_PATH,  'ENABLER_SERVER' +ENV_COMPUTERNAME+ ' -M', '', SW_SHOW, ewwaituntilterminated, ResultCode);
    Exec(SETX_PATH, 'ENABLER_WEB' +ExpandConstant('{app}\www')+ ' -M', '', SW_SHOW, ewwaituntilterminated, ResultCode);
    Exec(SETX_PATH, 'ENABLER_BIN' +ExpandConstant('{app}\bin')+ ' -M', '', SW_SHOW, ewwaituntilterminated, ResultCode);
    Exec(SETX_PATH, 'ENABLER_DB' +DBDIR+ ' -M', '', SW_SHOW, ewwaituntilterminated, ResultCode);


    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler', 'Bin', ExpandConstant('{app}\bin'));
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler', 'Database', 'enablerdb');
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler', 'DatabasePath', 'C:\EnablerDB');
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler', 'ServerName', ENV_COMPUTERNAME);
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'Software\ITL\Enabler', 'Web', ExpandConstant('{app}\www'));

    if FileExists(ExpandCOnstant('{app}\nightly70.bat')) then begin
      deleteFile(ExpandCOnstant('{app}\nightly70.bat'));
      //Remove any schedule entry for the nightly backup (just in case the server software was previous installed)
      Exec(ExpandCOnstant('{app}\atutil.exe'), '/d \Enalber\nightly','',SW_SHOW,ewwaituntilterminated,ResultCode);
    end;

    if FileExists(ExpandCOnstant('{app}\nightly.bat'))then begin
      deleteFile(ExpandCOnstant('{app}\nightly.bat'));
      //Remove any schedule entry for the nightly backup (just in case the server software was previous installed)
      Exec(ExpandCOnstant('{app}\atutil.exe'), '/d '+ExpandConstant('{app}\Enalber\nightly'),'',SW_SHOW,ewwaituntilterminated,ResultCode);
    end;

    DeleteFile(ExpandCOnstant('{app}\Install.exe'));
    DeleteFile(ExpandCOnstant('{app}\vsql.exe'));


    //Customer or integrator branding; customer configurable files

    if FileExists(ExpandCOnstant('{src}\branding\integrator.xml')) then begin
      FileCopy(ExpandCOnstant('{src}\branding\integrator.xml'),ExpandCOnstant('{app}\integrator\integrator.xml'),true);
    end
    else begin
      deletefile(ExpandCOnstant('{app}\integrator\integrator.xml'));
    end;

    //These are now combined into the EnbWeb/WebPages assembly by the obsfucator. Delete these files if they exists!

    deletefile(ExpandCOnstant('{app}\bin\DataAccess.dll'));
    deletefile(ExpandCOnstant('{app}\bin\DataEntity.dll'));
    deletefile(ExpandCOnstant('{app}\bin\DataModules.dll'));
    deletefile(ExpandCOnstant('{app}\bin\DataValidation.dll'));
    deletefile(ExpandCOnstant('{app}\bin\WebData.dll'));

    if fileexists(ExpandCOnstant('{app}\bin\webhost.exe')) then begin
      Exec(ExpandCOnstant('{app}\bin\webhost.exe'), '/uninstall','',SW_SHOW,ewwaituntilterminated,ResultCode);
    end;

    if fileexists(ExpandCOnstant('{app}\bin\enbweb.exe')) then begin
      Exec(ExpandCOnstant('{app}\bin\enbweb.exe'), '/stop','',SW_SHOW,ewwaituntilterminated,ResultCode);
      Exec(ExpandCOnstant('{app}\bin\enbweb.exe'), '/uninstall','',SW_SHOW,ewwaituntilterminated,ResultCode);
    end;

    //Insert line "DefaultPort="%ENBWEB_PORT%"" into text file %MAINDIR%\bin\EnbWeb.exe.config.
    //Insert line "Domain="%ENBWEB_DOMAIN%"" into text file %MAINDIR%\EnbWeb.exe.config.

    deletefile(ExpandCOnstant('{app}\WebHost.exe.config'));
    deletefile(ExpandCOnstant('{app}\WebHost.exe'));

    if fileexists(ExpandCOnstant('{src}\branding\logo-web.png')) then begin
      filecopy(ExpandCOnstant('{src}\branding\logo-web.png'), ExpandCOnstant('{app}\www\images\logo.png'),true);
    end;

    // Add firewall rules for Enabler Pump Server and EnbWeb 2410    
    //NOTE: 5.1 = Windows XP 2411    
    //NOTE: 5.2 = Windows 2003 2412    
    //NOTE: 6.0 = Windows Vista or Windows Server 2008
  
    if SILENT = false then begin
      //progress message 'Adding Firewall rules...'
    end;

    if OPERATING_SYSTEM >= '6' then begin
      Log('Updating Windows Advanced Firewall Rules');
      // New Advanced Firewall (Vista and later) - need to delete previous rules to avoid duplicates.
      Exec('netsh', 'advfirewall firewall delete rule name="Enabler Web Server" program='+ExpandConstant('{app}\bin\enbweb.exe'),'', SW_SHOW,ewwaituntilterminated,ResultCode);
      Log('Removed old Firewall rule for Web Server '+inttostr(ResultCOde));
      Exec('netsh', 'advfirewall firewall delete rule name="Enabler Pump Server" program='+ExpandConstant('{app}\bin\psrvr4.exe'),'', SW_SHOW,ewwaituntilterminated,ResultCode);
      Log('Removed old Firewall rule for Pump Server '+inttostr(ResultCOde));
      Exec('netsh', 'advfirewall firewall add rule name="Enabler Web Server" dir=in action=allow program='+ExpandConstant('{app}\bin\enbweb.exe')+ ' enable=yes','', SW_SHOW,ewwaituntilterminated,ResultCode);
      Log('Added Firewall rule for Web Server '+inttostr(ResultCOde));
      Exec('netsh', 'advfirewall firewall add rule name="Enabler Pump Server" dir=in action=allow program='+ExpandConstant('{app}\bin\psrvr4.exe')+ ' enable=yes','', SW_SHOW,ewwaituntilterminated,ResultCode);
      Log('Added Firewall rule for Pump Server '+inttostr(ResultCOde));
    end
    else begin
      //windows XP style firewall
      Log('Updating Windows Firewall Rules');
      Exec('netsh', 'firewall set allowedprogram program='+ExpandConstant('{app}\bin\enbweb.exe')+ ' name="Enabler Web Server" mode=enable', '', SW_SHOW, ewwaituntilterminated, resultcode);
      Log('Added Firewall rule for Web Server '+inttostr(ResultCOde));
      Exec('netsh', 'firewall set allowedprogram program='+ExpandConstant('{app}\bin\psrvr4.exe')+ ' name="Enabler Pump Server" mode=enable', '', SW_SHOW, ewwaituntilterminated, resultcode);
      Log('Added Firewall rule for Pump Server '+inttostr(ResultCOde));
    end;

    //obsolete or renamed file
    deletefile(ExpandConstant('{app}\www\Welcome.aspx'));
  End
  else begin
    Exec(SETX_PATH, ENABLER_SERVER + ' ' + SERVER_NAME + ' -M', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\ITL\Enabler','ServerName', SERVER_NAME);
  end;

  Log('Group Path'+GROUP)
  Log('Group Directory'+GROUPDIR)
  Log('Desktop Path'+ DESKTOPDIR)
  Log('Start Menu Path'+STARTMENUDIR)

  DelTree(GROUP+'\',False,True,True);
  DelTree(GROUPDIR+'\The Enabler\',False,True,True);

  //TODO - Create shortcut to web apps

  // Remove old EXE applications (if they are present)
  if FileExists(ExpandConstant('{app}')+'\EnbConfig.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\EnbConfig.exe');
    DeleteFile(DESKTOPDIR+'\Enabler Configuration.Ink');
  End;
  if FileExists(ExpandConstant('{app}')+'\enbmaint.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\Enbmaint.exe');
    DeleteFile(DESKTOPDIR+'\Enabler Management.Ink');
  End;
  if FileExists(ExpandConstant('{app}')+'\EnbBlockMgr.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\EnbBlockMgr.exe');
    DeleteFile(DESKTOPDIR+'\Enabler Block Manager.Ink');
  End;
  if FileExists(ExpandConstant('{app}')+'\FCMan.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\FCMan.exe');
  End;
  if FileExists(ExpandConstant('{app}')+'\FuelReconReport.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\FuelReconReport.exe');
  End;
  if FileExists(ExpandConstant('{app}')+'\FuelRecon.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\FuelRecon.exe');
    DeleteFile(DESKTOPDIR+'\Fuel Reconciliation.Ink');
  End;
  if FileExists(ExpandConstant('{app}')+'\wetstk.exe') then begin
    DeleteFile(ExpandConstant('{app}')+'\wetstk.exe');
    DeleteFile(DESKTOPDIR+'\Wetstock Maintenance.Ink');
  End;

  //Create short cut
  if pos('A',SDK) <> 0 then begin
    SDK_OPTIONS := 'ABC'
    if pos('B',COMPONENTS) <> 0 then begin
      if pos('B',ICONS) <> 0 then begin
        if OS = 32 then begin
          //Create Shortcut from %MAINDIR%\ExpressUpdate.exe to %GROUP%\Tools\Firmware Update for Express.lnk
        end
        else
          //Create Shortcut from %MAINDIR%\ExpressUpdatex64.exe to %GROUP%\Tools\Firmware Update for Express-x64.lnk
        end;
        //Create Shortcut from %MAINDIR%\PCIUpdate.exe to %GROUP%\Tools\Firmware Update for PCI.lnk
      End;

      if pos('A',ICONS) <> 0 then begin
        if OS = 32 then begin
          //Create Shortcut from %MAINDIR%\ExpressUpdate.exe to %DESKTOPDIR%\Firmware Update for Express.lnk
        end
        else
          //Create Shortcut from %MAINDIR%\ExpressUpdatex64.exe to %DESKTOPDIR%\Tools\Firmware Update for Express-x64.lnk
        end;
        //Create Shortcut from %MAINDIR%\PCIUpdate.exe to %DESKTOPDIR%\Firmware Update for PCI.lnk
      End;
    End;
  End.

  //Install the SDK applications (based on client/server install)
  //Install MPPSIM and Driver DLL
  if pos('A',SDK_OPTIONS) then begin
    DeleteFile(GROUP+'\MPPSim.lnk');
    DeleteFile(GROUP+'\Pump Simulator.lnk');
    //TODO Create shortcut
  end
  else begin
    if FileExists(ExpandConstant('{app}')+'\ITLMPPSim.dll') then begin
      Exec('rsgsvr32.exe', '/u /s '+ExpandConstant('{app}')+'\ITLMPPSim.dll', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
      DeleteFile(ExpandConstant('{app}')+'ITLMPPSim.dll');
    end;
    if FileExists(ExpandConstant('{app}')+'\bin\ITLMPPSim.dll') then begin
      Exec('rsgsvr32.exe', '/u /s '+ExpandConstant('{app}')+'\bin\ITLMPPSim.dll', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
      DeleteFile(ExpandConstant('{app}')+'\bin\ITLMPPSim.dll');
    end;
    if FilsExists(ExpandConstant('{app}')+'\MPPSim.exe') then begin
      DeleteFile(ExpandConstant('{app}')+'\MPPSim.exe');
      DeleteFile(GROUP+'\MPPSim.lnk');
      DeleteFile(GROUP+'\Pump Simulator.lnk');
      DeleteFile(DESKTOPDIR+'\MPPSim.lnk');
      DeleteFile(DESKTOPDIR+'\Pump Simulator.lnk');
    end;
  end;

  if pos('B',SDK_OPTIONS) <> 0 then begin
    DeleteFile(GROUP+'Pump Demp.lnk');

    //TODO Create shortcut

  end
  else
    if FileExists(ExpandConstant('{app}')+'\pumpdemo.exe') then begin
      DeleteFile(ExpandConstant('{app}')+'\pumpdemo.exe');
      DeleteFile(GROUP+'\Pump Demo.lnk');
      DeleteFile(DESKTOPDIR+'\Pump Demo.lnk');
    end;
    if FileExists(ExpandConstant('{app}')+'\PumpDemoWPF.exe')then begin
      DeleteFile(ExpandConstant('{app}')+'\PumpDemoWPF.exe');
      DeleteFile(GROUP+'\Pump Demo WPF.lnk');
      DeleteFile(DESKTOPDIR+'\Pump Demo WPF.lnk');
    end;
    if FileExists(ExpandConstant('{app}')+'\SampleCom.exe')then begin
      DeleteFile(ExpandConstant('{app}')+'\SampleCom.exe');
      DeleteFile(GROUP+'\Sample COM.lnk');
      DeleteFile(DESKTOPDIR+'\Sample COM.lnk');      
    end;
    if FileExists(ExpandConstant('{app}')+'\pumpdemo.jar')then begin
      DeleteFile(ExpandConstant('{app}')+'\pumpdemo.jar');
      DeleteFile(GROUP+'\Pump Demo (Java).lnk');
      DeleteFile(DESKTOPDIR+'\Pump Demo (Java).lnk');  
    end;
  end;
  
  //Remove vbComOleAPI sample if it exists - this has been renamed to SampleCOM
  if FileExists(ExpandConstant('{app}')+'\vbcomapitest.exe')then begin
    DeleteFile(ExpandConstant('{app}')+'\vbcomapitest.exe');
    DeleteFile(GROUP+'\Pump COM/OLE API Test.lnk');
    DeleteFile(DESKTOPDIR+'\Pump COM/OLE API Test.lnk'); 
  end;

  DeleteFile(ExpandConstant('{app}')+'\pumpdemo2.exe')

End;
    
    
    
    
    
     


