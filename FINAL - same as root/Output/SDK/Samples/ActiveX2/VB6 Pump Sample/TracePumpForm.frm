VERSION 5.00
Begin VB.Form TracePumpForm 
   Caption         =   "Select Pump To Trace"
   ClientHeight    =   1425
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   1425
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
   Begin VB.ComboBox PumpList 
      Height          =   315
      ItemData        =   "TracePumpForm.frx":0000
      Left            =   240
      List            =   "TracePumpForm.frx":0002
      Style           =   2  'Dropdown List
      TabIndex        =   2
      Top             =   240
      Width           =   2295
   End
   Begin VB.CommandButton CancelBtn 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   2880
      TabIndex        =   1
      Top             =   840
      Width           =   1575
   End
   Begin VB.CommandButton TraceBtn 
      Caption         =   "Trace"
      Height          =   375
      Left            =   240
      TabIndex        =   0
      Top             =   840
      Width           =   1575
   End
End
Attribute VB_Name = "TracePumpForm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()

    PumpList.Clear
    If MainForm.Session.NumberOfPumps > 0 Then
        For i = 1 To MainForm.Session.NumberOfPumps
            If Not MainForm.pump(i) Is Nothing Then
                PumpList.AddItem Str(MainForm.pump(i).Number) + ", " + MainForm.pump(i).name
                PumpList.ListIndex = i - 1
            End If
        Next i
    End If
End Sub

Private Sub CancelBtn_Click()
    Unload Me
End Sub

Private Sub TraceBtn_Click()
    TraceForm.SelectPump PumpList.ListIndex + 1
    TraceForm.Show
    Unload Me
End Sub
