VERSION 5.00
Begin VB.Form DialogTanks 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Tanks"
   ClientHeight    =   11505
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   9780
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   11505
   ScaleWidth      =   9780
   ShowInTaskbar   =   0   'False
   Begin VB.Frame Frame1 
      Caption         =   "Tank detail"
      Height          =   10575
      Left            =   240
      TabIndex        =   3
      Top             =   720
      Width           =   9135
      Begin VB.TextBox Text_StrappedTank 
         Enabled         =   0   'False
         Height          =   350
         Left            =   2040
         TabIndex        =   82
         Top             =   6720
         Width           =   1815
      End
      Begin VB.CommandButton Command_toggleAuto 
         Caption         =   "Toggle Auto"
         Height          =   255
         Left            =   2280
         TabIndex        =   80
         Top             =   2880
         Width           =   1575
      End
      Begin VB.ListBox List_events 
         Height          =   1230
         Left            =   240
         TabIndex        =   78
         Top             =   9240
         Width           =   8535
      End
      Begin VB.CheckBox Check_tank_delivery 
         Caption         =   "Tanker Delivery"
         Enabled         =   0   'False
         Height          =   255
         Left            =   2040
         TabIndex        =   77
         Top             =   4080
         Width           =   2295
      End
      Begin VB.CheckBox Check_tank_low_level 
         Caption         =   "Low Level"
         Enabled         =   0   'False
         Height          =   255
         Left            =   2040
         TabIndex        =   76
         Top             =   3840
         Width           =   1695
      End
      Begin VB.CheckBox Check_tank_user 
         Caption         =   "User"
         Enabled         =   0   'False
         Height          =   255
         Left            =   2040
         TabIndex        =   75
         Top             =   3600
         Width           =   1335
      End
      Begin VB.CommandButton Command_tvolSet 
         Caption         =   "Set"
         Height          =   375
         Left            =   3360
         TabIndex        =   73
         Top             =   6240
         Width           =   495
      End
      Begin VB.CommandButton Command_toggleBlock 
         Caption         =   "Toggle Block"
         Height          =   255
         Left            =   2280
         TabIndex        =   52
         Top             =   3270
         Width           =   1575
      End
      Begin VB.Frame Frame2 
         Caption         =   "Alarms"
         Height          =   1695
         Left            =   240
         TabIndex        =   51
         Top             =   7200
         Width           =   8535
         Begin VB.CheckBox Check_Alarm 
            Caption         =   "Alarm 0"
            Enabled         =   0   'False
            Height          =   255
            Index           =   0
            Left            =   360
            TabIndex        =   79
            Top             =   240
            Width           =   1300
         End
         Begin VB.CheckBox Check_Alarm 
            Caption         =   "Alarm 19"
            Enabled         =   0   'False
            Height          =   255
            Index           =   19
            Left            =   6600
            TabIndex        =   71
            Top             =   1200
            Width           =   1300
         End
         Begin VB.CheckBox Check_Alarm 
            Caption         =   "Alarm 18"
            Enabled         =   0   'False
            Height          =   255
            Index           =   18
            Left            =   6600
            TabIndex        =   70
            Top             =   960
            Width           =   1300
         End
         Begin VB.CheckBox Check_Alarm 
            Caption         =   "Alarm 17"
            Enabled         =   0   'False
            Height          =   255
            Index           =   17
            Left            =   6600
            TabIndex        =   69
            Top             =   720
            Width           =   1300
         End
         Begin VB.CheckBox Check_Alarm 
            Caption         =   "Alarm 16"
            Enabled         =   0   'False
            Height          =   255
            Index           =   16
            Left            =   6600
            TabIndex        =   68
            Top             =   480
            Width           =   1300
         End
         Begin VB.CheckBox Check_Alarm 
            Caption         =   "Alarm 15"
            Enabled         =   0   'False
            Height          =   255
            Index           =   15
            Left            =   6600
            TabIndex        =   67
            Top             =   240
            Width           =   1300
         End
         Begin VB.CheckBox Check_Alarm 
            Caption         =   "Alarm 14"
            Enabled         =   0   'False
            Height          =   255
            Index           =   14
            Left            =   4440
            TabIndex        =   66
            Top             =   1200
            Width           =   1300
         End
         Begin VB.CheckBox Check_Alarm 
            Caption         =   "Alarm 13"
            Enabled         =   0   'False
            Height          =   255
            Index           =   13
            Left            =   4440
            TabIndex        =   65
            Top             =   960
            Width           =   1300
         End
         Begin VB.CheckBox Check_Alarm 
            Caption         =   "Alarm 12"
            Enabled         =   0   'False
            Height          =   255
            Index           =   12
            Left            =   4440
            TabIndex        =   64
            Top             =   720
            Width           =   1300
         End
         Begin VB.CheckBox Check_Alarm 
            Caption         =   "Alarm 11"
            Enabled         =   0   'False
            Height          =   255
            Index           =   11
            Left            =   4440
            TabIndex        =   63
            Top             =   480
            Width           =   1300
         End
         Begin VB.CheckBox Check_Alarm 
            Caption         =   "Alarm 10"
            Enabled         =   0   'False
            Height          =   255
            Index           =   10
            Left            =   4440
            TabIndex        =   62
            Top             =   240
            Width           =   1300
         End
         Begin VB.CheckBox Check_Alarm 
            Caption         =   "Alarm 9"
            Enabled         =   0   'False
            Height          =   255
            Index           =   9
            Left            =   2400
            TabIndex        =   61
            Top             =   1200
            Width           =   1300
         End
         Begin VB.CheckBox Check_Alarm 
            Caption         =   "Alarm 8"
            Enabled         =   0   'False
            Height          =   255
            Index           =   8
            Left            =   2400
            TabIndex        =   60
            Top             =   960
            Width           =   1300
         End
         Begin VB.CheckBox Check_Alarm 
            Caption         =   "Alarm 7"
            Enabled         =   0   'False
            Height          =   255
            Index           =   7
            Left            =   2400
            TabIndex        =   59
            Top             =   720
            Width           =   1300
         End
         Begin VB.CheckBox Check_Alarm 
            Caption         =   "Alarm 6"
            Enabled         =   0   'False
            Height          =   255
            Index           =   6
            Left            =   2400
            TabIndex        =   58
            Top             =   480
            Width           =   1300
         End
         Begin VB.CheckBox Check_Alarm 
            Caption         =   "Alarm 5"
            Enabled         =   0   'False
            Height          =   255
            Index           =   5
            Left            =   2400
            TabIndex        =   57
            Top             =   240
            Width           =   1300
         End
         Begin VB.CheckBox Check_Alarm 
            Caption         =   "Alarm 4"
            Enabled         =   0   'False
            Height          =   255
            Index           =   4
            Left            =   360
            TabIndex        =   56
            Top             =   1200
            Width           =   1300
         End
         Begin VB.CheckBox Check_Alarm 
            Caption         =   "Alarm 3"
            Enabled         =   0   'False
            Height          =   255
            Index           =   3
            Left            =   360
            TabIndex        =   55
            Top             =   960
            Width           =   1300
         End
         Begin VB.CheckBox Check_Alarm 
            Caption         =   "Alarm 2"
            Enabled         =   0   'False
            Height          =   255
            Index           =   2
            Left            =   360
            TabIndex        =   54
            Top             =   720
            Width           =   1300
         End
         Begin VB.CheckBox Check_Alarm 
            Caption         =   "Alarm 1"
            Enabled         =   0   'False
            Height          =   255
            Index           =   1
            Left            =   360
            TabIndex        =   53
            Top             =   480
            Width           =   1300
         End
      End
      Begin VB.Frame Frame_gauge 
         Caption         =   "Gauge Reading"
         Height          =   5775
         Left            =   4440
         TabIndex        =   28
         Top             =   360
         Width           =   4335
         Begin VB.TextBox Text_ProbeNumber 
            Enabled         =   0   'False
            Height          =   375
            Left            =   2160
            TabIndex        =   49
            Top             =   5160
            Width           =   1815
         End
         Begin VB.TextBox Text_ProbeStatus 
            Enabled         =   0   'False
            Height          =   375
            Left            =   2160
            TabIndex        =   47
            Top             =   4680
            Width           =   1815
         End
         Begin VB.TextBox Text_Density 
            Enabled         =   0   'False
            Height          =   375
            Left            =   2160
            TabIndex        =   45
            Top             =   4200
            Width           =   1815
         End
         Begin VB.TextBox Text_WaterVolume 
            Enabled         =   0   'False
            Height          =   375
            Left            =   2160
            TabIndex        =   43
            Top             =   3720
            Width           =   1815
         End
         Begin VB.TextBox Text_WaterLevel 
            Enabled         =   0   'False
            Height          =   375
            Left            =   2160
            TabIndex        =   41
            Top             =   3240
            Width           =   1815
         End
         Begin VB.TextBox Text_Ullage 
            Enabled         =   0   'False
            Height          =   375
            Left            =   2160
            TabIndex        =   39
            Top             =   2760
            Width           =   1815
         End
         Begin VB.TextBox Text_Temperature 
            Enabled         =   0   'False
            Height          =   375
            Left            =   2160
            TabIndex        =   37
            Top             =   2280
            Width           =   1815
         End
         Begin VB.TextBox Text_LastReading 
            Enabled         =   0   'False
            Height          =   375
            Left            =   2160
            TabIndex        =   32
            Top             =   360
            Width           =   1815
         End
         Begin VB.TextBox Text_level 
            Enabled         =   0   'False
            Height          =   375
            Left            =   2160
            TabIndex        =   31
            Top             =   840
            Width           =   1815
         End
         Begin VB.TextBox Text_volume 
            Enabled         =   0   'False
            Height          =   375
            Left            =   2160
            TabIndex        =   30
            Top             =   1320
            Width           =   1815
         End
         Begin VB.TextBox Text_nonCOmpensatedVolume 
            Enabled         =   0   'False
            Height          =   375
            Left            =   2160
            TabIndex        =   29
            Top             =   1800
            Width           =   1815
         End
         Begin VB.Label Label24 
            Caption         =   "Probe number :"
            Height          =   255
            Left            =   120
            TabIndex        =   50
            Top             =   5160
            Width           =   1215
         End
         Begin VB.Label Label23 
            Caption         =   "Probe Status :"
            Height          =   255
            Left            =   120
            TabIndex        =   48
            Top             =   4680
            Width           =   1215
         End
         Begin VB.Label Label22 
            Caption         =   "Density :"
            Height          =   255
            Left            =   120
            TabIndex        =   46
            Top             =   4200
            Width           =   1215
         End
         Begin VB.Label Label21 
            Caption         =   "Water Volume :"
            Height          =   255
            Left            =   120
            TabIndex        =   44
            Top             =   3720
            Width           =   1215
         End
         Begin VB.Label Label20 
            Caption         =   "WaterLevel :"
            Height          =   255
            Left            =   120
            TabIndex        =   42
            Top             =   3240
            Width           =   1215
         End
         Begin VB.Label Label19 
            Caption         =   "Ullage :"
            Height          =   255
            Left            =   120
            TabIndex        =   40
            Top             =   2760
            Width           =   1215
         End
         Begin VB.Label Label18 
            Caption         =   "Temperature :"
            Height          =   255
            Left            =   120
            TabIndex        =   38
            Top             =   2280
            Width           =   1215
         End
         Begin VB.Label Label17 
            Caption         =   "Date last reading :"
            Height          =   255
            Left            =   120
            TabIndex        =   36
            Top             =   360
            Width           =   1575
         End
         Begin VB.Label Label16 
            Caption         =   "Level :"
            Height          =   255
            Left            =   120
            TabIndex        =   35
            Top             =   840
            Width           =   1215
         End
         Begin VB.Label Label15 
            Caption         =   "Volume :"
            Height          =   255
            Left            =   120
            TabIndex        =   34
            Top             =   1320
            Width           =   1215
         End
         Begin VB.Label Label14 
            Caption         =   "Non Compensated Volume :"
            Height          =   255
            Left            =   120
            TabIndex        =   33
            Top             =   1800
            Width           =   2175
         End
      End
      Begin VB.TextBox Text_theovolume 
         Height          =   350
         Left            =   2040
         TabIndex        =   27
         Top             =   6240
         Width           =   1215
      End
      Begin VB.TextBox Text_diameter 
         Enabled         =   0   'False
         Height          =   350
         Left            =   2040
         TabIndex        =   25
         Top             =   5760
         Width           =   1815
      End
      Begin VB.TextBox Text_Capacity 
         Enabled         =   0   'False
         Height          =   350
         Left            =   2040
         TabIndex        =   23
         Top             =   5280
         Width           =   1815
      End
      Begin VB.TextBox Text_Tanktype 
         Enabled         =   0   'False
         Height          =   350
         Left            =   2040
         TabIndex        =   21
         Top             =   4800
         Width           =   1815
      End
      Begin VB.CheckBox check_IsGauged 
         Enabled         =   0   'False
         Height          =   315
         Left            =   2040
         TabIndex        =   18
         Top             =   4440
         Width           =   1335
      End
      Begin VB.CheckBox Check_IsBlocked 
         Enabled         =   0   'False
         Height          =   315
         Left            =   2040
         TabIndex        =   16
         Top             =   3240
         Width           =   1335
      End
      Begin VB.CheckBox Check_IsAutoBlocking 
         Enabled         =   0   'False
         Height          =   315
         Left            =   2040
         TabIndex        =   14
         Top             =   2880
         Width           =   1335
      End
      Begin VB.TextBox Text_Grade 
         Enabled         =   0   'False
         Height          =   350
         Left            =   2040
         TabIndex        =   13
         Top             =   2400
         Width           =   1815
      End
      Begin VB.TextBox Text_description 
         Enabled         =   0   'False
         Height          =   350
         Left            =   2040
         TabIndex        =   11
         Top             =   1920
         Width           =   1815
      End
      Begin VB.TextBox Text_name 
         Enabled         =   0   'False
         Height          =   350
         Left            =   2040
         TabIndex        =   9
         Top             =   1440
         Width           =   1815
      End
      Begin VB.TextBox Text_number 
         Enabled         =   0   'False
         Height          =   350
         Left            =   2040
         TabIndex        =   7
         Top             =   960
         Width           =   1815
      End
      Begin VB.TextBox Text_id 
         Enabled         =   0   'False
         Height          =   350
         Left            =   2040
         TabIndex        =   5
         Top             =   480
         Width           =   1815
      End
      Begin VB.Label Label_StrappedTank 
         Caption         =   "Strapped Tank ID :"
         Height          =   255
         Left            =   360
         TabIndex        =   81
         Top             =   6720
         Width           =   1575
      End
      Begin VB.Label Label26 
         Caption         =   "Block reasons:"
         Height          =   255
         Left            =   360
         TabIndex        =   74
         Top             =   3600
         Width           =   1455
      End
      Begin VB.Label Label25 
         Caption         =   "Last events :"
         Height          =   375
         Left            =   240
         TabIndex        =   72
         Top             =   9000
         Width           =   1095
      End
      Begin VB.Label Label13 
         Caption         =   "Theorectical Volume :"
         Height          =   255
         Left            =   360
         TabIndex        =   26
         Top             =   6240
         Width           =   1695
      End
      Begin VB.Label Label12 
         Caption         =   "Diameter :"
         Height          =   255
         Left            =   360
         TabIndex        =   24
         Top             =   5760
         Width           =   1215
      End
      Begin VB.Label Label11 
         Caption         =   "Capacity :"
         Height          =   255
         Left            =   360
         TabIndex        =   22
         Top             =   5280
         Width           =   1215
      End
      Begin VB.Label Label10 
         Caption         =   "Tank type :"
         Height          =   255
         Left            =   360
         TabIndex        =   20
         Top             =   4800
         Width           =   1215
      End
      Begin VB.Label Label9 
         Caption         =   "Is Gauged :"
         Height          =   255
         Left            =   360
         TabIndex        =   19
         Top             =   4440
         Width           =   1335
      End
      Begin VB.Label Label8 
         Caption         =   "Is Blocked :"
         Height          =   255
         Left            =   360
         TabIndex        =   17
         Top             =   3240
         Width           =   1335
      End
      Begin VB.Label Label7 
         Caption         =   "Is Auto Blocking :"
         Height          =   255
         Left            =   360
         TabIndex        =   15
         Top             =   2880
         Width           =   1335
      End
      Begin VB.Label Label6 
         Caption         =   "Grade :"
         Height          =   255
         Left            =   360
         TabIndex        =   12
         Top             =   2400
         Width           =   1215
      End
      Begin VB.Label Label5 
         Caption         =   "Description :"
         Height          =   255
         Left            =   360
         TabIndex        =   10
         Top             =   1920
         Width           =   1215
      End
      Begin VB.Label Label4 
         Caption         =   "Name :"
         Height          =   255
         Left            =   360
         TabIndex        =   8
         Top             =   1440
         Width           =   1215
      End
      Begin VB.Label Label3 
         Caption         =   "Number :"
         Height          =   255
         Left            =   360
         TabIndex        =   6
         Top             =   960
         Width           =   1215
      End
      Begin VB.Label Label2 
         Caption         =   "Id :"
         Height          =   255
         Left            =   360
         TabIndex        =   4
         Top             =   480
         Width           =   1215
      End
   End
   Begin VB.ComboBox Combo_tanks 
      Height          =   315
      Left            =   1560
      TabIndex        =   1
      Text            =   "No Tanks"
      Top             =   240
      Width           =   2055
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "Close"
      Height          =   375
      Left            =   8040
      TabIndex        =   0
      Top             =   240
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Select tank :"
      Height          =   375
      Left            =   240
      TabIndex        =   2
      Top             =   240
      Width           =   1095
   End
End
Attribute VB_Name = "DialogTanks"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'**************************************************
' Tank detail Dialog
' Copyright 2013 Integration Technologies Ltd
'
' Select tank to show
' Show details of selected tank
' List tank events
' Change tank blocking
' Show tank guage alarms and readings
'**************************************************

Option Explicit

Private WithEvents CurTank As Tank
Attribute CurTank.VB_VarHelpID = -1
Private IgnoreEvents As Boolean






Private Sub Combo_tanks_Click()
    ShowTankDetail
End Sub

Private Sub Command_toggleAuto_Click()
    If (CurTank.IsAutoBlocking) Then
        CurTank.SetAutoBlocking False
    Else
        CurTank.SetAutoBlocking True
    End If
    
    ShowTankDetail
    
End Sub

Private Sub Command_toggleBlock_Click()
    If (CurTank.BlockedReasons And TankBlockedReasons_Manual) Then
        CurTank.SetBlock False
    Else
        CurTank.SetBlock True
    End If
    
    ShowTankDetail
    
End Sub


Private Sub Command_tvolSet_Click()
    Dim newLevel As Currency
    On Error GoTo Error
    
    newLevel = CCur(Text_theovolume)
    CurTank.SetTheorecticalVolume newLevel
    Exit Sub
Error:
    MsgBox "Error setting volume:" + Err.Description
End Sub





Private Sub CurTank_OnAlarm(ByVal Tank As ITL_Enabler_API.ITank, ByVal alarmType As Long, ByVal status As Boolean)
    List_events.AddItem "Tank:" + Format(Tank.number) + " OnAlarm : Alarm=" + Format(alarmType) + " Status:" + Format(status)
    ShowTankDetail
End Sub

Private Sub CurTank_OnGaugeLevelChanged(ByVal Tank As ITL_Enabler_API.ITank)
    List_events.AddItem "Tank:" + Format(Tank.number) + " OnGaugeLevelChanged : Volume=" + Format(Tank.GaugeReading.volume) + " Last Reading:" + FormatDateTime(Tank.GaugeReading.LastReading, vbGeneralDate)
    ShowTankDetail
End Sub

Private Sub CurTank_OnLevelChanged(ByVal Tank As ITL_Enabler_API.ITank)
    List_events.AddItem "Tank:" + Format(Tank.number) + " OnLevelChanged : TheoreticalVolume=" + Format(Tank.TheoreticalVolume)
    ShowTankDetail
End Sub

Private Sub CurTank_OnStatusChanged(ByVal Tank As ITL_Enabler_API.ITank, ByVal eventType As ITL_Enabler_API.TankStatusEventType)
    Select Case eventType
    Case TankStatusEventType_Blocked
        List_events.AddItem "Tank:" + Format(Tank.number) + " OnStatusChanged : Blocked=" + Format(Tank.IsBlocked)
    Case TankStatusEventType_AutoBlocking
        List_events.AddItem "Tank:" + Format(Tank.number) + " OnStatusChanged : AutoBlocking=" + Format(Tank.IsAutoBlocking)
    End Select
    
    ShowTankDetail
End Sub


Private Sub Form_Load()
    Dim Tank As Tank
    
    For Each Tank In FormMain.myforecourt.Tanks
        Combo_tanks.AddItem Format(Tank.id) + " \ " + Tank.name
    Next
    If (Combo_tanks.ListCount > 0) Then Combo_tanks.ListIndex = 0
    
    Check_Alarm(GaugeAlarmType.GaugeAlarmType_LeakAlarm).Caption = "Leak"
    Check_Alarm(GaugeAlarmType.GaugeAlarmType_HighWaterAlarm).Caption = "High Water"
    Check_Alarm(GaugeAlarmType.GaugeAlarmType_HighLimitAlarm).Caption = "High warning"
    Check_Alarm(GaugeAlarmType.GaugeAlarmType_LowLimitAlarm).Caption = "Low Alarm"
    Check_Alarm(GaugeAlarmType.GaugeAlarmType_OverfillAlarm).Caption = "High Alarm"
    Check_Alarm(GaugeAlarmType.GaugeAlarmType_LowLimitWarning).Caption = "Low Warning"
    
End Sub

Private Sub ShowAlarmDetail()

End Sub

Private Sub ShowTankDetail()
    Set CurTank = FormMain.myforecourt.Tanks.GetByIndex(Combo_tanks.ListIndex)
    If (CurTank Is Nothing) Then Exit Sub
    
    With CurTank
        Text_id = Format(.id)
        Text_number = Format(.number)
        Text_name = Format(.name)
        Text_description = .Description
        Text_Grade = .Grade.name
        
        Check_IsAutoBlocking = IsValue(.IsAutoBlocking)
        Check_IsBlocked = IsValue(.IsBlocked)
        
        Check_tank_user.value = BlockReasonCheckValue(.BlockedReasons, TankBlockedReasons_Manual)
        Check_tank_low_level.value = BlockReasonCheckValue(.BlockedReasons, TankBlockedReasons_LowLevel)
        Check_tank_delivery.value = BlockReasonCheckValue(.BlockedReasons, TankBlockedReasons_TankerDelivery)
      
        check_IsGauged = IsValue(.IsGauged)
        
        Select Case .TankType
            Case TankType_Gauged
                Text_Tanktype = "Gauged"
            Case TankType_ManualDip
                Text_Tanktype = "Manual dip"
            Case Default
                Text_Tanktype = "Other"
        End Select
        
        Text_Capacity = Format(.Capacity)
        Text_diameter = Format(.Diameter)
        Text_theovolume = Format(.TheoreticalVolume)
        
        ' Do alarms
        Dim alarmIndex As Integer
        For alarmIndex = 0 To 19
            Check_Alarm(alarmIndex) = IsValue(.GetAlarm(alarmIndex))
        Next
        
        Select Case .ConnectionType
            Case TankType_Gauged
                Text_Tanktype = "Gauged"
            Case TankType_ManualDip
                Text_Tanktype = "Manual dip"
            Case Default
                Text_Tanktype = "Other"
        End Select
        
        ' StrappedTank doesn't exist in API before 1.1.1
        Text_StrappedTank.Visible = False
        Label_StrappedTank.Visible = False
        On Error GoTo noStrappedID
        
        If .StrappedTank Is Nothing Then
            Text_StrappedTank.text = "none"
        Else
            Text_StrappedTank.text = Format(.StrappedTank.id) + "\" + .StrappedTank.name
        End If
        Text_StrappedTank.Visible = True
        Label_StrappedTank.Visible = True
        
noStrappedID:
        
    End With
        
    With CurTank.GaugeReading
        If (CurTank.IsGauged) Then
            Frame_gauge.Enabled = True
            Text_LastReading = FormatDateTime(.LastReading, vbGeneralDate)
            Text_level = Format(.level)
            Text_volume = Format(.volume)
            Text_nonCOmpensatedVolume = Format(.NonCompensatedVolume)
            Text_Temperature = Format(.Temperature)
            Text_Ullage = Format(.Ullage)
            Text_WaterLevel = Format(.WaterLevel)
            Text_WaterVolume = Format(.WaterVolume)
            Text_Density = Format(.Density)
            
            Select Case .ProbeStatus
                Case TankProbeStatus_NotConfigured
                    Text_ProbeStatus = "Not configured"
                Case TankProbeStatus_Offline
                    Text_ProbeStatus = "Offline"
                Case TankProbeStatus_Online
                    Text_ProbeStatus = "Online"
                Case TankProbeStatus_UnknownStatus
                Text_ProbeStatus = "Unknown Status"
            End Select
            
            Text_ProbeNumber = Format(.ProbeNumber)
            
        Else
            Frame_gauge.Enabled = False
            Text_LastReading = ""
            Text_level = ""
            Text_volume = ""
            Text_nonCOmpensatedVolume = ""
            Text_Temperature = ""
            Text_Ullage = ""
            Text_WaterLevel = ""
            Text_WaterVolume = ""
            Text_Density = ""
            Text_ProbeStatus = "Not configured"
            Text_ProbeNumber = ""
        End If
    End With
End Sub

Private Sub DoCommand(Command As String, result As ApiResult)
    If (result <> ApiResult_Ok) Then
        MsgBox Command + ":" + FormMain.myforecourt.GetResultString(result)
    End If
    ShowTankDetail
End Sub

Private Function BlockReasonCheckValue(reason As Integer, mask As Integer) As Integer
    If ((reason And mask) > 0) Then
        BlockReasonCheckValue = 1
    Else
        BlockReasonCheckValue = 0
    End If
End Function

Private Function IsValue(value As Boolean) As String
    If (value = True) Then
        IsValue = "1"
    Else
        IsValue = "0"
    End If
End Function


Private Sub OKButton_Click()
    Unload Me
End Sub
