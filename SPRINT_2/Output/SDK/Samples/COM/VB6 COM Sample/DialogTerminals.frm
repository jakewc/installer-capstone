VERSION 5.00
Begin VB.Form DialogTerminals 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Dialog Caption"
   ClientHeight    =   6540
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   7440
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   6540
   ScaleWidth      =   7440
   ShowInTaskbar   =   0   'False
   Begin VB.Frame Frame1 
      Caption         =   "Selected Terminal"
      Height          =   5655
      Left            =   120
      TabIndex        =   3
      Top             =   720
      Width           =   7095
      Begin VB.TextBox Text_Message 
         Height          =   495
         Left            =   2760
         TabIndex        =   23
         Text            =   "Hello terminal"
         Top             =   4440
         Width           =   2295
      End
      Begin VB.TextBox Text_Code 
         Height          =   495
         Left            =   1080
         TabIndex        =   22
         Text            =   "1"
         Top             =   4440
         Width           =   615
      End
      Begin VB.CommandButton Command_SendMessage 
         Caption         =   "Send Message to terminal"
         Height          =   495
         Left            =   5280
         TabIndex        =   20
         Top             =   4440
         Width           =   1455
      End
      Begin VB.Frame Frame2 
         Caption         =   "Permissions"
         Height          =   1335
         Left            =   360
         TabIndex        =   14
         Top             =   2760
         Width           =   6375
         Begin VB.CheckBox Check_Configure 
            Caption         =   "Configue"
            Enabled         =   0   'False
            Height          =   375
            Left            =   4320
            TabIndex        =   19
            Top             =   360
            Width           =   1815
         End
         Begin VB.CheckBox Check_modechange 
            Caption         =   "Mode change"
            Enabled         =   0   'False
            Height          =   375
            Left            =   2280
            TabIndex        =   18
            Top             =   720
            Width           =   1815
         End
         Begin VB.CheckBox Check_Pricechange 
            Caption         =   "Price Change"
            Enabled         =   0   'False
            Height          =   375
            Left            =   2280
            TabIndex        =   17
            Top             =   360
            Width           =   1815
         End
         Begin VB.CheckBox Check_Control 
            Caption         =   "Control"
            Enabled         =   0   'False
            Height          =   375
            Left            =   480
            TabIndex        =   16
            Top             =   720
            Width           =   1815
         End
         Begin VB.CheckBox Check_connect 
            Caption         =   "Connect"
            Enabled         =   0   'False
            Height          =   375
            Left            =   480
            TabIndex        =   15
            Top             =   360
            Width           =   1815
         End
      End
      Begin VB.CheckBox Check_isonline 
         Enabled         =   0   'False
         Height          =   375
         Left            =   2160
         TabIndex        =   13
         Top             =   1800
         Width           =   1815
      End
      Begin VB.TextBox Text_lastconnect 
         Enabled         =   0   'False
         Height          =   375
         Left            =   2160
         TabIndex        =   12
         Text            =   "Text1"
         Top             =   2280
         Width           =   1815
      End
      Begin VB.TextBox Text_name 
         Enabled         =   0   'False
         Height          =   375
         Left            =   2160
         TabIndex        =   9
         Text            =   "Text1"
         Top             =   1320
         Width           =   1815
      End
      Begin VB.TextBox Text_number 
         Enabled         =   0   'False
         Height          =   375
         Left            =   2160
         TabIndex        =   7
         Text            =   "Text1"
         Top             =   840
         Width           =   1815
      End
      Begin VB.TextBox Text_id 
         Enabled         =   0   'False
         Height          =   375
         Left            =   2160
         TabIndex        =   5
         Text            =   "Text1"
         Top             =   360
         Width           =   1815
      End
      Begin VB.Label Label8 
         Caption         =   "Message:"
         Height          =   375
         Left            =   1920
         TabIndex        =   24
         Top             =   4560
         Width           =   735
      End
      Begin VB.Label Label7 
         Caption         =   "Code:"
         Height          =   255
         Left            =   360
         TabIndex        =   21
         Top             =   4560
         Width           =   495
      End
      Begin VB.Label Label6 
         Caption         =   "Last connect date time :"
         Height          =   255
         Left            =   360
         TabIndex        =   11
         Top             =   2400
         Width           =   1935
      End
      Begin VB.Label Label5 
         Caption         =   "Is Online :"
         Height          =   255
         Left            =   360
         TabIndex        =   10
         Top             =   1920
         Width           =   1095
      End
      Begin VB.Label Label4 
         Caption         =   "Name :"
         Height          =   255
         Left            =   360
         TabIndex        =   8
         Top             =   1440
         Width           =   1095
      End
      Begin VB.Label Label3 
         Caption         =   "Number :"
         Height          =   255
         Left            =   360
         TabIndex        =   6
         Top             =   960
         Width           =   1095
      End
      Begin VB.Label Label2 
         Caption         =   "Id :"
         Height          =   255
         Left            =   360
         TabIndex        =   4
         Top             =   480
         Width           =   1095
      End
   End
   Begin VB.ComboBox Combo_terminals 
      Height          =   315
      Left            =   1440
      TabIndex        =   1
      Text            =   "No Terminals"
      Top             =   240
      Width           =   2775
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "Close"
      Height          =   375
      Left            =   6000
      TabIndex        =   0
      Top             =   240
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Select terminal:"
      Height          =   375
      Left            =   120
      TabIndex        =   2
      Top             =   240
      Width           =   1095
   End
End
Attribute VB_Name = "DialogTerminals"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'**************************************************
' Terminals detail Dialog
' Copyright 2013 Integration Technologies Ltd
'
' Select terminal to show
' Show details of selected terminal
' Send message to terminal
'**************************************************
Option Explicit

Private CurTerminal As Terminal

Private Sub Combo_terminals_Click()
    ShowTerminalDetails
End Sub

Private Sub Command_SendMessage_Click()
    If (Not CurTerminal Is Nothing) Then
        CurTerminal.SendMessage CLng(Text_Code), Text_Message
    End If
End Sub

Private Sub Form_Load()
    Dim Term As Terminal
    
    With FormMain.myforecourt
    
        For Each Term In .Terminals
            Combo_terminals.AddItem Format(Term.Id) + " \ " + Term.name
        Next Term
        If (.Terminals.Count > 0) Then Combo_terminals.ListIndex = 0
        
    End With

End Sub

Private Sub ShowTerminalDetails()
    Dim Perms As TerminalPermissions
    
    Set CurTerminal = FormMain.myforecourt.Terminals.GetByIndex(Combo_terminals.ListIndex)
    
    If (Not CurTerminal Is Nothing) Then
        With CurTerminal
            Text_id = .Id
            Text_number = .number
            Text_Name = .name
            Check_isonline = IsValue(.IsOnline)
            Text_lastconnect = FormatDateTime(.LastConnect, vbGeneralDate)
            
            Set Perms = .Permissions
            
            Check_connect = IsValue(Perms.Connect)
            Check_Control = IsValue(Perms.Control)
            Check_Pricechange = IsValue(Perms.PriceChange)
            Check_modechange = IsValue(Perms.ModeChange)
            Check_Configure = IsValue(Perms.Configure)
        End With
    End If
End Sub

Private Function IsValue(value As Boolean) As String
    If (value = True) Then
        IsValue = "1"
    Else
        IsValue = "0"
    End If
End Function

Private Sub OKButton_Click()
    Unload Me
End Sub
