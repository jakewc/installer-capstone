#
# Makefile for PUMPDEMO
#
# used by the Build PC to build if there are changes insead of compiling it every time
#
VB6EXE = VB6.exe

TARGETS = pumpdemo.exe

# dependency list
SRC = AttAuthDlg.frm \
 AttAuthDlg.frx \
 AttendantDlg.frm \
 AttendantDlg.frx \
 CaptionDlg.frm \
 CommandLine.bas \
 .\VBLib\DBUtility.bas \
 .\VBLib\EnablerDef.bas \
 ForecourtDlg.frm \
 frmAbout.frm \
 frmAbout.frx \
 makefile \
 ManualDelivery.frm \
 ManualDelivery.frx \
 PeriodsForm.frm \
 PreauthDlg.frm \
 PreauthDlg.frx \
 PrepayDlg.frm \
 PrepayDlg.frx \
 PresetDlg.frm \
 PresetDlg.frx \
 pumpdemo.frm \
 pumpdemo.frx \
 Pumpdemo.ico \
 pumpdemo.vbp \
 pumpdemo.vbw \
 .\VBLib\REGISTRY.BAS \
 ReinstateDlg.frm \
 ReinstateDlg.frx \
 resource.h \
 sale.bas \
 TankDlg.frm \
 TankDlg.frx \
 TraceForm.frm \
 TraceForm.frx \
 TracePumpForm.frm \
 TracePumpForm.frx \
 Utility.bas \
 .\VBLib\WinAPI.bas


pumpdemo.exe: $(SRC)
	@echo Make PUMPDEMO.EXE
	$(VB6EXE) /make pumpdemo.vbp /OUT build.log
	copy VBLib\pumpdemo.exe .
	
clean:
	@if exist pumpdemo.exe echo Removing PUMPDEMO.EXE
	@if exist pumpdemo.exe del pumpdemo.exe
	@if exist build.log echo Removing BUILD.LOG
	@if exist build.log del build.log
