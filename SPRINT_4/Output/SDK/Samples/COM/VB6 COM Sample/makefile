#
# Makefile for SampleCom
#
# used by the Build PC to build if there are changes insead of compiling it every time
#
VB6EXE = VB6.exe

TARGETS = SampleCom.exe

# dependency list
SRC = DialogAttendants.frm \
 DialogFallback.frm \
 DialogGlabalSettings.frm \
 DialogGrades.frm \
 DialogHoses.frm \
 DialogProfiles.frm \
 DialogPumpProfile.frm \
 DialogPumps.frm \
 DialogServerInformation.frm \
 DialogTanks.frm \
 DialogTerminals.frm \
 DialogTransaction.frm \
 Form1.frm \
 makefile \
 PumpControl.ctl \
 SampleCom.vbp


SampleCom.exe: $(SRC)
	@echo Make SampleCom.EXE
	$(VB6EXE) /make SampleCom.vbp /OUT build.log
	
clean:
	@if exist SampleCom.exe echo Removing SampleCom.EXE
	@if exist SampleCom.exe del SampleCom.exe
	@if exist build.log echo Removing BUILD.LOG
	@if exist build.log del build.log
