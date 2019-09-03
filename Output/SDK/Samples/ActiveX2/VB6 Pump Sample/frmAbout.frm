VERSION 5.00
Begin VB.Form frmAbout 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "About MyApp"
   ClientHeight    =   3720
   ClientLeft      =   3840
   ClientTop       =   3675
   ClientWidth     =   5655
   ClipControls    =   0   'False
   ControlBox      =   0   'False
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3720
   ScaleWidth      =   5655
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.PictureBox picIcon 
      AutoSize        =   -1  'True
      ClipControls    =   0   'False
      Height          =   540
      Left            =   240
      Picture         =   "frmAbout.frx":0000
      ScaleHeight     =   336.791
      ScaleMode       =   0  'User
      ScaleWidth      =   336.791
      TabIndex        =   1
      Top             =   240
      Width           =   540
   End
   Begin VB.CommandButton cmdOK 
      Cancel          =   -1  'True
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   4440
      TabIndex        =   0
      Top             =   3240
      Width           =   1095
   End
   Begin VB.Label lblPsrvrVer 
      Height          =   1335
      Left            =   1080
      TabIndex        =   5
      Top             =   1800
      Width           =   3975
   End
   Begin VB.Label lblDescription 
      Caption         =   "Enabler PumpX and SessionX Demonstration."
      ForeColor       =   &H00000000&
      Height          =   570
      Left            =   1050
      TabIndex        =   2
      Top             =   1125
      Width           =   3885
   End
   Begin VB.Label lblTitle 
      Caption         =   "Application Title"
      ForeColor       =   &H00000000&
      Height          =   480
      Left            =   1050
      TabIndex        =   3
      Top             =   240
      Width           =   3885
   End
   Begin VB.Label lblVersion 
      Caption         =   "Version"
      Height          =   225
      Left            =   1050
      TabIndex        =   4
      Top             =   780
      Width           =   3885
   End
End
Attribute VB_Name = "frmAbout"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'*****************************************************************
'*
'* Copyright (C) 1997-2003 Integration Technologies Limited
'* All rights reserved.
'*
'* Application About Box - this also shows version strings from the
'* ActiveX controls and the Pump Server
'*
'******************************************************************/
Option Explicit

Private Sub cmdOK_Click()
  Unload Me
End Sub

Private Sub Form_Load()
Dim s As String
Dim t As String

    Me.Caption = "About " & App.Title
    lblVersion.Caption = "Version " & App.Major & "." & App.Minor & "." & App.Revision
    lblTitle.Caption = App.Title
    lblDescription.Caption = lblDescription + Chr(13) + "Copyright (C) 1997-2016 Integration Technologies Limited"
    
    ' Get server and control versions for display as this is useful
    ' during integration to ensure installation is as expected
    s = Trim(MainForm.Session.Version + Chr(13))
    
    ' Get the SesseionX control version and format it nicely
    t = MainForm.Session.ControlVersion
    If Left(t, 5) = "EnbSe" Then
        s = s + t + Chr(13)
    Else
        s = s + "EnbSessionX " + t + Chr(13)
    End If
    
    ' If pumps are configured then get the PumpX control version and
    ' format it nicely
    If MainForm.Session.NumberOfPumps > 0 Then
        t = MainForm.Pump(1).ControlVersion
        If Left(t, 5) = "EnbPu" Then
            s = s + t + Chr(13)
        Else
            s = s + "EnbPumpX " + t + Chr(13)
        End If
    End If
        
    lblPsrvrVer.Caption = s
       
End Sub

