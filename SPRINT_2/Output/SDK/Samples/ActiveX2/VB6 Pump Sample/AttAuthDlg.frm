VERSION 5.00
Begin VB.Form AttAuthDlg 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Attendant authorise"
   ClientHeight    =   1230
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   3780
   Icon            =   "AttAuthDlg.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1230
   ScaleWidth      =   3780
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.ComboBox AttendantList 
      Height          =   288
      Left            =   1320
      Style           =   2  'Dropdown List
      TabIndex        =   2
      Top             =   240
      Width           =   2295
   End
   Begin VB.CommandButton CancelButton 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   240
      TabIndex        =   1
      Top             =   720
      Width           =   1215
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "Auth pump "
      Height          =   372
      Left            =   2160
      TabIndex        =   0
      Top             =   720
      Width           =   1452
   End
   Begin VB.Label Label4 
      Alignment       =   1  'Right Justify
      Caption         =   "Attendant"
      Height          =   252
      Left            =   120
      TabIndex        =   3
      Top             =   240
      Width           =   852
   End
End
Attribute VB_Name = "AttAuthDlg"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'*****************************************************************
'*
'* Copyright (C) 1997-2003 Integration Technologies Limited
'* All rights reserved.
'*
'* This shows how to authorise a pump so that the delivery is recorded
'* against that attendant, without having to log the attendant on.
'* This might be used in the case where an attendant must authorise
'* the pump using a tag reader, and the application reads the tag numebr
'* and then authorises the pump using that attendant id.
'*
'******************************************************************/

Option Explicit

Public AuthPump As Integer

Private Sub CancelButton_Click()
    Unload Me
End Sub

Private Sub Form_Load()

Dim Att As Attendant
Dim i As Integer
Dim AttendantNumber As Integer

    ' populate a list of attendants - note that attendant numbers do NOT necessarily
    ' start at zero, and may not be a continuous sequence of numbers
    i = 0
    AttendantNumber = 1
    While i < MainForm.Session.NumberOfAttendants
        Set Att = MainForm.Session.Attendant(AttendantNumber)
        If Not Att Is Nothing Then
            AttendantList.AddItem (Att.name)
            AttendantList.ItemData(AttendantList.NewIndex) = Att.ID
            i = i + 1
        End If
        
        AttendantNumber = AttendantNumber + 1
    Wend
    
    If AttendantList.ListCount > 0 Then
        AttendantList.ListIndex = 0
    End If
    
End Sub

Private Sub OkButton_Click()

    Dim result As Integer

    ' authorise the pump for use
    result = MainForm.Pump(AuthPump).AttendantAuthorise(AttendantList.ItemData(AttendantList.ListIndex))
    If result <> OK_RESULT Then
        MsgBox MainForm.Session.ResultString(result), vbExclamation
        Exit Sub
    End If
    
    Hide
    Unload Me
    
End Sub
