VERSION 5.00
Begin VB.Form FormMain 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Sample COM Api Test"
   ClientHeight    =   10110
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   14925
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   10110
   ScaleWidth      =   14925
   StartUpPosition =   3  'Windows Default
   Begin VB.Frame Frame1 
      Caption         =   "Forecourt Properties"
      Height          =   1815
      Left            =   240
      TabIndex        =   43
      Top             =   1200
      Width           =   5295
      Begin VB.CommandButton Command_fallback 
         Caption         =   "Fallback"
         Height          =   315
         Left            =   3480
         TabIndex        =   63
         Top             =   1080
         Width           =   1575
      End
      Begin VB.TextBox Text_upsstate 
         Enabled         =   0   'False
         Height          =   285
         Left            =   1440
         TabIndex        =   53
         Top             =   1440
         Width           =   3615
      End
      Begin VB.TextBox Text_termid 
         Enabled         =   0   'False
         Height          =   285
         Left            =   1440
         TabIndex        =   51
         Top             =   1080
         Width           =   1695
      End
      Begin VB.TextBox Text_IsConnected 
         Enabled         =   0   'False
         Height          =   285
         Left            =   1440
         TabIndex        =   49
         Top             =   720
         Width           =   1695
      End
      Begin VB.TextBox Text_sitename 
         Enabled         =   0   'False
         Height          =   285
         Left            =   1440
         TabIndex        =   47
         Top             =   360
         Width           =   1695
      End
      Begin VB.CommandButton Command_serverInformation 
         Caption         =   "Server Information"
         Height          =   315
         Left            =   3480
         TabIndex        =   45
         Top             =   720
         Width           =   1575
      End
      Begin VB.CommandButton Command_Settings 
         Caption         =   "Global Settings"
         Height          =   315
         Left            =   3480
         TabIndex        =   44
         Top             =   360
         Width           =   1575
      End
      Begin VB.Label Label14 
         Caption         =   "UpsState :"
         Height          =   255
         Left            =   240
         TabIndex        =   52
         Top             =   1440
         Width           =   1215
      End
      Begin VB.Label Label13 
         Caption         =   "Terminal ID :"
         Height          =   255
         Left            =   240
         TabIndex        =   50
         Top             =   1080
         Width           =   1215
      End
      Begin VB.Label Label12 
         Caption         =   "Is Connected :"
         Height          =   255
         Left            =   240
         TabIndex        =   48
         Top             =   720
         Width           =   1215
      End
      Begin VB.Label Label11 
         Caption         =   "Site name :"
         Height          =   255
         Left            =   240
         TabIndex        =   46
         Top             =   360
         Width           =   975
      End
   End
   Begin VB.Frame Frame3 
      Caption         =   "Pumps panel"
      Height          =   3255
      Left            =   240
      TabIndex        =   31
      Top             =   4320
      Width           =   14535
      Begin Project1.PumpControl PumpControl 
         Height          =   2655
         Index           =   0
         Left            =   240
         TabIndex        =   32
         Top             =   360
         Visible         =   0   'False
         Width           =   1695
         _ExtentX        =   2990
         _ExtentY        =   4683
      End
      Begin Project1.PumpControl PumpControl 
         Height          =   2655
         Index           =   1
         Left            =   1920
         TabIndex        =   33
         Top             =   360
         Visible         =   0   'False
         Width           =   1695
         _ExtentX        =   2990
         _ExtentY        =   4683
      End
      Begin Project1.PumpControl PumpControl 
         Height          =   2655
         Index           =   2
         Left            =   3600
         TabIndex        =   34
         Top             =   360
         Visible         =   0   'False
         Width           =   1815
         _ExtentX        =   3201
         _ExtentY        =   4683
      End
      Begin Project1.PumpControl PumpControl 
         Height          =   2655
         Index           =   3
         Left            =   5400
         TabIndex        =   35
         Top             =   360
         Visible         =   0   'False
         Width           =   1695
         _ExtentX        =   2990
         _ExtentY        =   4683
      End
      Begin Project1.PumpControl PumpControl 
         Height          =   2655
         Index           =   4
         Left            =   7080
         TabIndex        =   36
         Top             =   360
         Visible         =   0   'False
         Width           =   1695
         _ExtentX        =   2990
         _ExtentY        =   4683
      End
      Begin Project1.PumpControl PumpControl 
         Height          =   2655
         Index           =   5
         Left            =   8760
         TabIndex        =   37
         Top             =   360
         Visible         =   0   'False
         Width           =   1695
         _ExtentX        =   2990
         _ExtentY        =   4683
      End
      Begin Project1.PumpControl PumpControl 
         Height          =   2655
         Index           =   6
         Left            =   10440
         TabIndex        =   38
         Top             =   360
         Visible         =   0   'False
         Width           =   1695
         _ExtentX        =   2990
         _ExtentY        =   4683
      End
      Begin Project1.PumpControl PumpControl 
         Height          =   2655
         Index           =   7
         Left            =   12120
         TabIndex        =   61
         Top             =   360
         Visible         =   0   'False
         Width           =   1695
         _ExtentX        =   2990
         _ExtentY        =   4683
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "ForeCourt Connect methods"
      Height          =   975
      Left            =   240
      TabIndex        =   22
      Top             =   120
      Width           =   14535
      Begin VB.CheckBox Check_active 
         Caption         =   "Active"
         Height          =   375
         Left            =   7800
         TabIndex        =   62
         Top             =   360
         Width           =   855
      End
      Begin VB.CommandButton Command_ConnectAsync 
         Caption         =   "Connect Async"
         Height          =   375
         Left            =   11160
         TabIndex        =   42
         Top             =   360
         Width           =   1335
      End
      Begin VB.CommandButton Command_disconnect 
         Caption         =   "Disconnect"
         Height          =   375
         Left            =   12960
         TabIndex        =   27
         Top             =   360
         Width           =   1455
      End
      Begin VB.CommandButton Command_connect 
         Caption         =   "Connect"
         Height          =   375
         Left            =   9720
         TabIndex        =   26
         Top             =   360
         Width           =   1335
      End
      Begin VB.TextBox Text_server 
         Height          =   375
         Left            =   1080
         TabIndex        =   25
         Text            =   "127.0.0.1"
         Top             =   360
         Width           =   1935
      End
      Begin VB.TextBox Text_terminalid 
         Height          =   375
         Left            =   4200
         TabIndex        =   24
         Text            =   "3"
         Top             =   360
         Width           =   735
      End
      Begin VB.TextBox Text_password 
         Height          =   375
         Left            =   5880
         TabIndex        =   23
         Text            =   "password"
         Top             =   360
         Width           =   1575
      End
      Begin VB.Label Label1 
         Caption         =   "Server:"
         Height          =   375
         Left            =   240
         TabIndex        =   30
         Top             =   360
         Width           =   855
      End
      Begin VB.Label Label3 
         Caption         =   "Terminal ID"
         Height          =   375
         Left            =   3240
         TabIndex        =   29
         Top             =   360
         Width           =   1095
      End
      Begin VB.Label Label2 
         Caption         =   "Password:"
         Height          =   375
         Left            =   5040
         TabIndex        =   28
         Top             =   360
         Width           =   975
      End
   End
   Begin VB.Frame Frame_methods 
      Caption         =   "Forecourt Methods"
      Enabled         =   0   'False
      Height          =   3015
      Left            =   5640
      TabIndex        =   8
      Top             =   1200
      Width           =   9135
      Begin VB.TextBox Text_currentMode 
         Height          =   285
         Left            =   7560
         TabIndex        =   64
         Top             =   1185
         Width           =   1335
      End
      Begin VB.ComboBox Combo_DataId 
         Height          =   315
         Left            =   7080
         TabIndex        =   59
         Top             =   1680
         Width           =   1815
      End
      Begin VB.ComboBox Combo_DataType 
         Height          =   315
         Left            =   5400
         TabIndex        =   58
         Top             =   1680
         Width           =   1575
      End
      Begin VB.ComboBox Combo_ActionType 
         Height          =   315
         Left            =   3720
         TabIndex        =   57
         Top             =   1680
         Width           =   1575
      End
      Begin VB.CommandButton Command_notifyChange 
         Caption         =   "Notify change"
         Height          =   285
         Left            =   1920
         TabIndex        =   56
         Top             =   1650
         Width           =   1695
      End
      Begin VB.CommandButton Command_removeLocksRes 
         Caption         =   "Remove locks and Reserves"
         Height          =   495
         Left            =   1800
         TabIndex        =   55
         Top             =   2400
         Width           =   1335
      End
      Begin VB.CommandButton Command_AllStop 
         Caption         =   "All Stop"
         Height          =   495
         Left            =   120
         TabIndex        =   54
         Top             =   2400
         Width           =   1335
      End
      Begin VB.CommandButton Command_setmode 
         Caption         =   "Set mode"
         Height          =   285
         Left            =   1920
         TabIndex        =   41
         Top             =   1185
         Width           =   1695
      End
      Begin VB.ComboBox Combo_modes 
         Height          =   315
         Left            =   3720
         TabIndex        =   40
         Top             =   1170
         Width           =   3135
      End
      Begin VB.TextBox Text_Message 
         Height          =   285
         Left            =   6960
         TabIndex        =   17
         Text            =   "Hello all terminals"
         Top             =   765
         Width           =   1935
      End
      Begin VB.TextBox Text_messId 
         Height          =   285
         Left            =   5520
         TabIndex        =   16
         Text            =   "1"
         Top             =   765
         Width           =   495
      End
      Begin VB.CommandButton Command_SendMessage 
         Caption         =   "Broadcast Message"
         Height          =   285
         Left            =   1920
         TabIndex        =   15
         Top             =   765
         Width           =   1695
      End
      Begin VB.TextBox Text_MessTerminals 
         Height          =   285
         Left            =   4440
         TabIndex        =   14
         Text            =   "-1"
         Top             =   765
         Width           =   495
      End
      Begin VB.CommandButton Command_TransByRef 
         Caption         =   "by Client Ref. "
         Height          =   285
         Left            =   3720
         TabIndex        =   11
         Top             =   240
         Width           =   1695
      End
      Begin VB.CommandButton Command_TransByID 
         Caption         =   "by Transaction ID"
         Height          =   285
         Left            =   1920
         TabIndex        =   10
         Top             =   240
         Width           =   1695
      End
      Begin VB.TextBox Text_TransLookup 
         Height          =   285
         Left            =   6840
         TabIndex        =   9
         Top             =   240
         Width           =   2055
      End
      Begin VB.Label Label16 
         Caption         =   "Current:"
         Height          =   255
         Left            =   6960
         TabIndex        =   65
         Top             =   1200
         Width           =   615
      End
      Begin VB.Label Label15 
         Caption         =   "Notify server"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   120
         TabIndex        =   60
         Top             =   1650
         Width           =   1935
      End
      Begin VB.Label Label10 
         Caption         =   "Site profile modes"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   120
         TabIndex        =   39
         Top             =   1185
         Width           =   1935
      End
      Begin VB.Label Label9 
         Caption         =   "Broadcast Message"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   120
         TabIndex        =   21
         Top             =   720
         Width           =   1935
      End
      Begin VB.Label Label8 
         Caption         =   "Message:"
         Height          =   285
         Left            =   6240
         TabIndex        =   20
         Top             =   765
         Width           =   735
      End
      Begin VB.Label Label7 
         Caption         =   "Id:"
         Height          =   285
         Left            =   5160
         TabIndex        =   19
         Top             =   765
         Width           =   375
      End
      Begin VB.Label Label4 
         Caption         =   "Terminal:"
         Height          =   285
         Left            =   3720
         TabIndex        =   18
         Top             =   765
         Width           =   735
      End
      Begin VB.Label Label5 
         Caption         =   "Trans ID/Ref:"
         Height          =   375
         Left            =   5640
         TabIndex        =   13
         Top             =   195
         Width           =   1095
      End
      Begin VB.Label Label6 
         Caption         =   "Lookup Transaction"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   12
         Top             =   255
         Width           =   1935
      End
   End
   Begin VB.Frame Frame_forecourt 
      Caption         =   "Forecourt collections"
      Enabled         =   0   'False
      Height          =   1215
      Left            =   240
      TabIndex        =   1
      Top             =   3000
      Width           =   5295
      Begin VB.CommandButton Command_Profiles 
         Caption         =   "Site Profiles"
         Height          =   375
         Left            =   1800
         TabIndex        =   7
         Top             =   720
         Width           =   1575
      End
      Begin VB.CommandButton Command_Terminals 
         Caption         =   "Terminals"
         Height          =   375
         Left            =   120
         TabIndex        =   6
         Top             =   720
         Width           =   1575
      End
      Begin VB.CommandButton Command_Grades 
         Caption         =   "Grades"
         Height          =   375
         Left            =   1800
         TabIndex        =   5
         Top             =   240
         Width           =   1575
      End
      Begin VB.CommandButton Command_Tanks 
         Caption         =   "Tanks"
         Height          =   375
         Left            =   120
         TabIndex        =   4
         Top             =   240
         Width           =   1575
      End
      Begin VB.CommandButton Command_pumps 
         Caption         =   "Pumps"
         Height          =   375
         Left            =   3480
         TabIndex        =   3
         Top             =   240
         Width           =   1575
      End
      Begin VB.CommandButton Command_Attendants 
         Caption         =   "Attendants"
         Height          =   375
         Left            =   3480
         TabIndex        =   2
         Top             =   720
         Width           =   1575
      End
   End
   Begin VB.ListBox List_log 
      Height          =   1815
      Left            =   240
      TabIndex        =   0
      Top             =   7680
      Width           =   14535
   End
End
Attribute VB_Name = "FormMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'**************************************************
' SamppleCom
' Copyright 2013 Integration Technologies Ltd
'
' Sample V4 COM application to show the use of the COM API and to
' allow the user to experiment with the V4 Api
'
' All forecourt objects can be displayed in dialogs with live events
' updating the values.
'
'**************************************************

Public WithEvents myforecourt As Forecourt
Attribute myforecourt.VB_VarHelpID = -1
Public WithEvents fallback As fallback
Attribute fallback.VB_VarHelpID = -1

Private MyTransRef As Integer
Private WithEvents Pumps As PumpCollection
Attribute Pumps.VB_VarHelpID = -1
Private WithEvents Grades As GradeCollection
Attribute Grades.VB_VarHelpID = -1


Private Sub Combo_modes_Change()
    AddLog "mode change", ""
End Sub


Private Sub Command_AllStop_Click()
     DoCommand "All Stop", myforecourt.Stop
End Sub



Private Sub DoCommand(Command As String, result As ApiResult)
    If (result <> ApiResult_Ok) Then
        MsgBox Command + ":" + FormMain.myforecourt.GetResultString(result)
    End If
    
    ForeCourtPropDetails
End Sub


Private Sub Command_Attendants_Click()

    DialogAttendants.Show vbModeless

End Sub


Private Sub Command_Grades_Click()
    DialogGrades.Show vbModeless, FormMain
End Sub


Private Sub Command_Profiles_Click()
    DialogProfiles.Show vbModal, FormMain
End Sub

Private Sub Command_pumps_Click()
    Dim Dlg As DialogPumps
    Set Dlg = New DialogPumps
    
    Dlg.Show vbModeless, FormMain
End Sub

Private Sub Command_ConnectAsync_Click()
    Dim result As ApiResult
    
    List_log.Clear
    
    On Error GoTo NyError
    
    result = myforecourt.ConnectAsync(Text_server, CLng(Text_terminalid.text), "vb6demo", Text_password.text, True)
    If (result <> ApiResult_Ok) Then
        MsgBox "Connect async error :" + myforecourt.GetResultString(result), vbExclamation
        Exit Sub
    End If
    
    Set Grades = myforecourt.Grades
    
    Exit Sub
    
NyError:
     AddLog "Error", "no:" + Format(Err.number) + " Desc:" + Err.Description

End Sub

'
' Connect to Pump Server
'
Private Sub Command_connect_Click()
    Dim result As ApiResult
    
    List_log.Clear
    
    On Error GoTo NyError
    
    result = myforecourt.Connect(Text_server, CLng(Text_terminalid.text), "vb6demo", Text_password.text, Check_active.value)
    If (result <> ApiResult_Ok) Then
        MsgBox "Connect error :" + myforecourt.GetResultString(result), vbExclamation
        Exit Sub
    End If

    Connect_ok
    
    Set Grades = myforecourt.Grades
    
    Exit Sub
NyError:
     AddLog "Error", "no:" + Format(Err.number) + " Desc:" + Err.Description

End Sub

Private Sub Connect_ok()

    On Error GoTo NyError
    
    Frame_forecourt.Enabled = True
    Frame_methods.Enabled = True
    
    ForeCourtPropDetails
    
    SetNotifyDefaults
    
    ' ********** Log Forecourt *****************
    AddLog "", "****** FORECOURT *********"
    LogForecourt
    
    
    ' ********** Log Attendants *****************
    AddLog "****** Attendants", "For each Attendant in Attendants" + ", Attendants count=" + Format(myforecourt.Attendants.Count)
    For Each attendantX In myforecourt.Attendants
       LogAttendant attendantX
    Next attendantX

    ' ********** Log Grades *****************
    AddLog "****** Grades", "For each grade in Grades" + ", Grades count=" + Format(myforecourt.Grades.Count)
    For Each GradeX In myforecourt.Grades
        LogGrade GradeX
    Next GradeX
    
    ' ********** Log Pumps *****************
    AddLog "****** Pumps", "For each pump in pumps" + ", Pumps count=" + Format(myforecourt.Pumps.Count)
    Set Pumps = myforecourt.Pumps
    For Each pumpX In Pumps
        LogPump pumpX
    Next
   
    Dim siteprofileX As Profile
    
    ' ********** Log profiles *****************
    AddLog "****** SiteProfiles", "For each siteprofileX in SiteProfiles" + ", Profiles count=" + Format(myforecourt.SiteProfiles.Count)
    Combo_modes.Clear
    For Each siteprofileX In myforecourt.SiteProfiles
       Combo_modes.AddItem Format(siteprofileX.Id) + " \ " + siteprofileX.name
       ' Select  the current profile in Combo box
       If (siteprofileX.Id = myforecourt.CurrentMode.Id) Then
            Combo_modes.ListIndex = Combo_modes.ListCount - 1
            Text_currentMode.text = Format(siteprofileX.Id)
       End If
       LogSiteProfile siteprofileX
    Next
    
    ' ********** Log tanks *****************
    AddLog "****** Tanks", "For each tank in tanks" + ", Tanks count=" + Format(myforecourt.Tanks.Count)
    For Each TankX In myforecourt.Tanks
       LogTank TankX
    Next TankX
    
    
    ' ********** Log Terminals *****************
    AddLog "****** Terminals", "For each terminal in Terminals" + ", Terminals count=" + Format(myforecourt.Terminals.Count)
    For Each terminalX In myforecourt.Terminals
       LogTerminal terminalX
    Next terminalX

    ' Load pump controls
    Dim PumpIndex As Integer
    PumpIndex = 0
    For Each pumpX In Pumps
        With PumpControl(PumpIndex)
            .Visible = True
            .SetPump pumpX
        End With
        PumpIndex = PumpIndex + 1
    Next
    
   Exit Sub
NyError:
     AddLog "Error", "no:" + Format(Err.number) + " Desc:" + Err.Description
     
End Sub


Private Sub ForeCourtPropDetails()
    With myforecourt
        Text_sitename = .SiteName
        Text_IsConnected = Format(.IsConnected)
        Text_termid = Format(.TerminalId)
        SetUpsState
    End With
End Sub

Private Sub SetNotifyDefaults()
    Dim X As Integer
    
    Combo_ActionType.Clear
    AddType Combo_ActionType, "Add", ActionType_Add
    AddType Combo_ActionType, "Delete", ActionType_Delete
    AddType Combo_ActionType, "Update", ActionType_Update
    Combo_ActionType.ListIndex = 2
    
    Combo_DataType.Clear
    
    AddType Combo_DataType, "Attendant", DataType_Attendant
    AddType Combo_DataType, "Grade", DataType_Grade
    AddType Combo_DataType, "Hose", DataType_Hose
    AddType Combo_DataType, "Opt", DataType_Opt
    AddType Combo_DataType, "PriceLevel", DataType_PriceLevel
    AddType Combo_DataType, "PriceProfile", DataType_PriceProfile
    AddType Combo_DataType, "Pump", DataType_Pump
    AddType Combo_DataType, "PumpAndHoses", DataType_PumpAndHoses
    AddType Combo_DataType, "Site", DataType_Site
    AddType Combo_DataType, "SiteMode", DataType_SiteMode
    AddType Combo_DataType, "Tank", DataType_Tank
    AddType Combo_DataType, "Terminals", DataType_Terminals
    AddType Combo_DataType, "PumpMode", DataType_PumpMode
    Combo_DataType.ListIndex = 0
    
    
End Sub


Private Sub AddType(myCombo As ComboBox, name As String, number As Integer)
    With myCombo
        .AddItem name
        .ItemData(.ListCount - 1) = number
    End With
End Sub

Private Sub Combo_DataType_Click()
    SetNotifyIDs
End Sub


' Depending on state of Data type combo set the list of Ids
Private Sub SetNotifyIDs()
    Dim DataIndex As Integer, dt As Integer
        
    If (Combo_DataType.ListIndex = -1) Then Exit Sub
    
    dt = CInt(Combo_DataType.ItemData(Combo_DataType.ListIndex))

    Combo_DataId.Clear
    Select Case dt

        Case DataType_Pump
            Dim pumpX As Pump
            For Each pumpX In myforecourt.Pumps
               AddType Combo_DataId, Format(pumpX.Id) + "\" + pumpX.name, pumpX.Id
            Next
        
        Case DataType_Grade
             Dim GradeX As Grade
            For Each GradeX In myforecourt.Grades
               AddType Combo_DataId, Format(GradeX.Id) + "\" + GradeX.name, GradeX.Id
            Next
       
        Case DataType_Attendant
            Dim attendantX As Attendant
            For Each attendantX In myforecourt.Attendants
               AddType Combo_DataId, Format(attendantX.Id) + "\" + attendantX.name, attendantX.Id
            Next
        
        Case DataType_Tank
            Dim TankX As Tank
            For Each TankX In myforecourt.Tanks
               AddType Combo_DataId, Format(TankX.Id) + "\" + TankX.name, TankX.Id
            Next
        
        Case DataType_SiteMode
            Dim profileX As Profile
            For Each profileX In myforecourt.SiteProfiles
               AddType Combo_DataId, Format(profileX.Id) + "\" + profileX.name, profileX.Id
            Next
        
        Case DataType_Terminals
            Dim terminalX As Terminal
            For Each terminalX In myforecourt.Terminals
               AddType Combo_DataId, Format(terminalX.Id) + "\" + terminalX.name, terminalX.Id
            Next
        
        ' Only specified the main ones, rest can be 1 to 10
        Case Else
            For X = 1 To 10
              AddType Combo_DataId, Format(X), (X)
            Next X
    End Select
    
    If (Combo_DataId.ListCount > 0) Then Combo_DataId.ListIndex = 0
    
    
End Sub

Private Sub Command_notifyChange_Click()
    Dim dt As Integer, at As Integer, di As Integer
    
    On Error GoTo ierror
    at = CInt(Combo_ActionType.ItemData(Combo_ActionType.ListIndex))
    dt = CInt(Combo_DataType.ItemData(Combo_DataType.ListIndex))
    di = CInt(Combo_DataId.ItemData(Combo_DataId.ListIndex))
    
    DoCommand "Notify", myforecourt.NotifyChange(at, dt, di)
    Exit Sub
    
ierror:
    MsgBox CommandType + ":" + myforecourt.GetResultString(result), vbExclamation
End Sub

'
' Disconnect from Pump Server
'
Private Sub Command_disconnect_Click()
    myforecourt.Disconnect "message"
    AddLog "State", "Disconnected"
    Frame_forecourt.Enabled = False
End Sub

Private Sub Command_removeLocksRes_Click()
     DoCommand "Remove Locks & Reserves", myforecourt.RemoveLocksAndReserve
End Sub

Private Sub Command_SendMessage_Click()
    myforecourt.BroadcastMessage CInt(Text_MessTerminals), CInt(Text_messId), Text_Message, 0
End Sub

Private Sub Command_serverInformation_Click()
  DialogServerInformation.Show vbModal, FormMain
End Sub


Private Sub Command_fallback_Click()
 DialogFallback.Show vbModeless, FormMain
End Sub


Private Sub Command_setmode_Click()
    Dim NewMode As Profile
    
    ' Find profile selected in combo
    Set NewMode = myforecourt.SiteProfiles.GetByIndex(Combo_modes.ListIndex)
    
    ' Set profile to be current profile
    If (Not NewMode Is Nothing) Then
        myforecourt.SetCurrentMode NewMode.Id
    End If
End Sub

Private Sub Command_Settings_Click()
    DialogGlobalSettings.Show vbModal, FormMain
End Sub

Private Sub Command_Tanks_Click()
    DialogTanks.Show vbModeless, FormMain
End Sub

Private Sub Command_Terminals_Click()
    DialogTerminals.Show vbModal, FormMain
End Sub

Private Sub Command_TransByID_Click()
    Dim trans As Transaction
    Dim result As ApiResult
    Dim Dlg As DialogTransaction
    Dim TransID As Long
    
    On Error GoTo Error
    
    TransID = CLng(Text_TransLookup)
    
    Set Dlg = New DialogTransaction
    
    result = myforecourt.GetTransactionById(TransID, trans)
    If (result = ApiResult_Ok) Then
        Dlg.SetTransaction trans
        Dlg.Show vbModal
    Else
        MsgBox "Transaction not found :" + myforecourt.GetResultString(result)
    End If
    Exit Sub
Error:
    MsgBox "Invalid Transaction ID"
    
End Sub


Private Sub Command_TransByRef_Click()
    Dim trans As Transaction
    Dim Ref As String
    
    On Error GoTo Error
    
    Ref = Text_TransLookup
    
    Set Dlg = New DialogTransaction
    
    result = myforecourt.GetTransactionByReference(Ref, trans)
    If (result = ApiResult_Ok) Then
        Dlg.SetTransaction trans
        Dlg.Show vbModal
    Else
        MsgBox "Transaction not found :" + myforecourt.GetResultString(result)
    End If
    
    Exit Sub
Error:
    
    MsgBox "Invalid reference"
End Sub

Private Sub Form_Load()
    Set myforecourt = CreateObject("Enabler.Forecourt")
    myforecourt.DebugMode = True
    
    Set fallback = myforecourt.fallback
    
    MyTransRef = 1
End Sub

Public Function GetNextRef() As String
    GetNextRef = "ref" + Format(DateTime.Now, "yymmddhh") + Format(MyTransRef, "0000")
    MyTransRef = MyTransRef + 1
End Function

Sub LogForecourt()
    Dim line As String
    
    With myforecourt
    line = "SiteName:" + .SiteName + ", CurrentMode:" + Format(.CurrentMode.Id) + ", IsConnected:" + Format(.IsConnected) + ", TerminalId" + Format(.TerminalId)
    line = line + ", PumpLightsOn:" + Format(.PumpLightsOn)
    AddLog "Forecourt", line
    
    line = "Mode:" + Format(myforecourt.fallback.mode) + " Active clients:" + Format(myforecourt.fallback.ActiveClients)
    AddLog "Fallback", line
    
    End With
End Sub

Sub LogGrade(ByVal gr As Grade)
    Dim line As String
    
    line = " Name:" + gr.name + ", Code:" + gr.code + ", GradeType:" + Format(gr.GradeType) + ", BlendRatio:" + Format(gr.BlendRatio)
    line = line + ", DeliveryTimeout:" + Format(gr.DeliveryTimeout) + ", AllocationLimit:" + Format(gr.AllocationLimit) + ", AllocationLimitType" + Format(gr.AllocationLimitType)
    line = line + ", IsBlocked" + Format(gr.IsBlocked) + ", PriceLevelCount:" + Format(gr.PriceLevelCount) + ", PriceProfileId:" + Format(gr.PriceProfileId) + ", PriceSignSegment:" + Format(gr.PriceSignSegment) + ", Unit:" + Format(gr.Unit)
    AddLog "Grade id:" + Format(gr.Id), line

End Sub

Sub LogTank(ByVal Tank As Tank)
    Dim line As String, text As String
    
    text = "Other"
    Select Case Tank.TankType
        Case TankType_Gauged
            text = "Gauged"
        Case TankType_ManualDip
             text = "ManualDip"
    End Select
    
    line = "Number:" + Format(Tank.number) + " Name:" + Tank.name + " Description:" + Tank.Description
    line = line + " Capacity:" + Format(Tank.Capacity) + " Diameter:" + Format(Tank.Diameter) + " TankType:" + text
    line = line + " IsAutoBlocking:" + Format(Tank.IsAutoBlocking) + " IsBlocked:" + Format(Tank.IsBlocked) + " IsGauged:" + Format(Tank.IsGauged)
    AddLog "Tank id:" + Format(Tank.Id), line
    
End Sub

Sub LogPump(ByVal pmp As Pump)

    Dim line As String

    line = "Number:" + Format(pmp.number) + ", Description:" + pmp.name + ", PumpLightsOn:" + Format(pmp.PumpLightsOn) + ", IsBlocked:" + Format(pmp.IsBlocked)
    line = line + ", IsCurrentTransaction:" + Format(pmp.IsCurrentTransaction) + ", State:" + Format(pmp.State) + ", Stack count:" + Format(pmp.TransactionStack.Count)
    AddLog "Pump Id:" + Format(pmp.Id), line
    
    LogSiteProfile pmp.CurrentProfile

    For Each transX In pmp.TransactionStack
       AddLog "Pump Id:" + Format(pmp.Id), "Stacked transaction:" + Format(transX.Id)
    Next
    
End Sub

Sub LogSiteProfile(ByVal Prof As Profile)
    Dim line As String
    
    line = "Number:" + Format(Prof.number) + " Name:" + Prof.name + " Lights:" + Format(Prof.Lights)
    line = line + " AllowedDays:" + Format(Prof.AllowedDays) + " StartTime:" + Format(Prof.StartTime)
    line = line + " IsAttendantsAllowed:" + Format(Prof.IsAttendantsAllowed) + " IsAutoAuthorise:" + Format(Prof.IsAutoAuthorise) + " IsAutoStack:" + Format(Prof.IsAutoStack)
    AddLog "Profie id:" + Format(Prof.Id), line
    
    line = "IsMonitor:" + Format(Prof.IsMonitor) + " IsStackingAllowed:" + Format(Prof.IsStackingAllowed)
    line = line + " IsFallbackAllowed:" + Format(Prof.IsFallbackAllowed) + " IsAutoFallbackAllowed:" + Format(Prof.IsAutoFallbackAllowed)
    AddLog "Profie id:" + Format(Prof.Id), line
    
End Sub

Sub LogAttendant(ByVal att As Attendant)
    Dim line As String
    
    With att
        line = " Number:" + Format(.number) + ", Name:" + .name + ", BlockReason:" + Format(.BlockReason) + ", IsBlocked:" + Format(.IsBlocked)
        line = line + ", Password:" + .password
        line = line + ", Tag:" + Format(.Tag)
    
        AddLog "Attendant id:" + Format(.Id), line

    End With
End Sub


Sub LogTerminal(ByVal Term As Terminal)
    Dim line As String
    
    With Term
        line = " Name:" + Format(.number) + ", Name:" + .name + ", IsOnline:" + Format(.IsOnline) + ", Last connect:" + FormatDateTime(.LastConnect)
        line = line + ", Configure:" + Format(.Permissions.Configure) + ", Connect:" + Format(.Permissions.Connect) + ", Control" + Format(.Permissions.Control)
        line = line + ", ModeChange" + Format(.Permissions.ModeChange) + ", PriceChange:" + Format(.Permissions.PriceChange)
    
        AddLog "Terminal id:" + Format(.Id), line

    End With
End Sub


Sub AddLog(header As String, message As String)
    If (List_log.ListCount > 31000) Then List_log.Clear
    List_log.AddItem (header + ":" + message)
    List_log.ListIndex = List_log.ListCount - 1
End Sub


Sub LogTransaction(ByVal trans As Transaction)
    AddLog "***** Transaction ******", ""
    With trans
    AddLog "ID:", Format(trans.Id)
    AddLog "clientActivity:", trans.clientActivity
    AddLog "clientReference:", trans.clientReference
    AddLog "IsLocked:", Format(trans.IsLocked)
    AddLog "LockedById:", Format(trans.LockedById)
    AddLog "State:", Format(trans.State)
    Select Case trans.State
        Case TransactionState_Authorised
           AddLog "State:", "Authorised"
      Case TransactionState_Fuelling
            AddLog "State:", "Fuelling"
      Case TransactionState_Completed
            AddLog "State:", "Completed"
      Case TransactionState_Cleared
            AddLog "State:", "Cleared"
      Case TransactionState_Reserved
            AddLog "State:", "Reserved"
      Case TransactionState_Cancelled
            AddLog "State:", "Cancelled"
    End Select
    AddLog "Errors:", Format(trans.Errors)
    If (.Attendant Is Nothing) Then
        AddLog "Attendant:", "None"
    Else
        AddLog "Attendant:", Format(.Attendant.Id) + "/" + .Attendant.name
    End If
    If (.LockedBy Is Nothing) Then
        AddLog "LockedBy:", "Nobody"
    Else
        AddLog "LockedBy:", Format(.LockedBy.Id) + "/" + .LockedBy.name
    End If
    End With

    AddLog "***** Transaction AuthoriseData ******", ""
    With trans.AuthoriseData
        AddLog "AuthoriseDateTime:", Format(.AuthoriseDateTime)
        AddLog "MoneyLimit:", Format(.MoneyLimit)
        AddLog "PriceLevel:", Format(.PriceLevel)
        AddLog "QuantityLimit:", Format(.QuantityLimit)
        
        Select Case .reason
            Case AuthoriseReason_Attendant
                AddLog "AuthoriseReason:", "Attendant"
            Case AuthoriseReason_Auto
                AddLog "AuthoriseReason:", "Auto"
            Case AuthoriseReason_Client
                AddLog "AuthoriseReason:", "Client"
            Case AuthoriseReason_Fallback
                AddLog "AuthoriseReason:", "Fallback"
            Case AuthoriseReason_Monitor
                AddLog "AuthoriseReason:", "Monitor"
            Case AuthoriseReason_NotAuthorised
                AddLog "AuthoriseReason:", "NotAuthorised"
            Case AuthoriseReason_PumpSelf
                AddLog "AuthoriseReason:", "PumpSelf"
        End Select
        
        If (.Terminal Is Nothing) Then
            AddLog "Terminal:", "None"
        Else
            AddLog "Terminal:", Format(.Terminal.Id)
        End If
        
    End With

    AddLog "***** Transaction DeliveryData ******", ""
    With trans.DeliveryData
        
        If (.Grade Is Nothing) Then
            AddLog "Grade:", "No grade"
        Else
            AddLog "Grade:", Format(.Grade.name)
        End If
        
        AddLog "Money:", FormatCurrency(.Money, 3)
        AddLog "MoneyTotal:", FormatCurrency(.MoneyTotal, 3)
        AddLog "Quantity:", Format(.Quantity, 3)
        AddLog "QuantityTotal:", Format(.QuantityTotal, 3)
        AddLog "unitPrice:", FormatCurrency(.UnitPrice, 3)
    End With
    
    AddLog "***** Transaction HistoryData ******", ""
    With trans.HistoryData
        AddLog "Age:", Format(.Age)
        AddLog "AuthoriseDateTime:", FormatDateTime(.AuthoriseDateTime)
        
        If (.ClearedBy Is Nothing) Then
            AddLog "ClearedBy:", "Nobody"
        Else
            AddLog "ClearedBy: Terminal -> ", Format(.ClearedBy.name)
        End If
        
        AddLog "ClearedDateTime:", FormatDateTime(.ClearedDateTime)
        AddLog "CompletedDateTime:", FormatDateTime(.CompletedDateTime)
        
        Select Case .CompletionReason
             Case CompletionReason_Cancelled
                AddLog "CompletionReason:", "Cancelled"
             Case CompletionReason_Normal
                AddLog "CompletionReason:", "Normal"
             Case CompletionReason_NotComplete
                AddLog "CompletionReason:", "NotComplete"
             Case CompletionReason_StoppedByClient
                AddLog "CompletionReason:", "StoppedByClient"
             Case CompletionReason_StoppedByError
                AddLog "CompletionReason:", "StoppedByError"
             Case CompletionReason_StoppedByLimit
                AddLog "CompletionReason:", "StoppedByLimit"
             Case CompletionReason_Timeout
                AddLog "CompletionReason:", "Timeout"
             Case CompletionReason_Zero
                AddLog "CompletionReason:", "Zero"
        End Select
        
        
        If (.ReservedBy Is Nothing) Then
            AddLog "ReservedBy:", "Nobody"
        Else
            AddLog "ReservedBy: Terminal -> ", Format(.ReservedBy.name)
        End If
        
        AddLog "FormatDateTime:", FormatDateTime(.ReservedDateTime)
    End With
    
    AddLog "***** End Transaction ******", ""

End Sub




Private Sub OnServerEvent()
    Debug.Print "Server event"

End Sub

Private Sub Form_Terminate()
    myforecourt.Disconnect "bye"
    
End Sub




Private Sub fallback_OnActiveClientsChange()
    AddLog "fallback_OnActiveClientsChange=", Format(myforecourt.fallback.ActiveClients)
End Sub

Private Sub fallback_OnModeChange()
    Dim smode As String
    
    Select Case myforecourt.fallback.mode
    Case FallbackMode_Active
        smode = "Active"
    Case FallbackMode_Inactive
        smode = "Inactive"
    Case FallbackMode_Startup
        smode = "Startup"
    End Select
    
    AddLog "fallback_OnModeChange=", smode
End Sub


Private Sub Frame4_DragDrop(Source As Control, X As Single, Y As Single)

End Sub

Private Sub myforecourt_OnConfigChange()
     AddLog "OnConfigChange", "Event"
End Sub

Private Sub myforecourt_OnConnectAsyncResult(ByVal ConnectResult As ITL_Enabler_API.ApiResult)
    AddLog "OnConnectAsyncResult", "Result=" + myforecourt.GetResultString(ConnectResult)
    If (ConnectResult = ApiResult_Ok) Then Connect_ok

End Sub


Private Sub myforecourt_OnMessageReceived(ByVal SourceTerminalId As Long, ByVal notificationId As Long, ByVal NotificationString As String)
     AddLog "OnMessageReceived", "Id=" + Format(notificationId) + "Message=" + NotificationString + " from term " + Format(SourceTerminalId)
End Sub

Private Sub myforecourt_OnServerEvent()
    AddLog "OnServerEvent", "Event connected:" + Format(myforecourt.IsConnected)
    ForeCourtPropDetails
End Sub

Private Sub myforecourt_OnServerJounalEvent(ByVal eventType As Integer, ByVal level As Integer, ByVal deviceType As Integer, ByVal deviceId As Long, ByVal deviceNumber As Long, ByVal message As String)
     AddLog "OnServerJounalEvent", "eventType=" + Format(eventType) + " level=" + Format(level)
End Sub

Private Sub SetUpsState()
    Text_upsstate = "Pwr:" + PowerState() + " Bat:" + BatteryState()
End Sub

Private Function PowerState() As String
    
    Select Case myforecourt.UpsState.PowerState
        Case UpsPowerState_Battery
            PowerState = "Battery"
        Case UpsPowerState_Mains
            PowerState = "Mains"
        Case UpsPowerState_Unknown
            PowerState = "Unknown"
    End Select
    
End Function

Private Function BatteryState() As String

    Select Case myforecourt.UpsState.BatteryState
        Case UpsBatteryState_Good     ' 0
            BatteryState = "Good"
        Case UpsBatteryState_Ok       ' 1
            BatteryState = "Ok"
        Case UpsBatteryState_Low      ' 2
            BatteryState = "Low"
        Case UpsBatteryState_Critical ' 3
            BatteryState = "Critical"
        Case UpsBatteryState_Fault    ' 4
            BatteryState = "Fault"
        Case UpsBatteryState_Unknown  ' 5
            BatteryState = "Unknown"
    End Select

End Function

Private Sub myforecourt_OnServerPowerEvent()
    SetUpsState
    AddLog "OnServerPowerEvent", Text_upsstate
End Sub

    
Private Sub myforecourt_OnStatusChange(ByVal eventType As ITL_Enabler_API.ForecourtStatusEventType)
    Select Case eventType
        Case ForecourtStatusEventType_CurrentModeID
             AddLog "OnStatusChange", "CurrentModeID changed id:" + Format(myforecourt.CurrentMode.Id) + "/" + myforecourt.CurrentMode.name
        
        Case ForecourtStatusEventType_PumpLights
             AddLog "OnStatusChange", "Pump lights :" + Format(myforecourt.PumpLightsOn)
    End Select

End Sub

Private Sub myforecourt_OnTagRead(ByVal tagId As Long, ByVal TagData As String, ByVal TagPresent As Boolean, ByVal TagReaderID As Long, ByVal pumpNumber As Long, ByVal AttendantId As Long)
     AddLog "OnTagRead", "Tagid:" + Format(tagId) + " Present:" + Format(TagPresent) + " ReaderID:" + Format(TagReaderID) + " Pumpnum:" + Format(pumpNumber) + "Tag data:" + TagData
End Sub


Private Sub Log_OnTransactionEvent(Pump As ITL_Enabler_API.Pump, ByVal eventType As ITL_Enabler_API.TransactionEventType, ByVal transactionId As Long)
    Select Case eventType
        Case TransactionEventType_Authorised
           AddLog "Pump_OnTransactionEvent", "Authorised" + " TransId:" + Format(transactionId)
           
      Case TransactionEventType_Fuelling
            AddLog "Pump_OnTransactionEvent", "Fuelling" + " TransId:" + Format(transactionId)
      
      Case TransactionEventType_Completed
            AddLog "Pump_OnTransactionEvent", "Completed" + " TransId:" + Format(transactionId)

      Case TransactionEventType_Cleared
            AddLog "Pump_OnTransactionEvent", "Cleared" + " TransId:" + Format(transactionId)
    
      Case TransactionEventType_Locked
            AddLog "Pump_OnTransactionEvent", "Locked" + " TransId:" + Format(transactionId)
      
      Case TransactionEventType_Unlocked
            AddLog "Pump_OnTransactionEvent", "UnLocked" + " TransId:" + Format(transactionId)
    
      Case TransactionEventType_Reserved
            AddLog "Pump_OnTransactionEvent", "Reserved" + " TransId:" + Format(transactionId)
      
      Case TransactionEventType_Reinstated
            AddLog "Pump_OnTransactionEvent", "Reinstated" + " TransId:" + Format(transactionId)
      Case TransactionEventType_Stacked
        AddLog "Pump_OnTransactionEvent", "Stacked" + " TransId:" + Format(transactionId)
      Case TransactionEventType_NotTaken
        AddLog "Pump_OnTransactionEvent", "NotTaken" + " TransId:" + Format(transactionId)
    End Select


End Sub


Private Sub Pumps_OnHoseEvent(ByVal Pump As ITL_Enabler_API.IPump, ByVal eventType As ITL_Enabler_API.HoseEventType, ByVal hoseNumber As Long)
    Dim sevent As String
    
    Select Case (eventType)
    Case HoseEventType_Lifted: sevent = "Lifted"
    Case HoseEventType_Replaced: sevent = "Replaced"
    Case HoseEventType_LeftOut: sevent = "LeftOut"
    Case HoseEventType_Block: sevent = "Block/" + Format(Pump.Hoses.GetByKey(hoseNumber).BlockedReasons)
    End Select
    
    AddLog "Pumps_OnHoseEvent", sevent + " for pump:" + Format(Pump.Id) + " Hose:" + Format(hoseNumber)

End Sub


Private Sub Pumps_OnTransactionEvent(ByVal Pump As ITL_Enabler_API.IPump, ByVal eventType As ITL_Enabler_API.TransactionEventType, ByVal transactionId As Long, ByVal Transaction As ITL_Enabler_API.IFuelTransaction)
    AddLog "Pumps_OnTransactionEvent pump:", Format(Pump.Id) + " Evt:" + Format(eventType) + " trans id:" + Format(transactionId)

    Log_OnTransactionEvent Pump, eventType, transactionId

End Sub


Private Sub Grades_OnPriceChange(ByVal Grade As ITL_Enabler_API.IGrade, ByVal level As Long, ByVal index As Long, ByVal Price As Currency)
    AddLog "Grades_OnPriceChange", " Grade:" + Format(Grade.Id) + " Price:" + Format(Price)

End Sub
