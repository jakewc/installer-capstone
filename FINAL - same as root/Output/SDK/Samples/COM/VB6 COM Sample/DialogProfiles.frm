VERSION 5.00
Begin VB.Form DialogProfiles 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Dialog Profiles"
   ClientHeight    =   6825
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   5820
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   6825
   ScaleWidth      =   5820
   ShowInTaskbar   =   0   'False
   Begin VB.Frame Frame1 
      Caption         =   "Selected Profile"
      Height          =   5775
      Left            =   240
      TabIndex        =   3
      Top             =   840
      Width           =   5415
      Begin VB.TextBox Text_MaxStackSize 
         Enabled         =   0   'False
         Height          =   285
         Left            =   2400
         TabIndex        =   31
         Text            =   "0"
         Top             =   3240
         Visible         =   0   'False
         Width           =   855
      End
      Begin VB.CheckBox Check_FallbackAllowed 
         Enabled         =   0   'False
         Height          =   255
         Left            =   2400
         TabIndex        =   27
         Top             =   5040
         Width           =   1335
      End
      Begin VB.CheckBox Check_AutoFallback 
         Enabled         =   0   'False
         Height          =   255
         Left            =   2400
         TabIndex        =   26
         Top             =   5400
         Width           =   1335
      End
      Begin VB.TextBox Text_StartTime 
         Enabled         =   0   'False
         Height          =   285
         Left            =   2400
         TabIndex        =   25
         Text            =   "Text1"
         Top             =   1320
         Width           =   2535
      End
      Begin VB.TextBox Text_Alloweddays 
         Enabled         =   0   'False
         Height          =   285
         Left            =   2400
         TabIndex        =   24
         Text            =   "Text1"
         Top             =   960
         Width           =   2535
      End
      Begin VB.CheckBox Check_LightsOn 
         Enabled         =   0   'False
         Height          =   255
         Left            =   2400
         TabIndex        =   23
         Top             =   4680
         Width           =   1335
      End
      Begin VB.CheckBox Check_AutoAuthorise 
         Enabled         =   0   'False
         Height          =   255
         Left            =   2400
         TabIndex        =   19
         Top             =   2160
         Width           =   1335
      End
      Begin VB.CheckBox Check_AutoStack 
         Enabled         =   0   'False
         Height          =   255
         Left            =   2400
         TabIndex        =   18
         Top             =   2520
         Width           =   1335
      End
      Begin VB.CheckBox Check_Monitor 
         Enabled         =   0   'False
         Height          =   255
         Left            =   2400
         TabIndex        =   17
         Top             =   2880
         Width           =   1335
      End
      Begin VB.CheckBox Check_Stacking 
         Enabled         =   0   'False
         Height          =   255
         Left            =   2400
         TabIndex        =   16
         Top             =   3600
         Width           =   1335
      End
      Begin VB.CheckBox Check_SimpleAuth 
         Enabled         =   0   'False
         Height          =   255
         Left            =   2400
         TabIndex        =   15
         Top             =   3960
         Width           =   1335
      End
      Begin VB.CheckBox Check_ReserveAuth 
         Enabled         =   0   'False
         Height          =   255
         Left            =   2400
         TabIndex        =   14
         Top             =   4320
         Width           =   1335
      End
      Begin VB.CheckBox Check_AttendantsAllowed 
         Enabled         =   0   'False
         Height          =   255
         Left            =   2400
         TabIndex        =   9
         Top             =   1800
         Width           =   1335
      End
      Begin VB.TextBox Text_Name 
         Enabled         =   0   'False
         Height          =   285
         Left            =   2400
         TabIndex        =   5
         Text            =   "Text1"
         Top             =   600
         Width           =   2535
      End
      Begin VB.Label Label15 
         Caption         =   "Max Stack Size :"
         Height          =   255
         Left            =   360
         TabIndex        =   30
         Top             =   3240
         Visible         =   0   'False
         Width           =   1695
      End
      Begin VB.Label Label14 
         Caption         =   "Fallback Allowed:"
         Height          =   375
         Left            =   360
         TabIndex        =   29
         Top             =   5040
         Width           =   2055
      End
      Begin VB.Label Label13 
         Caption         =   "Automatic Fallback:"
         Height          =   375
         Left            =   360
         TabIndex        =   28
         Top             =   5400
         Width           =   2055
      End
      Begin VB.Label Label12 
         Caption         =   "Start Time:"
         Height          =   375
         Left            =   360
         TabIndex        =   22
         Top             =   1320
         Width           =   2055
      End
      Begin VB.Label Label11 
         Caption         =   "Allowd Days"
         Height          =   375
         Left            =   360
         TabIndex        =   21
         Top             =   960
         Width           =   2055
      End
      Begin VB.Label Label10 
         Caption         =   "Lights On:"
         Height          =   375
         Left            =   360
         TabIndex        =   20
         Top             =   4680
         Width           =   2055
      End
      Begin VB.Label Label9 
         Caption         =   "Reserve Authorise Allowed:"
         Height          =   375
         Left            =   360
         TabIndex        =   13
         Top             =   4320
         Width           =   2295
      End
      Begin VB.Label Label8 
         Caption         =   "Simple Authorise Allowed:"
         Height          =   375
         Left            =   360
         TabIndex        =   12
         Top             =   3960
         Width           =   2055
      End
      Begin VB.Label Label7 
         Caption         =   "Stacking Allowed:"
         Height          =   255
         Left            =   360
         TabIndex        =   11
         Top             =   3600
         Width           =   1695
      End
      Begin VB.Label Label6 
         Caption         =   "Monitor:"
         Height          =   255
         Left            =   360
         TabIndex        =   10
         Top             =   2880
         Width           =   1695
      End
      Begin VB.Label Label5 
         Caption         =   "Auto Stack:"
         Height          =   255
         Left            =   360
         TabIndex        =   8
         Top             =   2520
         Width           =   1695
      End
      Begin VB.Label Label4 
         Caption         =   "Auto Authorise"
         Height          =   255
         Left            =   360
         TabIndex        =   7
         Top             =   2160
         Width           =   1695
      End
      Begin VB.Label Label3 
         Caption         =   "Attendants Allowed:"
         Height          =   255
         Left            =   360
         TabIndex        =   6
         Top             =   1800
         Width           =   1575
      End
      Begin VB.Label Label2 
         Caption         =   "Name:"
         Height          =   255
         Left            =   360
         TabIndex        =   4
         Top             =   600
         Width           =   1215
      End
   End
   Begin VB.ComboBox Combo_profiles 
      Height          =   315
      Left            =   1800
      TabIndex        =   1
      Text            =   "Combo1"
      Top             =   240
      Width           =   2295
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "Close"
      Height          =   375
      Left            =   4440
      TabIndex        =   0
      Top             =   240
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Select site profile:"
      Height          =   375
      Left            =   360
      TabIndex        =   2
      Top             =   240
      Width           =   1455
   End
End
Attribute VB_Name = "DialogProfiles"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'**************************************************
' Profiles Dialog
' Copyright 2013 Integration Technologies Ltd
'
' Select site profile
' Show details of selected profile
'**************************************************
Option Explicit

Private CurProfile As Profile

Private Sub Combo_profiles_Click()
    ShowProfileDetail
End Sub


Private Sub Form_Load()
    Dim profileX As Profile
    Dim curIndex As Integer
    
    With FormMain.myforecourt
        
        curIndex = 0
        For Each profileX In .SiteProfiles
            Combo_profiles.AddItem Format(profileX.Id) + "\" + profileX.name
            
            If profileX.Id = .CurrentMode.Id Then
                Combo_profiles.ListIndex = curIndex
            End If
            
            curIndex = curIndex + 1
        Next
        
    End With
        
    ShowProfileDetail
        
End Sub

Private Sub ShowProfileDetail()
    Dim max As Integer
    
    Set CurProfile = FormMain.myforecourt.SiteProfiles.GetByIndex(Combo_profiles.ListIndex)

    If (Not CurProfile Is Nothing) Then
        With CurProfile
            Text_name = .name
            Text_Alloweddays = GetDays(.AllowedDays)
            Text_StartTime = FormatDateTime(.StartTime / 1440, vbShortTime)
            
            Check_AttendantsAllowed = IsValue(.IsAttendantsAllowed)
            Check_AutoAuthorise = IsValue(.IsAutoAuthorise)
            Check_AutoStack = IsValue(.IsAutoStack)
            'Text_MaxStackSize = Format(.MaxStackSize)
            Check_Monitor = IsValue(.IsMonitor)
            Check_Stacking = IsValue(.IsStackingAllowed)
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
    
    If (days And 1) Then dayStr = dayStr + "Sun,"
    If (days And 2) Then dayStr = dayStr + "Mon,"
    If (days And 4) Then dayStr = dayStr + "Tue,"
    If (days And 8) Then dayStr = dayStr + "Wed,"
    If (days And 16) Then dayStr = dayStr + "Thu,"
    If (days And 32) Then dayStr = dayStr + "Fri,"
    If (days And 64) Then dayStr = dayStr + "Sat,"
    
    If (Len(dayStr) > 0) Then dayStr = Left(dayStr, Len(dayStr) - 1)
    GetDays = dayStr
End Function


Private Sub OKButton_Click()
    Unload Me
End Sub
