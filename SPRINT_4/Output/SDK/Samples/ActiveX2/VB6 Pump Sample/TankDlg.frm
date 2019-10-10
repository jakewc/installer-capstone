VERSION 5.00
Begin VB.Form TankDlg 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Tanks"
   ClientHeight    =   5895
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   10395
   Icon            =   "TankDlg.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5895
   ScaleWidth      =   10395
   StartUpPosition =   1  'CenterOwner
   Begin VB.PictureBox TankLevelPicture 
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'None
      FillStyle       =   0  'Solid
      Height          =   5295
      Left            =   5640
      ScaleHeight     =   5295
      ScaleWidth      =   4575
      TabIndex        =   21
      Top             =   360
      Width           =   4575
   End
   Begin VB.ListBox AlarmList 
      Height          =   1425
      Left            =   360
      TabIndex        =   11
      Top             =   4320
      Width           =   4815
   End
   Begin VB.Timer RefreshTimer 
      Enabled         =   0   'False
      Interval        =   2500
      Left            =   4920
      Top             =   120
   End
   Begin VB.Frame TankDetailsFrame 
      Caption         =   "Tank Details"
      Height          =   3135
      Left            =   120
      TabIndex        =   2
      Top             =   600
      Width           =   5295
      Begin VB.Label GaugeUllage 
         Alignment       =   1  'Right Justify
         Caption         =   "(GaugeUllage)"
         Height          =   255
         Left            =   1800
         TabIndex        =   23
         Top             =   1080
         Width           =   2415
      End
      Begin VB.Label UllageLabel 
         Alignment       =   1  'Right Justify
         Caption         =   "Gauge Ullage"
         Height          =   255
         Left            =   240
         TabIndex        =   22
         ToolTipText     =   "Temperature Compensated Volume"
         Top             =   1080
         Width           =   1455
      End
      Begin VB.Label Diameter 
         Caption         =   "(Diameter)"
         Height          =   255
         Left            =   1800
         TabIndex        =   20
         Top             =   2400
         Width           =   2415
      End
      Begin VB.Label TankDiameterLabel 
         Alignment       =   1  'Right Justify
         Caption         =   "Diameter"
         Height          =   255
         Left            =   240
         TabIndex        =   19
         Top             =   2400
         Width           =   1455
      End
      Begin VB.Label Temperature 
         Caption         =   "(Temperature)"
         Height          =   255
         Left            =   1800
         TabIndex        =   18
         Top             =   2040
         Width           =   2415
      End
      Begin VB.Label TemperatureLabel 
         Alignment       =   1  'Right Justify
         Caption         =   "Temperature"
         Height          =   255
         Left            =   240
         TabIndex        =   17
         Top             =   2040
         Width           =   1455
      End
      Begin VB.Label WaterLevel 
         Caption         =   "(WaterLevel)"
         Height          =   255
         Left            =   1800
         TabIndex        =   16
         Top             =   1680
         Width           =   2415
      End
      Begin VB.Label WaterLevelLabel 
         Alignment       =   1  'Right Justify
         Caption         =   "Water Level"
         Height          =   255
         Left            =   240
         TabIndex        =   15
         Top             =   1680
         Width           =   1455
      End
      Begin VB.Label WaterVolumeLabel 
         Alignment       =   1  'Right Justify
         Caption         =   "Water Volume"
         Height          =   255
         Left            =   240
         TabIndex        =   14
         ToolTipText     =   "Temperature Compensated Volume"
         Top             =   1440
         Width           =   1455
      End
      Begin VB.Label WaterVolume 
         Alignment       =   1  'Right Justify
         Caption         =   "(WaterVolume)"
         Height          =   255
         Left            =   1800
         TabIndex        =   13
         Top             =   1440
         Width           =   2415
      End
      Begin VB.Label GaugeTCVolume 
         Alignment       =   1  'Right Justify
         Caption         =   "(GaugeTCVolume)"
         Height          =   255
         Left            =   1800
         TabIndex        =   10
         Top             =   840
         Width           =   2415
      End
      Begin VB.Label GaugeTCVolumeLabel 
         Alignment       =   1  'Right Justify
         Caption         =   "Gauge TC Volume"
         Height          =   255
         Left            =   240
         TabIndex        =   9
         ToolTipText     =   "Temperature Compensated Volume"
         Top             =   840
         Width           =   1455
      End
      Begin VB.Label TheoreticalVolume 
         Alignment       =   1  'Right Justify
         Caption         =   "(TheoreticalVolume)"
         Height          =   255
         Left            =   1800
         TabIndex        =   8
         Top             =   2760
         Width           =   2415
      End
      Begin VB.Label TheoreticalVolumeLabel 
         Alignment       =   1  'Right Justify
         Caption         =   "Theoretical Volume"
         Height          =   255
         Left            =   240
         TabIndex        =   7
         Top             =   2760
         Width           =   1455
      End
      Begin VB.Label GaugeVolume 
         Alignment       =   1  'Right Justify
         Caption         =   "(GaugeVolume)"
         Height          =   255
         Left            =   1800
         TabIndex        =   6
         Top             =   600
         Width           =   2415
      End
      Begin VB.Label GaugeVolumeLabel 
         Alignment       =   1  'Right Justify
         Caption         =   "Gauge Volume"
         Height          =   255
         Left            =   240
         TabIndex        =   5
         Top             =   600
         Width           =   1455
      End
      Begin VB.Label GaugeLevel 
         Caption         =   "(GaugeLevel)"
         Height          =   255
         Left            =   1800
         TabIndex        =   4
         Top             =   360
         Width           =   2415
      End
      Begin VB.Label GaugeLevelLabel 
         Alignment       =   1  'Right Justify
         Caption         =   "Gauge Level"
         Height          =   255
         Left            =   360
         TabIndex        =   3
         Top             =   360
         Width           =   1335
      End
   End
   Begin VB.ComboBox TankCombo 
      Height          =   315
      Left            =   1440
      Style           =   2  'Dropdown List
      TabIndex        =   0
      Top             =   120
      Width           =   3255
   End
   Begin VB.Label ActiveAlarmLabel 
      Caption         =   "Current (Active) Alarms"
      Height          =   255
      Left            =   240
      TabIndex        =   12
      Top             =   3960
      Width           =   2535
   End
   Begin VB.Label TankSelectLabel 
      Caption         =   "Select tank"
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   150
      Width           =   1215
   End
End
Attribute VB_Name = "TankDlg"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'*****************************************************************
'*
'* Copyright (C) 1997-2003 Integration Technologies Limited
'* All rights reserved.
'*
'* This dialog shows how to access the Tank Objects to retrieve
'* current tank status and alarms
'*
'******************************************************************
Option Explicit

Private Sub Form_Load()

Dim i As Integer
Dim NumTanks As Integer
Dim ThisTank As Tank
    
    ' get the number of tanks from the session control
    NumTanks = MainForm.Session.NumberOfTanks
    
    TankCombo.Clear
    
    ' load the tank names into the combo
    For i = 1 To NumTanks
    
        ' get the tank object from the session control
        Set ThisTank = MainForm.Session.Tank(i)
        
        ' add this tank's name to the combo box
        TankCombo.AddItem (ThisTank.name)
    
        Set ThisTank = Nothing
    Next

    ' set the combo to the first item in the list
    TankCombo.ListIndex = 0
    
    DisplayTankDetails
    
    ' Start the refresh timer
    RefreshTimer.Enabled = True
        
End Sub

' draw the tank graphic based on latest gauge data
' (only called if the pump server is online)
Sub UpdateTankGraphic(aTank As Tank)

Dim pbWidth As Long
Dim pbHeight As Long
Dim graphicD, graphicR As Long
Dim Bottom, Top, vCentre, hCentre As Long
Dim TopOfWater As Long
Dim WaterTop As Long
Dim ProductTop As Long
Dim Y As Long
Dim t As Long
Dim chordLength As Long
Dim chordL, chordR As Long
Dim paintColor As Long
Dim aGrade As grade
Dim DrawLevels As Boolean
Dim InfoMessage1 As String
Dim InfoMessage2 As String

    pbWidth = TankLevelPicture.Width - 100
    pbHeight = TankLevelPicture.Height - 20
    
    graphicD = pbWidth
    graphicR = graphicD / 2
    
    vCentre = TankLevelPicture.Height / 2
    Top = vCentre - graphicR
    Bottom = vCentre + graphicR
    hCentre = TankLevelPicture.Width / 2
    
    TopOfWater = aTank.WaterLevel * 1000 ' convert to mm
    
    ' check data and decide whether to draw levels or display info message
    DrawLevels = False
    If aTank.Diameter <= 0 Then
        ' invalid config
        ' cannot draw the tank levels if we don't know the diameter of the tank
        InfoMessage1 = "Check Enabler Configuration"
        InfoMessage2 = "(Diameter = 0)"
    ElseIf aTank.GaugeLevel > aTank.Diameter Then
        ' invalid config
        ' Gauge level is greater than tank diameter
        InfoMessage1 = "Check Enabler Configuration"
        InfoMessage2 = "(GaugeLevel > Diameter)"
    ElseIf aTank.GaugeLevel < 0 Then
        ' invalid config
        ' Gauge level is greater than tank diameter
        InfoMessage1 = "Check ATG Configuration"
        InfoMessage2 = "(GaugeLevel < 0)"
    ElseIf aTank.GaugeVolume = 0 Then
        ' looks like the tank isn't gauged
        InfoMessage1 = "No Tank Gauge Data"
        InfoMessage2 = "available for this tank"
    Else
        DrawLevels = True
    End If

    With TankLevelPicture
        .Cls
        Set aGrade = aTank.grade
        .FontSize = 14
        TankLevelPicture.Print "Tank #" + CStr(aTank.Number) + " (" + aGrade.name + ")"
        If DrawLevels Then
            .FontSize = 10
            .ForeColor = RGB(255, 0, 0)
            TankLevelPicture.Print "95% Full"
            .ForeColor = RGB(255, 127, 39)
            TankLevelPicture.Print "90% Full"
        End If
        
        .DrawStyle = vbSolid
        .ForeColor = vbBlack
        .FillColor = vbWhite
        .FillStyle = vbSolid
                
        ' Draw the tank background (white)
        .FillStyle = vbSolid
        .DrawWidth = 3
        TankLevelPicture.Circle (hCentre, vCentre), graphicR - 25, vbWhite
        .DrawWidth = 1
        
        If DrawLevels Then
            ' Draw the product
            If aTank.GaugeLevel > 0 And aTank.Diameter > 0 Then
                ProductTop = Bottom - ((aTank.GaugeLevel / aTank.Diameter) * graphicD)
                For Y = ProductTop To Bottom
                    t = vCentre - Y
                    chordLength = ((graphicR * graphicR) - (t * t)) ^ (1 / 2)
                    chordL = (hCentre) - chordLength
                    chordR = (hCentre) + chordLength
                    paintColor = RGB(50, 190 * ((Bottom - Y) / Abs(Bottom - ProductTop)) + 65, 50)
                    TankLevelPicture.Line (chordL, Y)-(chordR, Y), paintColor
                Next Y
            End If
            
            ' Draw the water
            If aTank.WaterLevel > 0 And aTank.WaterLevel < aTank.GaugeLevel Then
                WaterTop = Bottom - ((aTank.WaterLevel / aTank.Diameter) * graphicD)
                For Y = WaterTop To Bottom
                    t = vCentre - Y
                    chordLength = ((graphicR * graphicR) - (t * t)) ^ (1 / 2)
                    chordL = (hCentre) - chordLength
                    chordR = (hCentre) + chordLength
                    paintColor = RGB(70, 70, 100 * ((Bottom - Y) / Abs(Bottom - WaterTop)) + 155)
                    TankLevelPicture.Line (chordL, Y)-(chordR, Y), paintColor
                Next Y
            End If
        End If
        
        ' Draw the tank outline (dark grey)
        TankLevelPicture.FillStyle = 1 ' transparent - no fill
        .DrawWidth = 4
        TankLevelPicture.Circle (hCentre, vCentre), graphicR + 20, RGB(70, 70, 70)
        
        If (DrawLevels) Then
            ' Draw 90% and 90% ullage lines
            ' NOTE these are not linked to alarm levels setup in the ATG
            .DrawWidth = 2
            
            Y = Top + (0.156 * graphicD) ' ~90% capacity
            t = vCentre - Y
            chordLength = ((graphicR * graphicR) - (t * t)) ^ (1 / 2)
            chordL = (hCentre) - chordLength
            chordR = (hCentre) + chordLength
            TankLevelPicture.Line (chordL, Y)-(chordR, Y), RGB(255, 127, 39)
            
            Y = Top + (0.097 * graphicD) ' ~95% capacity
            t = vCentre - Y
            chordLength = ((graphicR * graphicR) - (t * t)) ^ (1 / 2)
            chordL = (hCentre) - chordLength
            chordR = (hCentre) + chordLength
            TankLevelPicture.Line (chordL, Y)-(chordR, Y), RGB(255, 0, 0)
        Else
            ' tank levels not drawn, display info messages instead
            .FontSize = 12
            .ForeColor = RGB(0, 0, 0)
            .CurrentX = hCentre - TankLevelPicture.TextWidth(InfoMessage1) / 2
            .CurrentY = vCentre - TankLevelPicture.TextHeight(InfoMessage1)
            TankLevelPicture.Print (InfoMessage1)
            .CurrentX = hCentre - TankLevelPicture.TextWidth(InfoMessage2) / 2
            .CurrentY = vCentre
            TankLevelPicture.Print (InfoMessage2)
        End If
                
    End With
            
End Sub

Sub DisplayTankDetails()

Dim ThisTank As Tank
Dim i As Integer
Dim AlarmVal As Integer
Dim PumpServerOnline As Boolean

    On Error GoTo Failed

    ' check if pump server is online
    PumpServerOnline = (MainForm.Session.NumberOfTanks > 0)
    
    TankCombo.Enabled = PumpServerOnline
    AlarmList.Enabled = PumpServerOnline
    
    GaugeLevel.Enabled = PumpServerOnline
    GaugeVolume.Enabled = PumpServerOnline
    GaugeTCVolume.Enabled = PumpServerOnline
    WaterVolume.Enabled = PumpServerOnline
    TheoreticalVolume.Enabled = PumpServerOnline
    WaterLevel.Enabled = PumpServerOnline
    Temperature.Enabled = PumpServerOnline
    Diameter.Enabled = PumpServerOnline
    GaugeUllage.Enabled = PumpServerOnline
    
    If Not PumpServerOnline Then
        AlarmList.Clear
        AlarmList.AddItem "(Unknown)"
        Exit Sub
    End If
    
    ' get the tank object from the session control
    Set ThisTank = MainForm.Session.Tank(TankCombo.ListIndex + 1)
    UpdateTankGraphic ThisTank
    
    ' display some fields from the selected tank
    If ThisTank.GaugeLevel > 0 Then
        GaugeLevel.Caption = Format(ThisTank.GaugeLevel, "0.0000") ' metres or inches
    Else
        GaugeLevel.Caption = "-"
    End If
    
    If ThisTank.GaugeVolume > 0 Then
        GaugeVolume.Caption = Format(ThisTank.GaugeVolume, "0.00")
    Else
        GaugeVolume.Caption = "-"
    End If
    
    If ThisTank.ullage > 0 Then
        GaugeUllage.Caption = Format(ThisTank.ullage, "0.00")
    Else
        GaugeUllage.Caption = "-"
    End If
    
    If ThisTank.GaugeLevel > 0 Then
        Temperature.Caption = Format(ThisTank.Temperature, "0.00") ' C or F
    Else
        Temperature.Caption = "-"
    End If
    Diameter.Caption = Format(ThisTank.Diameter, "0.0000")
    
    If ThisTank.ullage < 0 Then
        GaugeUllage.ForeColor = vbRed
    Else
        GaugeUllage.ForeColor = vbDefault
    End If
    
    If ThisTank.GaugeTCVolume > 0 Then
        GaugeTCVolume.Caption = Format(ThisTank.GaugeTCVolume, "0.00")
    Else
        GaugeTCVolume.Caption = "-"
    End If
    
    If ThisTank.WaterLevel > 0 Then
        WaterLevel.Caption = Format(ThisTank.WaterLevel, "0.0000")
    Else
        WaterLevel.Caption = "-"
    End If
        
    If ThisTank.WaterVolume > 0 Then
        WaterVolume.Caption = Format(ThisTank.WaterVolume, "0.00")
    Else
        WaterVolume.Caption = "-"
    End If
    
    TheoreticalVolume.Caption = Format(ThisTank.TheoreticalVolume, "0.000")
    
    ' display active alarms
    AlarmList.Clear
    For i = 1 To 30
        AlarmVal = ThisTank.Alarm(i)
        If AlarmVal <> 0 Then
            Select Case i
                Case 1
                    AlarmList.AddItem " 1 = Setup data warning"
                Case 2
                    AlarmList.AddItem " 2 = Leak alarm"
                Case 3
                    AlarmList.AddItem " 3 = High water alarm"
                Case 4
                    AlarmList.AddItem " 4 = Overfill alarm"
                Case 5
                    AlarmList.AddItem " 5 = Low Limit alarm"
                Case 6
                    AlarmList.AddItem " 6 = Unexpected loss (theft) alarm"
                Case 7
                    AlarmList.AddItem " 7 = High limit alarm"
                Case 8
                    AlarmList.AddItem " 8 = Invalid height alarm"
                Case 9
                    AlarmList.AddItem " 9 = Probe out (disconnected) alarm"
                Case 10
                    AlarmList.AddItem "10 = High water warning"
                Case 11
                    AlarmList.AddItem "11 = Delivery required warning"
                Case 12
                    AlarmList.AddItem "12 = Maximum level alarm"
                Case 13
                    AlarmList.AddItem "13 = Leak detected during leak test"
                Case 14
                    AlarmList.AddItem "14 = Periodic leak test failed"
                Case 15
                    AlarmList.AddItem "15 = Annual leak test failed"
                Case 16
                    AlarmList.AddItem "16 = Periodic leak test due soon"
                Case 17
                    AlarmList.AddItem "17 = Annual leak test due soon"
                Case 18
                    AlarmList.AddItem "18 = Periodic leak test overdue"
                Case 19
                    AlarmList.AddItem "19 = Annual leak test overdue"
                Case 20
                    AlarmList.AddItem "20 = Leak test in progress"
                Case 21
                    AlarmList.AddItem "21 = No CSLD rate increase warning"
                Case 22
                    AlarmList.AddItem "22 = Siphon break active"
                Case 23
                    AlarmList.AddItem "23 = CSLD rate increase warning"
                Case 24
                    AlarmList.AddItem "24 = AccuChart calibration warning"
                Case 25
                    AlarmList.AddItem "25 = HRM reconciliation warning"
                Case 26
                    AlarmList.AddItem "26 = HRM reconciliation alarm"
                Case 27
                    AlarmList.AddItem "27 = Cold temperature warning"
                Case 28
                    AlarmList.AddItem "28 = Missing delivery ticket warning"
                Case 29
                    AlarmList.AddItem "29 = Tank/Line gross leak alarm"
                Case 30
                    AlarmList.AddItem "30 = Delivery density warning"
                    
                Case Else
                    AlarmList.AddItem CStr(i + 1) + " = (undefined alarm)"
            End Select
        End If
    Next
    If AlarmList.ListCount = 0 Then
        AlarmList.AddItem "(None)"
    End If
    
    Exit Sub
    
    Set ThisTank = Nothing
    
Failed:
    MsgBox "Could not retrieve data for tank " & TankCombo.ListIndex + 1

End Sub

Private Sub Form_Unload(Cancel As Integer)
    ' Halt the refresh timer
    RefreshTimer.Enabled = False
End Sub

Private Sub RefreshTimer_Timer()
    DisplayTankDetails
End Sub

Private Sub TankCombo_Click()
    DisplayTankDetails
End Sub

