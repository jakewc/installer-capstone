VERSION 5.00
Object = "{FE0065C0-1B7B-11CF-9D53-00AA003C9CB6}#1.1#0"; "Comct232.ocx"
Begin VB.Form AttendantDlg 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Attendant function"
   ClientHeight    =   4890
   ClientLeft      =   5520
   ClientTop       =   4050
   ClientWidth     =   5820
   ControlBox      =   0   'False
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4890
   ScaleWidth      =   5820
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton Cancel 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   615
      Left            =   4560
      TabIndex        =   7
      Top             =   4200
      Width           =   1095
   End
   Begin VB.Frame Frame1 
      Caption         =   "Logoff attendant "
      Height          =   1695
      Left            =   240
      TabIndex        =   6
      Top             =   120
      Width           =   5415
      Begin VB.CommandButton CloseReconcileButton 
         Caption         =   "Close Reconcile"
         Height          =   615
         Left            =   4320
         TabIndex        =   14
         Top             =   960
         Width           =   975
      End
      Begin VB.ComboBox AttendantList 
         Height          =   315
         ItemData        =   "AttendantDlg.frx":0000
         Left            =   1920
         List            =   "AttendantDlg.frx":0002
         Style           =   2  'Dropdown List
         TabIndex        =   4
         Top             =   480
         Width           =   2295
      End
      Begin VB.CommandButton LogoffButton 
         Caption         =   "Logoff "
         Height          =   615
         Left            =   4320
         TabIndex        =   5
         Top             =   240
         Width           =   975
      End
      Begin VB.Label Label4 
         Alignment       =   1  'Right Justify
         Caption         =   "Attendant"
         Height          =   255
         Left            =   240
         TabIndex        =   9
         Top             =   600
         Width           =   1575
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "Logon attendant"
      Height          =   2175
      Left            =   240
      TabIndex        =   8
      Top             =   1920
      Width           =   5415
      Begin VB.CommandButton LogonButton 
         Caption         =   "Logon"
         Height          =   615
         Left            =   4320
         TabIndex        =   3
         Top             =   240
         Width           =   975
      End
      Begin VB.TextBox LogonIDEdit 
         Height          =   375
         Left            =   1920
         TabIndex        =   0
         Top             =   240
         Width           =   2295
      End
      Begin VB.TextBox PasswordEdit 
         Height          =   375
         IMEMode         =   3  'DISABLE
         Left            =   1920
         PasswordChar    =   "*"
         TabIndex        =   1
         Top             =   720
         Width           =   2295
      End
      Begin VB.TextBox PumpNumberEdit 
         Height          =   375
         Left            =   1920
         TabIndex        =   2
         Text            =   "1"
         Top             =   1200
         Width           =   375
      End
      Begin ComCtl2.UpDown PumpNumberUpDown 
         Height          =   375
         Left            =   2280
         TabIndex        =   13
         TabStop         =   0   'False
         Top             =   1200
         Width           =   240
         _ExtentX        =   450
         _ExtentY        =   661
         _Version        =   327681
         Value           =   1
         AutoBuddy       =   -1  'True
         BuddyControl    =   "PumpNumberEdit"
         BuddyDispid     =   196618
         OrigLeft        =   3960
         OrigTop         =   2280
         OrigRight       =   4200
         OrigBottom      =   2655
         Max             =   32
         Min             =   1
         SyncBuddy       =   -1  'True
         BuddyProperty   =   65547
         Enabled         =   -1  'True
      End
      Begin VB.Label Label3 
         Alignment       =   1  'Right Justify
         Caption         =   "Pump number"
         Height          =   255
         Left            =   600
         TabIndex        =   12
         Top             =   1320
         Width           =   1215
      End
      Begin VB.Label Label2 
         Alignment       =   1  'Right Justify
         Caption         =   "Password "
         Height          =   255
         Left            =   240
         TabIndex        =   11
         Top             =   840
         Width           =   1575
      End
      Begin VB.Label Label1 
         Alignment       =   1  'Right Justify
         Caption         =   "Logon ID"
         Height          =   255
         Left            =   240
         TabIndex        =   10
         Top             =   360
         Width           =   1575
      End
   End
End
Attribute VB_Name = "AttendantDlg"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'*****************************************************************
'*
'* Copyright (C) 1997-2003 Integration Technologies Limited
'* All rights reserved.
'*
'* This dialog demonstrates how to control the attendant logon and
'* logoff features.
'*
'******************************************************************/
Option Explicit

Private Sub Cancel_Click()
    Unload Me
End Sub


Private Sub Form_Load()

Dim Att As Attendant
Dim i As Integer
Dim AttendantsAdded As Integer

    ' populate the list of attendants, if no attendants exist
    ' then some will have to be created using the Enabler Managers
    ' application
    AttendantsAdded = 0
    i = 1
    ' the attendant numbers may not be a continuous sequence starting at 1, so we must test
    ' each attendant object and count the number we've added
    While AttendantsAdded < MainForm.Session.NumberOfAttendants
        Set Att = MainForm.Session.Attendant(i)
        If Not Att Is Nothing Then
            AttendantList.AddItem (Att.name)
            AttendantList.ItemData(AttendantList.NewIndex) = Att.ID
            AttendantsAdded = AttendantsAdded + 1
        End If
        i = i + 1
    Wend
    
     AttendantList.ListIndex = 0
     
End Sub

Private Sub CloseReconcileButton_Click()
Dim Att As Attendant
Dim result As Integer
    
    Set Att = MainForm.Session.AttendantByID(AttendantList.ItemData(AttendantList.ListIndex))
    If Not Att Is Nothing Then
        ' Close the period
        Att.ClosePeriod result, CInt(PumpNumberEdit.Text)
        If result <> OK_RESULT Then
            MsgBox MainForm.Session.ResultString(result), vbExclamation
        Else
            ' Period is now closed, now reconcile!
            Att.Reconcile result
            If result <> OK_RESULT Then
                MsgBox MainForm.Session.ResultString(result), vbExclamation
            End If
            Hide
        End If
    End If
    
End Sub

Private Sub LogoffButton_Click()
Dim Att As Attendant
Dim result As Integer
    
    ' logoff the attendant
    Set Att = MainForm.Session.AttendantByID(AttendantList.ItemData(AttendantList.ListIndex))
    If Not Att Is Nothing Then
        Att.LogoffPump result, CInt(PumpNumberEdit.Text)
        If result <> OK_RESULT Then
            MsgBox MainForm.Session.ResultString(result), vbExclamation
        Else
            Hide
        End If
    End If
    
    ' at this point an attendant report would normally be printed showing the
    ' total amount of deliveries performed on pumps this attendant was logged
    ' onto, and the total amount of cash that was received from the attendant

End Sub

Private Sub LogonButton_Click()
Dim Att As Attendant
Dim result As Integer

    ' Log attendant onto the pump, from now until they are logged off
    ' every delivery will have thier attendant ID recorded along with
    ' details of the delivery.  The attendant may be logged onto more
    ' than one pump
    Set Att = MainForm.Session.AttendantByLogonID(LogonIDEdit.Text)
    If Not Att Is Nothing Then
        If Trim(Att.Password) = Trim(PasswordEdit.Text) Then
            Att.Logon result, CInt(PumpNumberEdit.Text)
            If result <> OK_RESULT Then
                MsgBox MainForm.Session.ResultString(result), vbExclamation
            Else
                Hide
            End If
        Else
            MsgBox "Invalid attendant password.", vbExclamation
        End If
    Else
        MsgBox "Invalid attendant logon id.", vbExclamation
    End If
    
End Sub
