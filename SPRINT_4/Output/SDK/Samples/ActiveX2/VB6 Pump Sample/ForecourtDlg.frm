VERSION 5.00
Begin VB.Form ForecourtDlg 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Forecourt Control Dialog"
   ClientHeight    =   3240
   ClientLeft      =   4560
   ClientTop       =   3900
   ClientWidth     =   3360
   ControlBox      =   0   'False
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3240
   ScaleWidth      =   3360
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.TextBox edtPrice2 
      Alignment       =   1  'Right Justify
      Height          =   315
      Left            =   1800
      TabIndex        =   1
      Top             =   1200
      Width           =   1215
   End
   Begin VB.ComboBox lstModeProfile 
      Height          =   315
      Left            =   360
      Style           =   2  'Dropdown List
      TabIndex        =   3
      Top             =   2160
      Width           =   2655
   End
   Begin VB.TextBox edtPrice1 
      Alignment       =   1  'Right Justify
      Height          =   315
      Left            =   360
      TabIndex        =   0
      Top             =   1200
      Width           =   1215
   End
   Begin VB.ComboBox lstGrade 
      Height          =   315
      Left            =   360
      TabIndex        =   2
      Text            =   "lstGrade"
      Top             =   480
      Width           =   2655
   End
   Begin VB.CommandButton bnApply 
      Caption         =   "Apply"
      Height          =   375
      Left            =   960
      TabIndex        =   4
      Top             =   2760
      Width           =   1095
   End
   Begin VB.CommandButton bnOkay 
      Cancel          =   -1  'True
      Caption         =   "Close"
      Default         =   -1  'True
      Height          =   375
      Left            =   2160
      TabIndex        =   5
      Top             =   2760
      Width           =   1095
   End
   Begin VB.Frame Frame1 
      Caption         =   "Grade pricing"
      Height          =   1575
      Left            =   120
      TabIndex        =   6
      Top             =   120
      Width           =   3135
      Begin VB.Label Label2 
         Caption         =   "Credit"
         Height          =   255
         Left            =   1680
         TabIndex        =   8
         Top             =   840
         Width           =   1095
      End
      Begin VB.Label Label1 
         Caption         =   "Cash "
         Height          =   255
         Left            =   240
         TabIndex        =   7
         Top             =   840
         Width           =   1095
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "Site profile"
      Height          =   855
      Left            =   120
      TabIndex        =   9
      Top             =   1800
      Width           =   3135
   End
End
Attribute VB_Name = "ForecourtDlg"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'*****************************************************************
'*
'* Copyright (C) 1997-2003 Integration Technologies Limited
'* All rights reserved.
'*
'* This Dialog demonstrates some of the administration type tasks
'* that can be performed using the Enabler SessionX and PumpX controls.
'*
'******************************************************************/
Option Explicit

Private Sub bnApply_Click()
    
    On Error GoTo InvalidPriceEntered
    
    With MainForm.Session
        .grade(lstGrade.ListIndex + 1).Price(1) = CCur(edtPrice1.Text)
        .grade(lstGrade.ListIndex + 1).Price(2) = CCur(edtPrice2.Text)
        .CurrentSiteModeProfile = lstModeProfile.ListIndex + 1
    End With
    
    Exit Sub
    
InvalidPriceEntered:
    MsgBox "Invalid grade price entered", vbExclamation + vbOKOnly
    
End Sub

Private Sub bnOkay_Click()
    Unload Me
End Sub

Public Sub RefreshData()
   
    Dim i As Integer

    With MainForm.Session
        ' get list of grades
        lstGrade.Clear
        For i = 1 To .NumberOfGrades
            lstGrade.AddItem .grade(i).name
        Next i
        lstGrade.ListIndex = 0
        
        ' get list of site mode profiles
        For i = 1 To .NumberOfSiteModeProfiles
            lstModeProfile.AddItem .SiteModeProfileName(i)
        Next i
        
        ' set list to the currently active site profile
        lstModeProfile.ListIndex = .CurrentSiteModeProfile - 1
    End With
    
End Sub

Private Sub Form_Load()
    RefreshData
End Sub

Private Sub lstGrade_Click()
    With MainForm.Session
        edtPrice1.Text = Format(.grade(lstGrade.ListIndex + 1).Price(1), "#,##0.000")
        edtPrice2.Text = Format(.grade(lstGrade.ListIndex + 1).Price(2), "#,##0.000")
    End With
End Sub

