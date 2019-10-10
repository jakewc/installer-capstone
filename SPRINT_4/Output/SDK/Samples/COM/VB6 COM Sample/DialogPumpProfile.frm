VERSION 5.00
Begin VB.Form DialogPumpProfile 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Pump Profile"
   ClientHeight    =   4260
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   4455
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4260
   ScaleWidth      =   4455
   ShowInTaskbar   =   0   'False
   Begin VB.TextBox Text_MaxStackSize 
      Enabled         =   0   'False
      Height          =   285
      Left            =   2400
      TabIndex        =   21
      Text            =   "0"
      Top             =   2040
      Visible         =   0   'False
      Width           =   855
   End
   Begin VB.CheckBox Check_AutoFallback 
      Enabled         =   0   'False
      Height          =   255
      Left            =   2400
      TabIndex        =   19
      Top             =   3840
      Width           =   1455
   End
   Begin VB.CheckBox Check_FallbackAllowed 
      Enabled         =   0   'False
      Height          =   255
      Left            =   2400
      TabIndex        =   17
      Top             =   3480
      Width           =   1455
   End
   Begin VB.CheckBox Check_AttendantsAllowed 
      Enabled         =   0   'False
      Height          =   255
      Left            =   2400
      TabIndex        =   8
      Top             =   240
      Width           =   735
   End
   Begin VB.CheckBox Check_ReserveAuth 
      Enabled         =   0   'False
      Height          =   255
      Left            =   2400
      TabIndex        =   7
      Top             =   2760
      Width           =   1455
   End
   Begin VB.CheckBox Check_SimpleAuth 
      Enabled         =   0   'False
      Height          =   255
      Left            =   2400
      TabIndex        =   6
      Top             =   2400
      Width           =   1455
   End
   Begin VB.CheckBox Check_Stacking 
      Enabled         =   0   'False
      Height          =   255
      Left            =   2400
      TabIndex        =   5
      Top             =   1680
      Width           =   1455
   End
   Begin VB.CheckBox Check_Monitor 
      Enabled         =   0   'False
      Height          =   255
      Left            =   2400
      TabIndex        =   4
      Top             =   1320
      Width           =   1455
   End
   Begin VB.CheckBox Check_AutoStack 
      Enabled         =   0   'False
      Height          =   255
      Left            =   2400
      TabIndex        =   3
      Top             =   960
      Width           =   1455
   End
   Begin VB.CheckBox Check_AutoAuthorise 
      Enabled         =   0   'False
      Height          =   255
      Left            =   2400
      TabIndex        =   2
      Top             =   600
      Width           =   735
   End
   Begin VB.CheckBox Check_LightsOn 
      Enabled         =   0   'False
      Height          =   255
      Left            =   2400
      TabIndex        =   1
      Top             =   3120
      Width           =   1455
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "Close"
      Height          =   375
      Left            =   3120
      TabIndex        =   0
      Top             =   240
      Width           =   1215
   End
   Begin VB.Label Label15 
      Caption         =   "Max Stack Size :"
      Height          =   255
      Left            =   240
      TabIndex        =   22
      Top             =   2040
      Visible         =   0   'False
      Width           =   1695
   End
   Begin VB.Label Label2 
      Caption         =   "Automatic Fallback:"
      Height          =   375
      Left            =   240
      TabIndex        =   20
      Top             =   3840
      Width           =   2055
   End
   Begin VB.Label Label1 
      Caption         =   "Fallback Allowed:"
      Height          =   375
      Left            =   240
      TabIndex        =   18
      Top             =   3480
      Width           =   2055
   End
   Begin VB.Label Label3 
      Caption         =   "Attendants Allowed:"
      Height          =   255
      Left            =   240
      TabIndex        =   16
      Top             =   240
      Width           =   1575
   End
   Begin VB.Label Label4 
      Caption         =   "Auto Authorise"
      Height          =   255
      Left            =   240
      TabIndex        =   15
      Top             =   600
      Width           =   1695
   End
   Begin VB.Label Label5 
      Caption         =   "Auto Stack:"
      Height          =   255
      Left            =   240
      TabIndex        =   14
      Top             =   960
      Width           =   1695
   End
   Begin VB.Label Label6 
      Caption         =   "Monitor:"
      Height          =   255
      Left            =   240
      TabIndex        =   13
      Top             =   1320
      Width           =   1695
   End
   Begin VB.Label Label7 
      Caption         =   "Stacking Allowed:"
      Height          =   255
      Left            =   240
      TabIndex        =   12
      Top             =   1680
      Width           =   1695
   End
   Begin VB.Label Label8 
      Caption         =   "Simple Authorise Allowed:"
      Height          =   375
      Left            =   240
      TabIndex        =   11
      Top             =   2400
      Width           =   2055
   End
   Begin VB.Label Label9 
      Caption         =   "Reserve Authorise Allowed:"
      Height          =   375
      Left            =   240
      TabIndex        =   10
      Top             =   2760
      Width           =   2415
   End
   Begin VB.Label Label10 
      Caption         =   "Lights On:"
      Height          =   375
      Left            =   240
      TabIndex        =   9
      Top             =   3120
      Width           =   2055
   End
End
Attribute VB_Name = "DialogPumpProfile"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'**************************************************
' Pump Profile Dialog
' Copyright 2013 Integration Technologies Ltd
'
' Show details of pump profile
'**************************************************
Option Explicit

Private CurProfile As Profile

Public Sub SetPump(Pump As Pump)
    Set CurProfile = Pump.CurrentProfile
End Sub

Private Sub Form_Load()
    ShowProfileDetail
End Sub

Private Sub ShowProfileDetail()

    If (Not CurProfile Is Nothing) Then
        With CurProfile
        
            Check_AttendantsAllowed = IsValue(.IsAttendantsAllowed)
            Check_AutoAuthorise = IsValue(.IsAutoAuthorise)
            Check_AutoStack = IsValue(.IsAutoStack)
            Check_Monitor = IsValue(.IsMonitor)
            Check_Stacking = IsValue(.IsStackingAllowed)
            'Text_MaxStackSize = Format(.MaxStackSize)
            Check_SimpleAuth = IsValue(.IsSimpleAuthAllowed)
            Check_ReserveAuth = IsValue(.IsReserveAuthAllowed)
            Check_LightsOn = IsValue(.Lights)
            Check_FallbackAllowed = IsValue(.IsFallbackAllowed)
            Check_AutoFallback = IsValue(.IsAutoFallbackAllowed)
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

Private Function GetDays(days As Integer) As String
    Dim dayStr As String
    
    If (days & 1) Then dayStr = dayStr + "Sun,"
    If (days & 2) Then dayStr = dayStr + "Mon,"
    If (days & 4) Then dayStr = dayStr + "Tue,"
    If (days & 8) Then dayStr = dayStr + "Wed,"
    If (days & 16) Then dayStr = dayStr + "Thu,"
    If (days & 32) Then dayStr = dayStr + "Fri,"
    If (days & 64) Then dayStr = dayStr + "Sat,"
    
    If (Len(dayStr) > 0) Then dayStr = Left(dayStr, Len(dayStr) - 1)
    GetDays = dayStr
End Function

Private Sub Frame1_DragDrop(Source As Control, X As Single, Y As Single)

End Sub

Private Sub OKButton_Click()
    Unload Me
End Sub

