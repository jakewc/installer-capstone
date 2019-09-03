VERSION 5.00
Begin VB.Form CaptionDlg 
   Caption         =   "Caption Text"
   ClientHeight    =   1635
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   4695
   LinkTopic       =   "Form1"
   ScaleHeight     =   1635
   ScaleWidth      =   4695
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton ClearBtn 
      Caption         =   "Clear Text"
      Height          =   375
      Left            =   1800
      TabIndex        =   4
      Top             =   1080
      Width           =   1215
   End
   Begin VB.TextBox CaptionText 
      Height          =   375
      Left            =   120
      MaxLength       =   250
      TabIndex        =   3
      Top             =   480
      Width           =   4455
   End
   Begin VB.CommandButton OkBtn 
      Caption         =   "Ok"
      Height          =   375
      Left            =   3120
      TabIndex        =   1
      Top             =   1080
      Width           =   1455
   End
   Begin VB.CommandButton CancelBtn 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   120
      TabIndex        =   0
      Top             =   1080
      Width           =   1575
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      Caption         =   "Caption Text"
      Height          =   255
      Left            =   1800
      TabIndex        =   2
      Top             =   120
      Width           =   1095
   End
End
Attribute VB_Name = "CaptionDlg"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'*****************************************************************
'*
'* Copyright (C) 1997-2012 Integration Technologies Limited
'* All rights reserved.
'*
'* This dialog is an example of how to set the caption text on an icon
'* and to demonstrate the appearance of the caption text
'*
'******************************************************************
Option Explicit
Public CaptionPump As Integer

'******************************************************************
'*
'*  CancelBtn_Click - Click event for the cancel button, this
'*      cancels the caption text dialog
'*
'******************************************************************
Private Sub CancelBtn_Click()
    Hide
    Unload Me
End Sub

'******************************************************************
'*
'*  ClearBtn_Click - Click event to clear the caption text
'*
'******************************************************************
Private Sub ClearBtn_Click()

    MainForm.Pump(CaptionPump).SetCaptionText ""
       
    Hide
    Unload Me
    
End Sub

'******************************************************************
'*
'*  OkBtn_Click - Click event to save the caption text to the pump
'* icon
'*
'******************************************************************
Private Sub OkBtn_Click()
    
    MainForm.Pump(CaptionPump).SetCaptionText (CaptionText.Text)
       
    Hide
    Unload Me
    
End Sub

