VERSION 5.00
Begin VB.Form DialogPumps 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Pumps"
   ClientHeight    =   8940
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   10380
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   8940
   ScaleWidth      =   10380
   ShowInTaskbar   =   0   'False
   Begin VB.CommandButton Command_showProfile 
      Caption         =   "Show profile"
      Enabled         =   0   'False
      Height          =   375
      Left            =   6600
      TabIndex        =   54
      Top             =   120
      Width           =   1455
   End
   Begin VB.Frame Frame1 
      Caption         =   "Pump details"
      Height          =   8175
      Left            =   240
      TabIndex        =   3
      Top             =   600
      Width           =   9975
      Begin VB.CommandButton Command_setDisplayText 
         Caption         =   "Set"
         Height          =   255
         Left            =   3360
         TabIndex        =   75
         Top             =   1440
         Width           =   615
      End
      Begin VB.TextBox Text_Displaytext 
         Height          =   285
         Left            =   1920
         TabIndex        =   73
         Top             =   1440
         Width           =   1335
      End
      Begin VB.CheckBox Check_flow 
         Caption         =   "Flow on"
         Enabled         =   0   'False
         Height          =   255
         Left            =   1920
         TabIndex        =   72
         Top             =   3720
         Width           =   1695
      End
      Begin VB.CheckBox Check_stopblock 
         Caption         =   "Stop block"
         Enabled         =   0   'False
         Height          =   255
         Left            =   1920
         TabIndex        =   70
         Top             =   3000
         Width           =   1695
      End
      Begin VB.ComboBox Combo_pricelevel2 
         Height          =   315
         Left            =   4440
         TabIndex        =   66
         Text            =   "Combo1"
         Top             =   6690
         Width           =   615
      End
      Begin VB.CommandButton Command_setPricelevel2 
         Caption         =   "Set"
         Height          =   255
         Left            =   5040
         TabIndex        =   65
         Top             =   6720
         Width           =   615
      End
      Begin VB.ComboBox Combo_pricelevel1 
         Height          =   315
         Left            =   1920
         TabIndex        =   64
         Text            =   "Combo1"
         Top             =   6690
         Width           =   615
      End
      Begin VB.CommandButton Command_setPricelevel1 
         Caption         =   "Set"
         Height          =   255
         Left            =   2520
         TabIndex        =   62
         Top             =   6720
         Width           =   615
      End
      Begin VB.CheckBox Check_pump_user 
         Caption         =   "User"
         Enabled         =   0   'False
         Height          =   255
         Left            =   1920
         TabIndex        =   60
         Top             =   2520
         Width           =   1335
      End
      Begin VB.CheckBox Check_pump_allhoses 
         Caption         =   "All hoses blocked"
         Enabled         =   0   'False
         Height          =   255
         Left            =   1920
         TabIndex        =   59
         Top             =   2760
         Width           =   1695
      End
      Begin VB.CommandButton Command_showHoses 
         Caption         =   "Show hoses"
         Height          =   375
         Left            =   240
         TabIndex        =   45
         Top             =   7680
         Width           =   1695
      End
      Begin VB.Frame Frame2 
         Caption         =   "Authorise limits"
         Height          =   5775
         Left            =   5880
         TabIndex        =   41
         Top             =   1320
         Width           =   3735
         Begin VB.ComboBox Combo_Attendant 
            Height          =   315
            Left            =   1560
            TabIndex        =   68
            Text            =   "Combo1"
            Top             =   4800
            Width           =   1935
         End
         Begin VB.ComboBox Combo_FuelTimeout 
            Height          =   315
            Left            =   1560
            TabIndex        =   58
            Text            =   "Combo1"
            Top             =   4200
            Width           =   1935
         End
         Begin VB.ComboBox Combo_AuthTimeout 
            Height          =   315
            Left            =   1560
            TabIndex        =   56
            Text            =   "Combo1"
            Top             =   3810
            Width           =   1935
         End
         Begin VB.OptionButton Option_none 
            Alignment       =   1  'Right Justify
            Caption         =   "No limit"
            Height          =   255
            Left            =   120
            TabIndex        =   53
            Top             =   840
            Value           =   -1  'True
            Width           =   1695
         End
         Begin VB.OptionButton Option_quantity 
            Alignment       =   1  'Right Justify
            Caption         =   "Limit by Quantity"
            Height          =   255
            Left            =   120
            TabIndex        =   52
            Top             =   600
            Width           =   1695
         End
         Begin VB.OptionButton Option_value 
            Alignment       =   1  'Right Justify
            Caption         =   "Limit by Value"
            Height          =   255
            Left            =   120
            TabIndex        =   51
            Top             =   360
            Width           =   1695
         End
         Begin VB.ComboBox Combo_pricelevels 
            Height          =   315
            Left            =   1560
            TabIndex        =   49
            Text            =   "Combo1"
            Top             =   3480
            Width           =   1935
         End
         Begin VB.CommandButton Command_Authorise 
            Caption         =   "Authorise"
            Height          =   375
            Left            =   120
            TabIndex        =   48
            Top             =   5280
            Width           =   1695
         End
         Begin VB.CommandButton Command_cancelAuthorise 
            Caption         =   "Cancel Authorise"
            Height          =   375
            Left            =   1920
            TabIndex        =   47
            Top             =   5280
            Width           =   1695
         End
         Begin VB.CheckBox Check_AllProducts 
            Caption         =   "All or selected products"
            Height          =   255
            Left            =   240
            TabIndex        =   46
            Top             =   1200
            Value           =   1  'Checked
            Width           =   2175
         End
         Begin VB.ListBox List_products 
            Columns         =   1
            Enabled         =   0   'False
            Height          =   1635
            Left            =   120
            Style           =   1  'Checkbox
            TabIndex        =   44
            Top             =   1440
            Width           =   3375
         End
         Begin VB.TextBox Text_valuelimit 
            Enabled         =   0   'False
            Height          =   285
            Left            =   2160
            TabIndex        =   42
            Text            =   "10"
            Top             =   600
            Width           =   1335
         End
         Begin VB.Label Label21 
            Caption         =   "Attendant :"
            Height          =   255
            Left            =   240
            TabIndex        =   69
            Top             =   4800
            Width           =   1335
         End
         Begin VB.Label Label18 
            Caption         =   "Fuelling Timeout :"
            Height          =   255
            Left            =   240
            TabIndex        =   57
            Top             =   4200
            Width           =   1335
         End
         Begin VB.Label Label7 
            Caption         =   "Authorise Timeout :"
            Height          =   255
            Left            =   240
            TabIndex        =   55
            Top             =   3840
            Width           =   1455
         End
         Begin VB.Label Label17 
            Caption         =   "Price level :"
            Height          =   255
            Left            =   240
            TabIndex        =   50
            Top             =   3480
            Width           =   1095
         End
         Begin VB.Label Label10 
            Caption         =   "Limit :"
            Height          =   375
            Left            =   2160
            TabIndex        =   43
            Top             =   360
            Width           =   615
         End
      End
      Begin VB.CommandButton Command_ShowStackedTrans 
         Caption         =   "Show"
         Height          =   255
         Left            =   5040
         TabIndex        =   40
         Top             =   5160
         Width           =   615
      End
      Begin VB.CommandButton Command_showTransactrion 
         Caption         =   "Show"
         Height          =   255
         Left            =   5040
         TabIndex        =   39
         Top             =   4800
         Width           =   615
      End
      Begin VB.CommandButton Command_showAttendant 
         Caption         =   "Show"
         Height          =   255
         Left            =   3360
         TabIndex        =   38
         Top             =   1800
         Width           =   615
      End
      Begin VB.CommandButton Command_Stop 
         Caption         =   "Stop"
         Height          =   375
         Left            =   2160
         TabIndex        =   37
         Top             =   7680
         Width           =   1695
      End
      Begin VB.CommandButton Command_resume 
         Caption         =   "Resume"
         Height          =   375
         Left            =   3960
         TabIndex        =   36
         Top             =   7200
         Width           =   1695
      End
      Begin VB.CommandButton Command_pause 
         Caption         =   "Pause"
         Height          =   375
         Left            =   2160
         TabIndex        =   35
         Top             =   7200
         Width           =   1695
      End
      Begin VB.CommandButton Command_unblock 
         Caption         =   "Unblock"
         Height          =   375
         Left            =   7920
         TabIndex        =   34
         Top             =   360
         Width           =   1695
      End
      Begin VB.CommandButton Command_block 
         Caption         =   "Block"
         Height          =   375
         Left            =   6120
         TabIndex        =   33
         Top             =   360
         Width           =   1695
      End
      Begin VB.CommandButton Command_reserve 
         Caption         =   "Reserve"
         Height          =   375
         Left            =   6120
         TabIndex        =   32
         Top             =   840
         Width           =   1695
      End
      Begin VB.CommandButton Command_cancelReserve 
         Caption         =   "Cancel reserve"
         Height          =   375
         Left            =   7920
         TabIndex        =   31
         Top             =   840
         Width           =   1695
      End
      Begin VB.CommandButton Command_stack 
         Caption         =   "Stack current"
         Height          =   375
         Left            =   3960
         TabIndex        =   30
         Top             =   7680
         Width           =   1695
      End
      Begin VB.TextBox Text_hoseState 
         Enabled         =   0   'False
         Height          =   285
         Left            =   1920
         TabIndex        =   28
         Text            =   "Text2"
         Top             =   6240
         Width           =   1335
      End
      Begin VB.CheckBox Check_pumplights 
         Enabled         =   0   'False
         Height          =   315
         Left            =   1920
         TabIndex        =   26
         Top             =   5850
         Width           =   1335
      End
      Begin VB.TextBox Text_state 
         Enabled         =   0   'False
         Height          =   285
         Left            =   1920
         TabIndex        =   24
         Text            =   "Text2"
         Top             =   5520
         Width           =   1335
      End
      Begin VB.ComboBox Combo_transStack 
         Enabled         =   0   'False
         Height          =   315
         Left            =   1920
         TabIndex        =   22
         Text            =   "Combo1"
         Top             =   5160
         Width           =   3015
      End
      Begin VB.TextBox Text_pricechangeStatus 
         Enabled         =   0   'False
         Height          =   285
         Left            =   1920
         TabIndex        =   20
         Text            =   "Text2"
         Top             =   4440
         Width           =   1335
      End
      Begin VB.CheckBox Check_isTransaction 
         Enabled         =   0   'False
         Height          =   315
         Left            =   1920
         TabIndex        =   18
         Top             =   4080
         Width           =   1335
      End
      Begin VB.TextBox Text_currentTransaction 
         Enabled         =   0   'False
         Height          =   285
         Left            =   1920
         TabIndex        =   16
         Text            =   "Text2"
         Top             =   4800
         Width           =   3015
      End
      Begin VB.TextBox Text_currentHose 
         Enabled         =   0   'False
         Height          =   285
         Left            =   1920
         TabIndex        =   14
         Text            =   "Text2"
         Top             =   3360
         Width           =   1335
      End
      Begin VB.TextBox Text_attendant 
         Enabled         =   0   'False
         Height          =   285
         Left            =   1920
         TabIndex        =   12
         Text            =   "Text2"
         Top             =   1800
         Width           =   1335
      End
      Begin VB.CheckBox Check_IsBlocked 
         Enabled         =   0   'False
         Height          =   315
         Left            =   1920
         TabIndex        =   10
         Top             =   2160
         Width           =   1335
      End
      Begin VB.TextBox Text_name 
         Enabled         =   0   'False
         Height          =   285
         Left            =   1920
         TabIndex        =   8
         Text            =   "Text2"
         Top             =   1080
         Width           =   1335
      End
      Begin VB.TextBox Text_id 
         Enabled         =   0   'False
         Height          =   285
         Left            =   1920
         TabIndex        =   5
         Text            =   "Text1"
         Top             =   360
         Width           =   1335
      End
      Begin VB.TextBox Text_number 
         Enabled         =   0   'False
         Height          =   285
         Left            =   1920
         TabIndex        =   4
         Text            =   "Text2"
         Top             =   720
         Width           =   1335
      End
      Begin VB.Label Label23 
         Caption         =   "DisplayText:"
         Height          =   255
         Left            =   240
         TabIndex        =   74
         Top             =   1440
         Width           =   1095
      End
      Begin VB.Label Label22 
         Caption         =   "Flow:"
         Height          =   255
         Left            =   240
         TabIndex        =   71
         Top             =   3720
         Width           =   1455
      End
      Begin VB.Label Label20 
         Caption         =   "Price Level 2:"
         Height          =   255
         Left            =   3360
         TabIndex        =   67
         Top             =   6720
         Width           =   975
      End
      Begin VB.Label Label19 
         Caption         =   "Price Level 1:"
         Height          =   255
         Left            =   240
         TabIndex        =   63
         Top             =   6720
         Width           =   1575
      End
      Begin VB.Label Label26 
         Caption         =   "Block reasons:"
         Height          =   255
         Left            =   240
         TabIndex        =   61
         Top             =   2520
         Width           =   1455
      End
      Begin VB.Label Label16 
         Caption         =   "Hose state:"
         Height          =   255
         Left            =   240
         TabIndex        =   29
         Top             =   6240
         Width           =   1455
      End
      Begin VB.Label Label15 
         Caption         =   "Pump Lights On:"
         Height          =   255
         Left            =   240
         TabIndex        =   27
         Top             =   5880
         Width           =   1695
      End
      Begin VB.Label Label14 
         Caption         =   "Pump state:"
         Height          =   255
         Left            =   240
         TabIndex        =   25
         Top             =   5520
         Width           =   1455
      End
      Begin VB.Label Label13 
         Caption         =   "Transaction stack:"
         Height          =   255
         Left            =   240
         TabIndex        =   23
         Top             =   5160
         Width           =   1455
      End
      Begin VB.Label Label12 
         Caption         =   "Price change status:"
         Height          =   255
         Left            =   240
         TabIndex        =   21
         Top             =   4440
         Width           =   1455
      End
      Begin VB.Label Label11 
         Caption         =   "Is Current Transaction:"
         Height          =   375
         Left            =   240
         TabIndex        =   19
         Top             =   4080
         Width           =   1935
      End
      Begin VB.Label Label9 
         Caption         =   "Current Transaction:"
         Height          =   255
         Left            =   240
         TabIndex        =   17
         Top             =   4800
         Width           =   1455
      End
      Begin VB.Label Label8 
         Caption         =   "Current Hose:"
         Height          =   255
         Left            =   240
         TabIndex        =   15
         Top             =   3360
         Width           =   1095
      End
      Begin VB.Label Label6 
         Caption         =   "Attendant:"
         Height          =   255
         Left            =   240
         TabIndex        =   13
         Top             =   1800
         Width           =   1095
      End
      Begin VB.Label Label5 
         Caption         =   "IsBlocked:"
         Height          =   255
         Left            =   240
         TabIndex        =   11
         Top             =   2160
         Width           =   735
      End
      Begin VB.Label Label3 
         Caption         =   "Name:"
         Height          =   255
         Left            =   240
         TabIndex        =   9
         Top             =   1080
         Width           =   1095
      End
      Begin VB.Label Label2 
         Caption         =   "Id:"
         Height          =   255
         Left            =   240
         TabIndex        =   7
         Top             =   360
         Width           =   855
      End
      Begin VB.Label Label4 
         Caption         =   "Number:"
         Height          =   255
         Left            =   240
         TabIndex        =   6
         Top             =   720
         Width           =   1095
      End
   End
   Begin VB.ComboBox Combo_pumps 
      Height          =   315
      Left            =   1560
      TabIndex        =   1
      Text            =   "No Pumps"
      Top             =   120
      Width           =   2775
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "Close"
      Height          =   375
      Left            =   8520
      TabIndex        =   0
      Top             =   120
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Select pump:"
      Height          =   375
      Left            =   240
      TabIndex        =   2
      Top             =   120
      Width           =   1095
   End
End
Attribute VB_Name = "DialogPumps"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'**************************************************
' Pump Dialog
' Copyright 2013 Integration Technologies Ltd
'
' Select pump to show
' Show details of selected pump
' Show Current or stacked transactions
' Show attendant
' Show hoses
' Call methods Pause, Resume Stop, Stack, Block, Unblock, reserve, cancel reserve and cancel authorise
' Authorise a transaction with or without limits.
' Update details on events
'**************************************************

Option Explicit

Private WithEvents CurPump As Pump
Attribute CurPump.VB_VarHelpID = -1


Private Sub Check_AllProducts_Click()
    If (Check_AllProducts.value = 1) Then
        List_products.Enabled = False
    Else
         List_products.Enabled = True
    End If
End Sub

Private Sub Combo_pumps_Click()
    ShowPumpDetails
End Sub


Private Sub ShowPumpDetails()
    Dim transX As Transaction
    
    If (Combo_pumps.ListIndex < 0) Then Exit Sub
    
    Set CurPump = FormMain.myforecourt.Pumps.GetByIndex(Combo_pumps.ListIndex)
    If (Not CurPump Is Nothing) Then
        With CurPump
            Text_id.text = Format(.Id)
            Text_number = Format(.number)
            Text_name = .name
            Command_setDisplayText.Enabled = False
            
            On Error Resume Next    'handle using old API
            Text_Displaytext.text = .DisplayText
            On Error GoTo 0         'normal error handling
            
            If (.Attendant Is Nothing) Then
                Text_attendant = "None"
                Command_showAttendant.Enabled = False
            Else
                Text_attendant = .Attendant.name
                Command_showAttendant.Enabled = True
            End If
            
            If (.IsBlocked) Then
                Check_IsBlocked.value = 1
            Else
                Check_IsBlocked.value = 0
            End If
            
            Check_pump_user.value = BlockReasonCheckValue(.BlockedReasons, PumpBlockedReasons_Manual)
            Check_pump_allhoses.value = BlockReasonCheckValue(.BlockedReasons, PumpBlockedReasons_AllHosesBlocked)
            Check_stopblock.value = BlockReasonCheckValue(.BlockedReasons, PumpBlockedReasons_Stopped)
            
            If (.CurrentHose Is Nothing) Then
                Text_currentHose = "None"
            Else
                Text_currentHose = Format(.CurrentHose.number) + "\" + .CurrentHose.Grade.name
            End If
            
            If .FuelFlow Then
                Check_flow.value = 1
            Else
                Check_flow.value = 0
            End If
            
            If (.CurrentTransaction Is Nothing) Then
                Text_currentTransaction = "None"
                Command_showTransactrion.Enabled = False
            Else
                Text_currentTransaction = "Id:" + Format(.CurrentTransaction.Id) + " Val:" + FormatCurrency(.CurrentTransaction.DeliveryData.Money) + " Vol:" + FormatCurrency(.CurrentTransaction.DeliveryData.Quantity)
                Command_showTransactrion.Enabled = True
            End If
            
            If (.IsCurrentTransaction) Then
                Check_isTransaction.value = 1
            Else
                Check_isTransaction.value = 0
            End If
            
            Select Case .PriceChangeStatus
                Case PriceChangeStatus_Failed
                    Text_pricechangeStatus = "Failed"
                Case PriceChangeStatus_Idle
                    Text_pricechangeStatus = "Idle"
                Case PriceChangeStatus_InvalidPrice
                    Text_pricechangeStatus = "InvalidPrice"
                Case PriceChangeStatus_Pending
                    Text_pricechangeStatus = "Pending"
                Case PriceChangeStatus_Running
                    Text_pricechangeStatus = "Running"
            End Select
            
            Combo_transStack.Clear
            For Each transX In .TransactionStack
                Combo_transStack.AddItem "Id:" + Format(transX.Id) + " Val:" + FormatCurrency(transX.DeliveryData.Money) + " Vol:" + FormatCurrency(transX.DeliveryData.Quantity)
            Next
            If (.TransactionStack.Count > 0) Then Combo_transStack.ListIndex = 0
            
            Text_state = .GetPumpStateString(.State)
            
            If (.PumpLightsOn) Then
                Check_pumplights.value = 1
            Else
                Check_pumplights.value = 0
            End If

            If (.CurrentHose Is Nothing) Then
                Text_hoseState = "Replaced"
            Else
                Text_hoseState = "Lifted"
            End If
            
            If (Combo_pricelevel1.ListCount >= .GetPriceLevelMapping(1)) Then
                Combo_pricelevel1.ListIndex = .GetPriceLevelMapping(1) - 1
            End If
            
            If (Combo_pricelevel2.ListCount >= .GetPriceLevelMapping(2)) Then
                Combo_pricelevel2.ListIndex = .GetPriceLevelMapping(2) - 1
            End If
            
            
        End With
    End If
End Sub

Private Function BlockReasonCheckValue(reason As Integer, mask As Integer) As Integer
    If ((reason And mask) > 0) Then
        BlockReasonCheckValue = 1
    Else
        BlockReasonCheckValue = 0
    End If
End Function

Private Function FindPumpId() As Integer
    Dim logonPump As Pump
    
    Set CurPump = FormMain.myforecourt.Pumps.GetByIndex(Combo_pumps.ListIndex)
    FindPumpId = CurPump.Id
End Function

Private Sub Text_Displaytext_Change()
    Command_setDisplayText.Enabled = True
End Sub

Private Sub Command_setDisplayText_Click()
    On Error Resume Next
    CurPump.DisplayText = Text_Displaytext.text & "" 'handle empty string
    On Error GoTo 0
End Sub

Private Sub Command_setPricelevel1_Click()
  CurPump.SetPriceLevelMapping 1, Combo_pricelevel1.ListIndex + 1
End Sub

Private Sub Command_setPricelevel2_Click()
  CurPump.SetPriceLevelMapping 2, Combo_pricelevel2.ListIndex + 1
End Sub

Private Sub Command_showAttendant_Click()
    DialogAttendants.Show vbModal, DialogPumps
End Sub

Private Sub Command_showHoses_Click()
    Dim Dlg As DialogHoses
    
    Set Dlg = New DialogHoses
    Dlg.SetPump CurPump
    Dlg.Show vbModeless
End Sub

Private Sub Command_showProfile_Click()
    Dim Dlg As DialogPumpProfile
    
    Set Dlg = New DialogPumpProfile
    Dlg.SetPump CurPump
    Dlg.Show vbModal
    
End Sub

Private Sub Command_ShowStackedTrans_Click()
    Dim Dlg As DialogTransaction
    
    Set Dlg = New DialogTransaction
    Dlg.SetPump CurPump, 0
    Dlg.Show vbModal
End Sub

Private Sub Command_showTransactrion_Click()
    Dim Dlg As DialogTransaction
    
    Set Dlg = New DialogTransaction
    Dlg.SetPump CurPump, 1
    Dlg.Show vbModal
End Sub

Private Sub Command_Stop_Click()
  DoCommand "Stop", CurPump.Stop
End Sub

Private Sub Command_unblock_Click()
  DoCommand "Unblock", CurPump.SetBlock(False, "")
End Sub

Private Sub Command_Authorise_Click()
  DoAuthorise
End Sub

Private Sub DoAuthorise()
  
  Dim Limits As PumpAuthoriseLimits
  Dim AuthoriseTimeout As Integer
  Dim FuellingTimeout As Integer
  Dim AuthAttendantID As Integer
  
  
  On Error GoTo limitError
  
  ' Default is no limit, All products, price level = 1
  Set Limits = New PumpAuthoriseLimits
  
  If (Option_value = True) Then
    ' Authorise by value
    Limits.value = CCur(Text_valuelimit)
  ElseIf (Option_quantity = True) Then
    ' Authorise by quantity
    Limits.Quantity = CCur(Text_valuelimit)
  End If
  
  If (Check_AllProducts <> 1) Then
    Dim index As Integer
    For index = 0 To List_products.ListCount
        If (List_products.Selected(index) = True) Then
            Limits.Products.Add (List_products.ItemData(index))
        End If
    Next
    
  End If
  
  ' Set price level
  Limits.level = Combo_pricelevels.ListIndex + 1
  
  Limits.AuthoriseTimeout = Combo_AuthTimeout.ListIndex * 30
  Limits.FuellingTimeout = Combo_FuelTimeout.ListIndex * 30
  
  AuthAttendantID = -1
  If (Combo_Attendant.ListIndex > 0) Then
    AuthAttendantID = FormMain.myforecourt.Attendants.GetByIndex(Combo_Attendant.ListIndex - 1).Id
  End If
  
  DoCommand "Authorise", CurPump.Authorise("VbTest", FormMain.GetNextRef, AuthAttendantID, Limits)
  Exit Sub
  
limitError:
  MsgBox "Invalid limit, numberic only"
End Sub

Private Sub Command_block_Click()
  DoCommand "Block", CurPump.SetBlock(True, "")
End Sub

Private Sub Command_cancelAuthorise_Click()
  DoCommand "CancelAuthorise", CurPump.CancelAuthorise
End Sub

Private Sub Command_cancelReserve_Click()
  DoCommand "CancelReserve", CurPump.CancelReserve
End Sub

Private Sub Command_pause_Click()
  DoCommand "Pause", CurPump.Pause
End Sub

Private Sub Command_reserve_Click()
  DoCommand "Reserve", CurPump.Reserve("TestReserve", "vbComTest", True)
End Sub

Private Sub Command_resume_Click()
  DoCommand "Resume", CurPump.Resume
End Sub


Private Sub Command_stack_Click()
    DoCommand "Stack", CurPump.StackCurrentTransaction
End Sub


Private Sub DoCommand(Command As String, result As ApiResult)
    If (result <> ApiResult_Ok) Then
        MsgBox Command + ":" + FormMain.myforecourt.GetResultString(result)
    End If
    ShowPumpDetails
End Sub


Private Sub CurPump_OnFuellingProgress(ByVal Pump As ITL_Enabler_API.IPump, ByVal value As Currency, ByVal volume As Currency, ByVal volume2 As Currency)
    ShowPumpDetails
End Sub

Private Sub CurPump_OnHoseEvent(ByVal Pump As ITL_Enabler_API.IPump, ByVal eventType As ITL_Enabler_API.HoseEventType, ByVal hoseNumber As Long)
    ShowPumpDetails
End Sub

Private Sub CurPump_OnPriceChange(ByVal Pump As ITL_Enabler_API.IPump)
    ShowPumpDetails
End Sub

Private Sub CurPump_OnStatusChange(ByVal Pump As ITL_Enabler_API.IPump, ByVal eventType As ITL_Enabler_API.PumpStatusEventType)
    ShowPumpDetails
End Sub

Private Sub CurPump_OnTransactionEvent(ByVal Pump As ITL_Enabler_API.IPump, ByVal eventType As ITL_Enabler_API.TransactionEventType, ByVal transactionId As Long, ByVal Transaction As ITL_Enabler_API.IFuelTransaction)
    ShowPumpDetails
End Sub

Private Sub Form_Load()
    Dim pumpX As Pump
    Dim index As Integer
    
    For Each pumpX In FormMain.myforecourt.Pumps
        Combo_pumps.AddItem Format(pumpX.number) + "\" + pumpX.name
    Next

    ShowPumpDetails
    
    Text_hoseState = "Replaced"

    ' Load all grades into allowed products
    Dim product As Grade
    For Each product In FormMain.myforecourt.Grades
        List_products.AddItem Format(product.Id) + " \ " + product.name
    Next
    
    ' Select them all
    For index = 0 To List_products.ListCount - 1
        List_products.Selected(index) = True
    Next


    Combo_pricelevels.Clear
    Combo_pricelevel1.Clear
    Combo_pricelevel2.Clear
    For index = 1 To FormMain.myforecourt.Settings.PriceLevels.Count
        Combo_pricelevel1.AddItem Format(index)
        Combo_pricelevel2.AddItem Format(index)
        Combo_pricelevels.AddItem "Price level " + Format(index)
    Next
    Combo_pricelevels.ListIndex = 0
    
    Combo_AuthTimeout.Clear
    Combo_FuelTimeout.Clear
    Combo_AuthTimeout.AddItem "System default"
    Combo_FuelTimeout.AddItem "System default"
    For index = 1 To 20
        Combo_AuthTimeout.AddItem Format(index * 30) + " secs"
        Combo_FuelTimeout.AddItem Format(index * 30) + " secs"
    Next
    Combo_AuthTimeout.ListIndex = 0
    Combo_FuelTimeout.ListIndex = 0
    
    Combo_pumps.ListIndex = 0

    
    Combo_Attendant.AddItem "None"
    
    Dim attendantX As Attendant
    For Each attendantX In FormMain.myforecourt.Attendants
        Combo_Attendant.AddItem Format(attendantX.Id) + " \ " + attendantX.name
    Next
    Combo_Attendant.ListIndex = 0
 

End Sub


Private Sub OKButton_Click()
     Unload Me
End Sub


Private Sub Option_none_Click()
    Text_valuelimit.Enabled = Not Option_none.value
End Sub

Private Sub Option_quantity_Click()
    Text_valuelimit.Enabled = Option_quantity.value
End Sub

Private Sub Option_value_Click()
    Text_valuelimit.Enabled = Option_value.value
End Sub
