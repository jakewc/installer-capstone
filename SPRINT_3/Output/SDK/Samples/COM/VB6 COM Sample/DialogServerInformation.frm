VERSION 5.00
Begin VB.Form DialogServerInformation 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Server Information"
   ClientHeight    =   2205
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   7755
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2205
   ScaleWidth      =   7755
   ShowInTaskbar   =   0   'False
   Begin VB.TextBox Text_ApiVersion 
      Enabled         =   0   'False
      Height          =   375
      Left            =   5760
      TabIndex        =   12
      Top             =   1080
      Width           =   1815
   End
   Begin VB.TextBox Text_ServerUpTime 
      Enabled         =   0   'False
      Height          =   375
      Left            =   5760
      TabIndex        =   10
      Text            =   "0"
      Top             =   600
      Width           =   1815
   End
   Begin VB.TextBox Text_ServerPlatformVersion 
      Enabled         =   0   'False
      Height          =   375
      Left            =   5760
      TabIndex        =   8
      Top             =   120
      Width           =   1815
   End
   Begin VB.TextBox Text_ServerPlatform 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1920
      TabIndex        =   6
      Top             =   1080
      Width           =   1815
   End
   Begin VB.TextBox Text_ServerVersion 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1920
      TabIndex        =   4
      Top             =   600
      Width           =   1815
   End
   Begin VB.TextBox Text_serverName 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1920
      TabIndex        =   2
      Top             =   120
      Width           =   1815
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "Close"
      Height          =   375
      Left            =   6360
      TabIndex        =   0
      Top             =   1680
      Width           =   1215
   End
   Begin VB.Label Label8 
      Caption         =   "API Version:"
      Height          =   255
      Left            =   3960
      TabIndex        =   11
      Top             =   1200
      Width           =   1455
   End
   Begin VB.Label Label6 
      Caption         =   "Server Uptime:"
      Height          =   255
      Left            =   3960
      TabIndex        =   9
      Top             =   720
      Width           =   1455
   End
   Begin VB.Label Label5 
      Caption         =   "Server Platform Version:"
      Height          =   255
      Left            =   3960
      TabIndex        =   7
      Top             =   240
      Width           =   1695
   End
   Begin VB.Label Label4 
      Caption         =   "Server Platform:"
      Height          =   255
      Left            =   120
      TabIndex        =   5
      Top             =   1200
      Width           =   1455
   End
   Begin VB.Label Label2 
      Caption         =   "Server Version:"
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   720
      Width           =   1455
   End
   Begin VB.Label Label1 
      Caption         =   "Server Name:"
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   240
      Width           =   1455
   End
End
Attribute VB_Name = "DialogServerInformation"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'**************************************************
' Server Information Dialog
' Copyright 2013 Integration Technologies Ltd
'
' Show server information details
'**************************************************
Option Explicit


Private Sub Form_Load()
    With FormMain.myforecourt.ServerInformation
    
        Text_serverName = .ServerName
        Text_ServerVersion = .ServerVersion
        Text_ServerPlatform = .ServerPlatform
        Text_ServerPlatformVersion = .ServerPlatformVersion
        Text_ServerUpTime = .ServerUptime

        Text_ApiVersion = .ApiVersion
    End With
End Sub

Private Sub OKButton_Click()
    Unload Me
End Sub

