VERSION 5.00
Begin VB.Form DialogFallback 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Fallback Status"
   ClientHeight    =   4965
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   5190
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4965
   ScaleWidth      =   5190
   ShowInTaskbar   =   0   'False
   Begin VB.CommandButton Command_manfallback 
      Caption         =   "Activate Manual Fallback"
      Height          =   375
      Left            =   1800
      TabIndex        =   13
      Top             =   2880
      Width           =   3135
   End
   Begin VB.TextBox Text_pumps_noFallback 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1800
      TabIndex        =   11
      Text            =   "Text1"
      Top             =   2400
      Width           =   3135
   End
   Begin VB.TextBox Text_pumps_manual 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1800
      TabIndex        =   9
      Text            =   "Text1"
      Top             =   1920
      Width           =   3135
   End
   Begin VB.TextBox Text_pumps_auto 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1800
      TabIndex        =   7
      Text            =   "Text1"
      Top             =   1440
      Width           =   3135
   End
   Begin VB.ListBox List_event 
      Height          =   1230
      Left            =   120
      TabIndex        =   5
      Top             =   3600
      Width           =   4815
   End
   Begin VB.TextBox Text_mode 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1800
      TabIndex        =   4
      Text            =   "Text1"
      Top             =   840
      Width           =   3135
   End
   Begin VB.TextBox Text_active 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1800
      TabIndex        =   2
      Text            =   "Text1"
      Top             =   240
      Width           =   1215
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "Close"
      Height          =   375
      Left            =   3720
      TabIndex        =   0
      Top             =   240
      Width           =   1215
   End
   Begin VB.Label Label6 
      Caption         =   "Pumps no Fallback:"
      Height          =   375
      Left            =   120
      TabIndex        =   12
      Top             =   2400
      Width           =   1335
   End
   Begin VB.Label Label5 
      Caption         =   "Pumps with Manual Fallback:"
      Height          =   375
      Left            =   120
      TabIndex        =   10
      Top             =   1920
      Width           =   1335
   End
   Begin VB.Label Label4 
      Caption         =   "Pumps with Automatic Fallback:"
      Height          =   375
      Left            =   120
      TabIndex        =   8
      Top             =   1440
      Width           =   1575
   End
   Begin VB.Label Label3 
      Caption         =   "Fallback Events :"
      Height          =   255
      Left            =   120
      TabIndex        =   6
      Top             =   3360
      Width           =   1335
   End
   Begin VB.Label Label2 
      Caption         =   "Fallback Mode :"
      Height          =   375
      Left            =   120
      TabIndex        =   3
      Top             =   840
      Width           =   1335
   End
   Begin VB.Label Label1 
      Caption         =   "Active Terminals :"
      Height          =   375
      Left            =   120
      TabIndex        =   1
      Top             =   240
      Width           =   1335
   End
End
Attribute VB_Name = "DialogFallback"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'**************************************************
' Fallback Dialog
' Copyright 2013 Integration Technologies Ltd
'
' Show status of fallback system.
' Show pumps with automatic fallback and manual fallback pumps.
' Activate manual fallback
'**************************************************


Option Explicit
Public WithEvents myfallback As fallback
Attribute myfallback.VB_VarHelpID = -1


Private Sub Command_manfallback_Click()
    myfallback.ManualFallback True
    UpdateForm
End Sub

Private Sub Form_Load()
    Set myfallback = FormMain.myforecourt.fallback
    UpdateForm
End Sub

Private Sub UpdateForm()
    Dim pumpX As Pump
    Dim listAuto As String
    Dim listMan As String
    Dim listNone As String
    
    With myfallback
        Text_active.text = Format(.ActiveClients)
        Text_mode.text = getModeText(.mode)
        
        For Each pumpX In FormMain.myforecourt.Pumps
        If (pumpX.CurrentProfile.IsFallbackAllowed) Then
            If (pumpX.CurrentProfile.IsAutoFallbackAllowed) Then
                listAuto = listAuto + Format(pumpX.number) + " "
            Else
                listMan = listMan + Format(pumpX.number) + " "
            End If
        Else
            listNone = listNone + Format(pumpX.number) + " "
        End If
        Next pumpX
        
        Text_pumps_manual = listMan
        Text_pumps_auto = listAuto
        Text_pumps_noFallback = listNone
        
        ' Enable button
        Command_manfallback.Enabled = .mode
        
    End With
End Sub

Private Function getModeText(mode As FallbackMode) As String
    Select Case mode
        Case FallbackMode_Active
            getModeText = "Fallback is Active"
        Case FallbackMode_Inactive
            getModeText = "Fallback is Inactive"
        Case FallbackMode_Startup
            getModeText = "Fallback in startup"
        Case Default
            getModeText = "Unknown"
    End Select
End Function

Private Sub myfallback_OnActiveClientsChange()
    List_event.AddItem "Event OnActiveClientsChange  ActiveClients=" + Format(myfallback.ActiveClients)
    UpdateForm
End Sub


Private Sub myfallback_OnModeChange()
    List_event.AddItem "Event OnModeChange  Mode=" + getModeText(myfallback.mode)
    UpdateForm
End Sub

Private Sub OKButton_Click()
    Unload Me
End Sub
