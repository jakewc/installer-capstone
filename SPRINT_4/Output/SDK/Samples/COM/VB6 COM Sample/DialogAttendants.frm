VERSION 5.00
Begin VB.Form DialogAttendants 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Attendants"
   ClientHeight    =   7384
   ClientLeft      =   2756
   ClientTop       =   3744
   ClientWidth     =   8450
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   7384
   ScaleWidth      =   8450
   ShowInTaskbar   =   0   'False
   Begin VB.Frame Frame1 
      Caption         =   "Attendant Details"
      Height          =   6495
      Left            =   120
      TabIndex        =   3
      Top             =   840
      Width           =   8175
      Begin VB.ListBox List_events 
         Height          =   1911
         Left            =   240
         TabIndex        =   25
         Top             =   4080
         Width           =   7695
      End
      Begin VB.ComboBox Combo_pumps 
         Height          =   315
         Left            =   240
         TabIndex        =   24
         Text            =   "Combo1"
         Top             =   3360
         Width           =   1215
      End
      Begin VB.CommandButton Command_logoffPump 
         Caption         =   "LogOff Pump"
         Height          =   495
         Left            =   2880
         TabIndex        =   23
         Top             =   3360
         Width           =   1215
      End
      Begin VB.CommandButton Command_logonPump 
         Caption         =   "LogOn Pump"
         Height          =   495
         Left            =   1560
         TabIndex        =   22
         Top             =   3360
         Width           =   1215
      End
      Begin VB.CommandButton Command_unblock 
         Caption         =   "UnBlock"
         Height          =   495
         Left            =   1560
         TabIndex        =   21
         Top             =   2640
         Width           =   1215
      End
      Begin VB.CommandButton Command_block 
         Caption         =   "Block"
         Height          =   495
         Left            =   240
         TabIndex        =   20
         Top             =   2640
         Width           =   1215
      End
      Begin VB.TextBox Text_tagID 
         Enabled         =   0   'False
         Height          =   285
         Left            =   1440
         TabIndex        =   19
         Top             =   1920
         Width           =   1335
      End
      Begin VB.TextBox Text_password 
         Enabled         =   0   'False
         Height          =   285
         Left            =   4680
         TabIndex        =   17
         Top             =   1920
         Width           =   1335
      End
      Begin VB.TextBox Text_name 
         Enabled         =   0   'False
         Height          =   285
         Left            =   4680
         TabIndex        =   15
         Top             =   1440
         Width           =   1335
      End
      Begin VB.TextBox Text_Logonid 
         Enabled         =   0   'False
         Height          =   285
         Left            =   4680
         TabIndex        =   13
         Top             =   960
         Width           =   1335
      End
      Begin VB.TextBox Text_BlockReason 
         Enabled         =   0   'False
         Height          =   285
         Left            =   4680
         TabIndex        =   11
         Top             =   480
         Width           =   1335
      End
      Begin VB.CheckBox Check_IsBlocked 
         Enabled         =   0   'False
         Height          =   255
         Left            =   1440
         TabIndex        =   9
         Top             =   1440
         Width           =   1335
      End
      Begin VB.TextBox Text_number 
         Enabled         =   0   'False
         Height          =   285
         Left            =   1440
         TabIndex        =   6
         Top             =   960
         Width           =   1335
      End
      Begin VB.TextBox Text_id 
         Enabled         =   0   'False
         Height          =   285
         Left            =   1440
         TabIndex        =   5
         Top             =   480
         Width           =   1335
      End
      Begin VB.Label Label14 
         Caption         =   "Attendant events :"
         Height          =   255
         Left            =   240
         TabIndex        =   26
         Top             =   4800
         Width           =   1095
      End
      Begin VB.Label Label12 
         Caption         =   "Tag ID:"
         Height          =   255
         Left            =   240
         TabIndex        =   18
         Top             =   1920
         Width           =   855
      End
      Begin VB.Label Label10 
         Caption         =   "Password:"
         Height          =   255
         Left            =   3480
         TabIndex        =   16
         Top             =   1920
         Width           =   855
      End
      Begin VB.Label Label9 
         Caption         =   "Name:"
         Height          =   255
         Left            =   3480
         TabIndex        =   14
         Top             =   1440
         Width           =   855
      End
      Begin VB.Label Label8 
         Caption         =   "Log on id:"
         Height          =   255
         Left            =   3480
         TabIndex        =   12
         Top             =   960
         Width           =   855
      End
      Begin VB.Label Label7 
         Caption         =   "Block reason:"
         Height          =   255
         Left            =   3480
         TabIndex        =   10
         Top             =   480
         Width           =   1215
      End
      Begin VB.Label Label5 
         Caption         =   "IsBlocked:"
         Height          =   255
         Left            =   240
         TabIndex        =   8
         Top             =   1440
         Width           =   735
      End
      Begin VB.Label Label4 
         Caption         =   "Number:"
         Height          =   255
         Left            =   240
         TabIndex        =   7
         Top             =   960
         Width           =   1095
      End
      Begin VB.Label Label2 
         Caption         =   "Id:"
         Height          =   255
         Left            =   240
         TabIndex        =   4
         Top             =   480
         Width           =   855
      End
   End
   Begin VB.ComboBox Combo_attendants 
      Height          =   315
      Left            =   1920
      TabIndex        =   2
      Text            =   "Combo1"
      Top             =   240
      Width           =   2655
   End
   Begin VB.CommandButton CancelButton 
      Cancel          =   -1  'True
      Caption         =   "Close"
      Height          =   375
      Left            =   7080
      TabIndex        =   0
      Top             =   240
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Select attendant"
      Height          =   375
      Left            =   240
      TabIndex        =   1
      Top             =   240
      Width           =   1455
   End
End
Attribute VB_Name = "DialogAttendants"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'**************************************************
' Attendant Dialog
' Copyright 2013 Integration Technologies Ltd
'
' Show details for each attendant.
' Logon,Logoff,Block and Unblock attendants
' List Attendant events
'**************************************************

Option Explicit

Private WithEvents CurAttendant As Attendant
Attribute CurAttendant.VB_VarHelpID = -1

Private Sub update_attendant()
    
    If (Combo_attendants.ListIndex > 0) Then
        Set CurAttendant = FormMain.myforecourt.Attendants.GetByIndex(Combo_attendants.ListIndex)
    End If
    
    If (Not CurAttendant Is Nothing) Then
        With CurAttendant
            Text_id = .Id
            Text_number = .number
            
            If (.IsBlocked) Then
                Check_IsBlocked.value = 1
            Else
                Check_IsBlocked.value = 0
            End If
            
            Text_BlockReason.text = Format(.BlockReason)
            Text_Logonid = .LogOnId
            Text_name = .name
            Text_password = .password
            Text_tagID = Format(.Tag)
        
        End With
    End If
End Sub


Private Sub CancelButton_Click()
    Unload Me
End Sub

Private Sub Combo_attendants_Click()
    update_attendant
End Sub


Private Sub Form_Load()
    Dim attendantX As Attendant
    Dim pumpX As Pump
    
    Combo_attendants.Clear
    
    For Each attendantX In FormMain.myforecourt.Attendants
        Combo_attendants.AddItem Format(attendantX.Id) + "\" + attendantX.name
    Next
    If (FormMain.myforecourt.Attendants.Count > 0) Then Combo_attendants.ListIndex = 0
    update_attendant
    
    For Each pumpX In FormMain.myforecourt.Pumps
        Combo_pumps.AddItem pumpX.name
    Next
    Combo_pumps.ListIndex = 0
    
End Sub


Private Sub Command_block_Click()
    If (Not CurAttendant Is Nothing) Then
        DoCommand "Block", CurAttendant.Block(1)
    End If
End Sub


Private Sub Command_logoffPump_Click()
    If (Not CurAttendant Is Nothing) Then
        DoCommand "LogOffPump", CurAttendant.LogOffPump(FindPump)
    End If
End Sub


Private Sub Command_logonPump_Click()
    If (Not CurAttendant Is Nothing) Then
        DoCommand "logonPump", CurAttendant.logonPump(FindPump)
    End If
End Sub

Private Function FindPump() As Integer
    Dim logonPump As Pump
    
    Set logonPump = FormMain.myforecourt.Pumps.GetByIndex(Combo_pumps.ListIndex)
    FindPump = logonPump.Id
End Function

Private Sub Command_unblock_Click()
    If (Not CurAttendant Is Nothing) Then
      DoCommand "Unblock", CurAttendant.Unblock
    End If
End Sub

Private Sub DoCommand(Command As String, result As ApiResult)
    If (result <> ApiResult_Ok) Then
        MsgBox Command + ":" + FormMain.myforecourt.GetResultString(result)
    End If
    update_attendant
End Sub

Private Sub OKButton_Click()
     Unload Me
End Sub

Private Sub AddEvent(ByVal Attendant As ITL_Enabler_API.IAttendant, etype As String, details As String)
    List_events.AddItem etype + ":" + details
End Sub

Private Sub CurAttendant_OnLogOff(ByVal Attendant As ITL_Enabler_API.IAttendant, ByVal pumpNumber As Long, ByVal tagId As Long)
    AddEvent Attendant, "OnLogOff", "Pump=" + Format(pumpNumber) + " Tag=" + Format(tagId)
    update_attendant
End Sub

Private Sub CurAttendant_OnLogOn(ByVal Attendant As ITL_Enabler_API.IAttendant, ByVal pumpNumber As Long, ByVal tagId As Long)
    AddEvent Attendant, "OnLogOn", "Pump=" + Format(pumpNumber) + " Tag=" + Format(tagId)
    update_attendant
End Sub


Private Sub CurAttendant_OnStatusChanged(ByVal Attendant As ITL_Enabler_API.IAttendant, ByVal eventType As ITL_Enabler_API.AttendantStatusEventType)
    Select Case eventType
        Case AttendantStatusEventType_Blocked
        AddEvent Attendant, "OnStatusChanged", "Attendant blocked:" + Format(Attendant.IsBlocked)
    End Select
    
    update_attendant
End Sub



