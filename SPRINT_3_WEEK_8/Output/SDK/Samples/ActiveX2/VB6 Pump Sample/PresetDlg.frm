VERSION 5.00
Begin VB.Form PresetDlg 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "PresetDlg"
   ClientHeight    =   3510
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   5190
   Icon            =   "PresetDlg.frx":0000
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3510
   ScaleWidth      =   5190
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.CheckBox AllHosesCheck 
      Caption         =   "Allow All Hoses"
      Height          =   255
      Left            =   240
      TabIndex        =   11
      Top             =   2880
      Width           =   2415
   End
   Begin VB.Frame PriceLevelFrame 
      Caption         =   "Price Level"
      Height          =   975
      Left            =   120
      TabIndex        =   10
      Top             =   1800
      Width           =   2535
      Begin VB.OptionButton LevelOption2 
         Caption         =   "Use level 2 price"
         Height          =   255
         Left            =   120
         TabIndex        =   5
         Top             =   600
         Width           =   2295
      End
      Begin VB.OptionButton LevelOption1 
         Caption         =   "Use level 1 price"
         Height          =   255
         Left            =   120
         TabIndex        =   4
         Top             =   240
         Width           =   2295
      End
   End
   Begin VB.Frame DeliveryLimitFrame 
      Caption         =   "Limit"
      Height          =   1335
      Left            =   120
      TabIndex        =   9
      Top             =   240
      Width           =   2535
      Begin VB.OptionButton NoLimitOption 
         Caption         =   "No Limit"
         Height          =   255
         Left            =   120
         TabIndex        =   12
         Top             =   960
         Width           =   2175
      End
      Begin VB.TextBox Limit 
         Alignment       =   1  'Right Justify
         Height          =   375
         Left            =   1320
         TabIndex        =   0
         Text            =   "10.00"
         Top             =   360
         Width           =   975
      End
      Begin VB.OptionButton VolumeOption 
         Caption         =   "Volume"
         Height          =   255
         Left            =   120
         TabIndex        =   2
         Top             =   600
         Width           =   975
      End
      Begin VB.OptionButton ValueOption 
         Caption         =   "Money"
         Height          =   255
         Left            =   120
         TabIndex        =   1
         Top             =   240
         Width           =   975
      End
   End
   Begin VB.ListBox AllowedHoseList 
      Height          =   2295
      IntegralHeight  =   0   'False
      ItemData        =   "PresetDlg.frx":05FA
      Left            =   2760
      List            =   "PresetDlg.frx":05FC
      Style           =   1  'Checkbox
      TabIndex        =   3
      Top             =   480
      Width           =   2295
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   2760
      TabIndex        =   6
      Top             =   2880
      Width           =   1095
   End
   Begin VB.CommandButton CancelButton 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   3960
      TabIndex        =   7
      Top             =   2880
      Width           =   1095
   End
   Begin VB.Label AllowedProductsLabel 
      Caption         =   "Allowed Hoses"
      Height          =   255
      Left            =   2760
      TabIndex        =   8
      Top             =   120
      Width           =   1575
   End
End
Attribute VB_Name = "PresetDlg"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'*****************************************************************
'*
'* Copyright (C) 1997-2003 Integration Technologies Limited
'* All rights reserved.
'*
'* Created 01/06/1997
'*
'* This dialog is an example of how to apply a limit to a post pay
'* sale - in other words a Preset Limit.
'*
'******************************************************************

Option Explicit

Public PresetPump As Integer

Private Sub AllHosesCheck_Click()
    AllowedHoseList.Enabled = AllHosesCheck.Value <> vbChecked
End Sub

Private Sub CancelButton_Click()
    Hide
End Sub

'******************************************************************
'*
'*  Form_Activate - form activate event, initialise the prepay dialog
'*
'******************************************************************
Private Sub Form_Activate()

Dim result As Integer
Dim i As Integer

    ' load the hose listbox with all the names of the grades on
    ' each of this pump's hoses
    AllowedHoseList.Clear
    With MainForm.Pump(PresetPump)
        For i = 1 To .NumberOfHoses
            AllowedHoseList.AddItem .Hose(i).grade.name
            
            ' select all hoses by default
            AllowedHoseList.Selected(i - 1) = True ' listbox is zero based
        Next i
    End With
    
    Caption = "Preset authorisation on pump " & PresetPump
    'ValueOption.Value = True
    'LevelOption1.Value = True
    
End Sub

'******************************************************************
'*
'*  Form_Load - processing when the form is created
'*
'******************************************************************
Private Sub Form_Load()
    
    ValueOption.Value = True
    LevelOption1.Value = True
    
End Sub

Private Sub ValueOption_Click()
    UpdateLimitControls
End Sub

Private Sub VolumeOption_Click()
    UpdateLimitControls
End Sub

Private Sub NoLimitOption_Click()
    UpdateLimitControls
End Sub

Private Sub UpdateLimitControls()

    If NoLimitOption.Value Then
        Limit.Enabled = False
    Else
        Limit.Enabled = True
    End If

End Sub

'******************************************************************
'*
'*  Click event for the okay button, this is clicked
'*  by the user when the hose and amount have been entered
'*
'******************************************************************
Private Sub OkButton_Click()
    
Dim Desc As String
Dim Value As Currency
Dim result As Integer
Dim AllowedHoses As Integer
Dim i As Integer
Dim PriceLevel As Integer
Dim LimitType As Integer
    
    ' check that the limit is a valid number
    On Error GoTo bad_limit
    Value = CCur(Limit.Text)
        
    ' based on the checked products in the listbox, build a 'bitmap' of the allowed
    ' hoses for this preset
    If AllHosesCheck.Value = vbChecked Then
        AllowedHoses = 255 ' all hoses
    Else
        AllowedHoses = GetHoseBitmap(AllowedHoseList)
    End If
    
    ' make sure they have selected at least one product
    If AllowedHoses = 0 Then
        MsgBox "Please select one or more products", vbExclamation
        Exit Sub
    End If
    
    ' figure out which price level to use
    If LevelOption1.Value = True Then
        PriceLevel = 1
    Else
        PriceLevel = 2
    End If
    
    If ValueOption.Value Then
        LimitType = VALUE_PRESET_LIMIT ' money preset
    ElseIf VolumeOption.Value Then
        LimitType = VOLUME_PRESET_LIMIT
    Else '  NoLimitOption.Value
        LimitType = NO_LIMIT '
    End If
    
    ' do preset authorisation on pump
    result = MainForm.Pump(PresetPump).AuthorisePreset(LimitType, Value, PriceLevel, AllowedHoses)
    
    ' check result, if not Okay then display error string
    ' as retrieved from the Enabler SessionX object
    If result <> OK_RESULT Then
        MsgBox MainForm.Session.ResultString(result) + " (" + Format(result) + ")", vbExclamation
        Exit Sub
    End If
    
    Hide
    Exit Sub
    
' trap the invalid pump number error
bad_limit:
    MsgBox "Invalid preset limit, please re-enter.", vbExclamation
    Limit.SetFocus
    
End Sub

