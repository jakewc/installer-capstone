VERSION 5.00
Begin VB.Form ReinstateDlg 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Form1"
   ClientHeight    =   1545
   ClientLeft      =   30
   ClientTop       =   330
   ClientWidth     =   3720
   Icon            =   "ReinstateDlg.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1545
   ScaleWidth      =   3720
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.CheckBox Check_Lock 
      Alignment       =   1  'Right Justify
      Caption         =   "And Lock"
      Height          =   195
      Left            =   960
      TabIndex        =   4
      Top             =   720
      Visible         =   0   'False
      Width           =   1335
   End
   Begin VB.TextBox IDText 
      Height          =   372
      Left            =   2135
      TabIndex        =   2
      Top             =   120
      Width           =   1335
   End
   Begin VB.CommandButton CancelButton 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   240
      TabIndex        =   1
      Top             =   1080
      Width           =   1212
   End
   Begin VB.CommandButton OkButton 
      Caption         =   "OK"
      Height          =   375
      Left            =   2160
      TabIndex        =   0
      Top             =   1080
      Width           =   1332
   End
   Begin VB.Label Label1 
      Alignment       =   1  'Right Justify
      Caption         =   "Delivery ID"
      Height          =   252
      Left            =   240
      TabIndex        =   3
      Top             =   240
      Width           =   1572
   End
End
Attribute VB_Name = "ReinstateDlg"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'*****************************************************************
'*
'* Copyright (C) 1997-2003 Integration Technologies Limited
'* All rights reserved.
'*
'* This dialog is an example of how to apply a limit to a post pay
'* sale - in other words a Preset Limit.
'*
'******************************************************************
Option Explicit
Public ReinstatePump As Integer

'******************************************************************
'*
'*  Cancel_Click - Click event for the cancel button, this
'*      cancels the reinstate dialog
'*
'******************************************************************
Private Sub CancelButton_Click()
    Hide
    Unload Me
End Sub

Private Sub Form_Load()
     
   ' only show with version 4
   Check_Lock.Visible = MainForm.Version4
   
End Sub

'******************************************************************
'*
'*  OkButton_Click - Click event to continue with reinstate
'*      processing. If sucessfull the reinstated delivery will
'*      be displayed on the stack of the selected pump.
'*
'******************************************************************
Private Sub OkButton_Click()

    Dim ID As Long
    Dim result As Integer
   
    ' check that the limit is a valid number
    On Error GoTo bad_value
    ID = CLng(IDText.Text)
    On Error GoTo 0
    
  
    If Check_Lock.Value = vbChecked Then
        result = MainForm.Pump(ReinstatePump).ReinstateDeliveryAndLock(ID)
    Else
        result = MainForm.Pump(ReinstatePump).ReinstateDelivery(ID)
    End If
    
    ' if reinstate failed then display the error
    If result <> OK_RESULT Then
        MsgBox MainForm.Session.ResultString(result), vbExclamation
    End If
    
    Hide
    Unload Me
    
    Exit Sub
    
bad_value:
    MsgBox "Invalid delivery ID, please re-enter.", vbExclamation
End Sub
