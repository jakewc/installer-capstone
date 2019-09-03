VERSION 5.00
Begin VB.Form DialogGlobalSettings 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Global Settings"
   ClientHeight    =   4335
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   4560
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4335
   ScaleWidth      =   4560
   ShowInTaskbar   =   0   'False
   Begin VB.ListBox List_pricelevels 
      Enabled         =   0   'False
      Height          =   1035
      Left            =   1920
      TabIndex        =   14
      Top             =   3120
      Width           =   2535
   End
   Begin VB.TextBox Text_FuellingTimeout 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1920
      TabIndex        =   11
      Text            =   "Text1"
      Top             =   2520
      Width           =   975
   End
   Begin VB.TextBox Text_MonitorTimeout 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1920
      TabIndex        =   10
      Text            =   "Text1"
      Top             =   2040
      Width           =   975
   End
   Begin VB.TextBox Text_reserveTimeout 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1920
      TabIndex        =   8
      Text            =   "Text1"
      Top             =   1080
      Width           =   975
   End
   Begin VB.TextBox Text_AuthTimeout 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1920
      TabIndex        =   6
      Text            =   "Text1"
      Top             =   1560
      Width           =   975
   End
   Begin VB.CheckBox Check_Automode 
      Enabled         =   0   'False
      Height          =   255
      Left            =   1920
      TabIndex        =   3
      Top             =   240
      Width           =   975
   End
   Begin VB.TextBox Text_maxStack 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1920
      TabIndex        =   2
      Text            =   "Text1"
      Top             =   600
      Width           =   975
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "Close"
      Height          =   375
      Left            =   3240
      TabIndex        =   0
      Top             =   240
      Width           =   1215
   End
   Begin VB.Label Label5 
      Caption         =   "Price Levels:"
      Height          =   255
      Left            =   120
      TabIndex        =   13
      Top             =   3120
      Width           =   1935
   End
   Begin VB.Label Label3 
      Caption         =   "Fuelling Timeout:"
      Height          =   255
      Left            =   120
      TabIndex        =   12
      Top             =   2640
      Width           =   1935
   End
   Begin VB.Label Label7 
      Caption         =   "Monitor Timeout:"
      Height          =   255
      Left            =   120
      TabIndex        =   9
      Top             =   2160
      Width           =   1935
   End
   Begin VB.Label Label6 
      Caption         =   "Reserve Timeout:"
      Height          =   255
      Left            =   120
      TabIndex        =   7
      Top             =   1200
      Width           =   1935
   End
   Begin VB.Label Label4 
      Caption         =   "Authorise Timeout:"
      Height          =   255
      Left            =   120
      TabIndex        =   5
      Top             =   1680
      Width           =   1935
   End
   Begin VB.Label Label2 
      Caption         =   "Auto Mode Change:"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   240
      Width           =   1575
   End
   Begin VB.Label Label1 
      Caption         =   "Max Stack size"
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   720
      Width           =   855
   End
End
Attribute VB_Name = "DialogGlobalSettings"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'**************************************************
' GlobalSettings Dialog
' Copyright 2013 Integration Technologies Ltd
'
' Show the value of the Global settings.
'**************************************************

Option Explicit


Private Sub Form_Load()
    With FormMain.myforecourt.Settings
    
    If (.AutoModeChange = True) Then
        Check_Automode = 1
    Else
        Check_Automode = 0
    End If
    
    Text_maxStack = Format(.MaxStackSize)
    
    Text_reserveTimeout = Format(.ReserveTimeout)
    Text_AuthTimeout = Format(.AuthoriseTimeout)
    Text_MonitorTimeout = Format(.MonitorTimeout)
    Text_FuellingTimeout = Format(.FuellingTimeout)

    Dim pl As PriceLevel
    List_pricelevels.Clear
    For Each pl In .PriceLevels
        List_pricelevels.AddItem ("Price level " + Format(pl.number) + ":" + pl.name + ":" + pl.Description)
    Next pl

    End With
End Sub

Private Sub OKButton_Click()
    Unload Me
End Sub

