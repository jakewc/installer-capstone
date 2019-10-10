VERSION 5.00
Begin VB.Form DialogTransaction 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Transactions"
   ClientHeight    =   8865
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   11955
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   8865
   ScaleWidth      =   11955
   ShowInTaskbar   =   0   'False
   Begin VB.CommandButton Command_reinstateAndLock 
      Caption         =   "Reinstate and lock"
      Height          =   495
      Left            =   1920
      TabIndex        =   82
      Top             =   7080
      Width           =   1215
   End
   Begin VB.TextBox Text_deliverytype 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1800
      TabIndex        =   78
      Top             =   5880
      Width           =   1335
   End
   Begin VB.ComboBox Combo_transactions 
      Height          =   315
      Left            =   2280
      TabIndex        =   77
      Text            =   "Combo1"
      Top             =   120
      Width           =   2775
   End
   Begin VB.ComboBox Combo_cleartype 
      Height          =   315
      Left            =   360
      TabIndex        =   75
      Text            =   "Combo1"
      Top             =   7720
      Width           =   1215
   End
   Begin VB.CommandButton Command_Releaselock 
      Caption         =   "Release lock"
      Height          =   495
      Left            =   1920
      TabIndex        =   74
      Top             =   6480
      Width           =   1215
   End
   Begin VB.CommandButton Command_reinstate 
      Caption         =   "Reinstate"
      Height          =   495
      Left            =   360
      TabIndex        =   73
      Top             =   7080
      Width           =   1215
   End
   Begin VB.CommandButton Command_clear 
      Caption         =   "Clear"
      Height          =   375
      Left            =   1920
      TabIndex        =   72
      Top             =   7680
      Width           =   1215
   End
   Begin VB.CommandButton Command_getLock 
      Caption         =   "Get Lock"
      Height          =   495
      Left            =   360
      TabIndex        =   71
      Top             =   6480
      Width           =   1215
   End
   Begin VB.Frame Frame4 
      Caption         =   "Blend data"
      Height          =   2295
      Left            =   7680
      TabIndex        =   46
      Top             =   5760
      Width           =   4095
      Begin VB.TextBox Text_bd_Ratio 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   70
         Top             =   480
         Width           =   1695
      End
      Begin VB.TextBox Text_bd_Base1 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   48
         Top             =   960
         Width           =   1695
      End
      Begin VB.TextBox Text_bd_Base2 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   47
         Top             =   1440
         Width           =   1695
      End
      Begin VB.Label Label26 
         Caption         =   "Ratio :"
         Height          =   255
         Left            =   120
         TabIndex        =   51
         Top             =   480
         Width           =   1095
      End
      Begin VB.Label Label25 
         Caption         =   "Base 1 Delivery data :"
         Height          =   255
         Left            =   120
         TabIndex        =   50
         Top             =   960
         Width           =   1815
      End
      Begin VB.Label Label24 
         Caption         =   "Base 2 Delivery data :"
         Height          =   255
         Left            =   120
         TabIndex        =   49
         Top             =   1440
         Width           =   1815
      End
   End
   Begin VB.TextBox Text_pump 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1800
      TabIndex        =   22
      Top             =   5400
      Width           =   1335
   End
   Begin VB.TextBox Text_hose 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1800
      TabIndex        =   20
      Top             =   4920
      Width           =   1335
   End
   Begin VB.Frame Frame3 
      Caption         =   "Delivery data"
      Height          =   3855
      Left            =   3480
      TabIndex        =   19
      Top             =   4200
      Width           =   4095
      Begin VB.TextBox Text_dd_QuantityTotal 
         Enabled         =   0   'False
         Height          =   405
         Left            =   1920
         TabIndex        =   60
         Top             =   3000
         Width           =   1695
      End
      Begin VB.TextBox Text_dd_MoneyTotal 
         Enabled         =   0   'False
         Height          =   405
         Left            =   1920
         TabIndex        =   58
         Top             =   2520
         Width           =   1695
      End
      Begin VB.TextBox Text_dd_Quantity 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   44
         Top             =   2040
         Width           =   1695
      End
      Begin VB.TextBox Text_dd_Money 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   42
         Top             =   1560
         Width           =   1695
      End
      Begin VB.TextBox Text_dd_UnitPrice 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   40
         Top             =   960
         Width           =   1695
      End
      Begin VB.TextBox Text_dd_grade 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   38
         Top             =   480
         Width           =   1695
      End
      Begin VB.Label Label32 
         Caption         =   "Quantity e Total :"
         Height          =   255
         Left            =   120
         TabIndex        =   61
         Top             =   3000
         Width           =   1695
      End
      Begin VB.Label Label31 
         Caption         =   "Money e Total :"
         Height          =   255
         Left            =   120
         TabIndex        =   59
         Top             =   2520
         Width           =   1095
      End
      Begin VB.Label Label22 
         Caption         =   "Quantity :"
         Height          =   255
         Left            =   120
         TabIndex        =   45
         Top             =   2040
         Width           =   1095
      End
      Begin VB.Label Label21 
         Caption         =   "Money :"
         Height          =   255
         Left            =   120
         TabIndex        =   43
         Top             =   1560
         Width           =   1095
      End
      Begin VB.Label Label20 
         Caption         =   "Unit Price :"
         Height          =   255
         Left            =   120
         TabIndex        =   41
         Top             =   960
         Width           =   1095
      End
      Begin VB.Label Label19 
         Caption         =   "Grade :"
         Height          =   255
         Left            =   120
         TabIndex        =   39
         Top             =   480
         Width           =   1095
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "History data"
      Height          =   5055
      Left            =   7680
      TabIndex        =   18
      Top             =   600
      Width           =   4215
      Begin VB.TextBox Text_hd_ReservedType 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   81
         Top             =   2880
         Width           =   1695
      End
      Begin VB.TextBox Text_hd_Age 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   68
         Top             =   4320
         Width           =   1695
      End
      Begin VB.TextBox Text_hd_ClearedBy 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   66
         Top             =   3840
         Width           =   1695
      End
      Begin VB.TextBox Text_hd_ReservedBy 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   64
         Top             =   3360
         Width           =   1695
      End
      Begin VB.TextBox Text_hd_CompletionReason 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   62
         Top             =   2400
         Width           =   1695
      End
      Begin VB.TextBox Text_hd_ClearedDateTime 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   36
         Top             =   1920
         Width           =   1695
      End
      Begin VB.TextBox Text_hd_CompletedDateTime 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   34
         Top             =   1440
         Width           =   1695
      End
      Begin VB.TextBox Text_hd_AuthoriseDateTime 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   32
         Top             =   960
         Width           =   1695
      End
      Begin VB.TextBox Text_hd_ReservedDateTime 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   30
         Top             =   480
         Width           =   1695
      End
      Begin VB.Label Label23 
         Caption         =   "Reserved Type :"
         Height          =   255
         Left            =   120
         TabIndex        =   80
         Top             =   2880
         Width           =   1695
      End
      Begin VB.Label Label37 
         Caption         =   "Age :"
         Height          =   255
         Left            =   120
         TabIndex        =   69
         Top             =   4320
         Width           =   1695
      End
      Begin VB.Label Label36 
         Caption         =   "Cleared By :"
         Height          =   255
         Left            =   120
         TabIndex        =   67
         Top             =   3840
         Width           =   1695
      End
      Begin VB.Label Label35 
         Caption         =   "Reserved By :"
         Height          =   255
         Left            =   120
         TabIndex        =   65
         Top             =   3360
         Width           =   1695
      End
      Begin VB.Label Label34 
         Caption         =   "Completion Reason :"
         Height          =   255
         Left            =   120
         TabIndex        =   63
         Top             =   2400
         Width           =   1695
      End
      Begin VB.Label Label18 
         Caption         =   "Cleared DateTime :"
         Height          =   255
         Left            =   120
         TabIndex        =   37
         Top             =   1920
         Width           =   1695
      End
      Begin VB.Label Label17 
         Caption         =   "Completed DateTime :"
         Height          =   255
         Left            =   120
         TabIndex        =   35
         Top             =   1440
         Width           =   1695
      End
      Begin VB.Label Label16 
         Caption         =   "Authorise DateTime :"
         Height          =   255
         Left            =   120
         TabIndex        =   33
         Top             =   960
         Width           =   1695
      End
      Begin VB.Label Label15 
         Caption         =   "Reserved DateTime :"
         Height          =   255
         Left            =   120
         TabIndex        =   31
         Top             =   480
         Width           =   1695
      End
   End
   Begin VB.Frame Frame1 
      Caption         =   "Authorise data"
      Height          =   3375
      Left            =   3480
      TabIndex        =   17
      Top             =   600
      Width           =   4095
      Begin VB.TextBox Text_ad_QuantLimit 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   56
         Top             =   2760
         Width           =   1695
      End
      Begin VB.TextBox Text_ad_MoneyLimit 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   54
         Top             =   2280
         Width           =   1695
      End
      Begin VB.TextBox Text_ad_authReason 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   52
         Top             =   1800
         Width           =   1695
      End
      Begin VB.TextBox Text_ad_AuthDate 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   28
         Top             =   1320
         Width           =   1695
      End
      Begin VB.TextBox Text_ad_terminal 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   26
         Top             =   840
         Width           =   1695
      End
      Begin VB.TextBox Text_ad_pricelevel 
         Enabled         =   0   'False
         Height          =   375
         Left            =   1920
         TabIndex        =   24
         Top             =   360
         Width           =   1695
      End
      Begin VB.Label Label29 
         Caption         =   "Quantity limit :"
         Height          =   255
         Left            =   240
         TabIndex        =   57
         Top             =   2760
         Width           =   1575
      End
      Begin VB.Label Label28 
         Caption         =   "Money limit :"
         Height          =   255
         Left            =   240
         TabIndex        =   55
         Top             =   2280
         Width           =   1575
      End
      Begin VB.Label Label27 
         Caption         =   "Authorise Reason :"
         Height          =   255
         Left            =   240
         TabIndex        =   53
         Top             =   1800
         Width           =   1575
      End
      Begin VB.Label Label14 
         Caption         =   "Authorise Date Time :"
         Height          =   255
         Left            =   240
         TabIndex        =   29
         Top             =   1320
         Width           =   1575
      End
      Begin VB.Label Label13 
         Caption         =   "Terminal :"
         Height          =   255
         Left            =   240
         TabIndex        =   27
         Top             =   840
         Width           =   1095
      End
      Begin VB.Label Label12 
         Caption         =   "Price_level :"
         Height          =   255
         Left            =   240
         TabIndex        =   25
         Top             =   360
         Width           =   1095
      End
   End
   Begin VB.CheckBox Check_isLocked 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1800
      TabIndex        =   16
      Top             =   3525
      Width           =   1335
   End
   Begin VB.TextBox Text_lockedBy 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1800
      TabIndex        =   14
      Top             =   4440
      Width           =   1335
   End
   Begin VB.TextBox Text_lockedById 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1800
      TabIndex        =   12
      Top             =   3960
      Width           =   1335
   End
   Begin VB.TextBox Text_attendant 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1800
      TabIndex        =   9
      Top             =   3120
      Width           =   1335
   End
   Begin VB.TextBox Text_state 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1800
      TabIndex        =   7
      Top             =   2640
      Width           =   1335
   End
   Begin VB.TextBox Text_ClientActivity 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1800
      TabIndex        =   6
      Top             =   2160
      Width           =   1335
   End
   Begin VB.TextBox Text_ClientRef 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1800
      TabIndex        =   4
      Top             =   1680
      Width           =   1335
   End
   Begin VB.TextBox Text_id 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1800
      TabIndex        =   2
      Top             =   720
      Width           =   1335
   End
   Begin VB.TextBox Text_deliveryId 
      Enabled         =   0   'False
      Height          =   375
      Left            =   1800
      TabIndex        =   83
      Top             =   1200
      Width           =   1335
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "Close"
      Height          =   375
      Left            =   10560
      TabIndex        =   0
      Top             =   8280
      Width           =   1215
   End
   Begin VB.Label Label5 
      Caption         =   "Delivery type :"
      Height          =   255
      Left            =   360
      TabIndex        =   79
      Top             =   5880
      Width           =   1335
   End
   Begin VB.Label Label_trans 
      Caption         =   "Select stacked transaction"
      Height          =   255
      Left            =   360
      TabIndex        =   76
      Top             =   120
      Width           =   1815
   End
   Begin VB.Label Label11 
      Caption         =   "Pump :"
      Height          =   255
      Left            =   360
      TabIndex        =   23
      Top             =   5400
      Width           =   1095
   End
   Begin VB.Label Label10 
      Caption         =   "Hose :"
      Height          =   255
      Left            =   360
      TabIndex        =   21
      Top             =   4920
      Width           =   1095
   End
   Begin VB.Label Label9 
      Caption         =   "Locked By :"
      Height          =   255
      Left            =   360
      TabIndex        =   15
      Top             =   4440
      Width           =   1095
   End
   Begin VB.Label Label8 
      Caption         =   "Locked By ID :"
      Height          =   255
      Left            =   360
      TabIndex        =   13
      Top             =   3960
      Width           =   1095
   End
   Begin VB.Label Label7 
      Caption         =   "Is Locked :"
      Height          =   255
      Left            =   360
      TabIndex        =   11
      Top             =   3600
      Width           =   1095
   End
   Begin VB.Label Label6 
      Caption         =   "Attendant :"
      Height          =   255
      Left            =   360
      TabIndex        =   10
      Top             =   3120
      Width           =   1095
   End
   Begin VB.Label Label4 
      Caption         =   "State :"
      Height          =   255
      Left            =   360
      TabIndex        =   8
      Top             =   2640
      Width           =   1095
   End
   Begin VB.Label Label3 
      Caption         =   "Client Activity :"
      Height          =   255
      Left            =   360
      TabIndex        =   5
      Top             =   2160
      Width           =   1095
   End
   Begin VB.Label Label2 
      Caption         =   "Client Reference :"
      Height          =   255
      Left            =   360
      TabIndex        =   3
      Top             =   1680
      Width           =   1695
   End
   Begin VB.Label Label30 
      Caption         =   "Delivery ID :"
      Height          =   255
      Left            =   360
      TabIndex        =   84
      Top             =   1200
      Width           =   975
   End
   Begin VB.Label Label1 
      Caption         =   "Id :"
      Height          =   255
      Left            =   360
      TabIndex        =   1
      Top             =   720
      Width           =   1095
   End
End
Attribute VB_Name = "DialogTransaction"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'**************************************************
' Transaction details Dialog
' Copyright 2013 Integration Technologies Ltd
'
' Show details of transaction
' Called from get Transastion, Show current, Show stack
' Reinstate transation
'**************************************************
Option Explicit

Private CurTrans As ITL_Enabler_API.Transaction
Private CurPump As Pump

' 0 = Pump current, 1 = Pump stack , 2 = Transaction
Private Dlgtype As Integer

Public Sub SetPump(p As Pump, Dtype As Integer)
    Set CurPump = p
    Dlgtype = Dtype
    SetUpForm
    ShowTransDetails
End Sub

Public Sub SetTransaction(trans As Transaction)
    Set CurTrans = trans
    Dlgtype = 2
    SetUpForm
    ShowTransDetails
End Sub

Private Sub SetUpForm()
    Dim transX As Transaction
    
    Combo_transactions.Visible = False
    Label_trans.Visible = False
    Command_reinstate.Visible = False
    Command_reinstateAndLock.Visible = False
    
    Select Case Dlgtype
    Case 0 ' Transaction stack
        Combo_transactions.Visible = True
        Label_trans.Visible = True
        
        With CurPump
        Combo_transactions.Clear
            For Each transX In .TransactionStack
                Combo_transactions.AddItem "Id:" + Format(transX.Id) + " Val:" + FormatCurrency(transX.DeliveryData.Money) + " Vol:" + FormatCurrency(transX.DeliveryData.Quantity)
            Next
            If (.TransactionStack.Count > 0) Then Combo_transactions.ListIndex = 0
        End With
    Case 1 ' Current transaction
        Set CurTrans = CurPump.CurrentTransaction
    Case 2 ' Found transaction
        Command_reinstate.Visible = True
        Command_reinstateAndLock.Visible = True
        Command_getLock.Visible = False
        Command_Releaselock.Visible = False
        Command_clear.Visible = False
        Combo_cleartype.Visible = False
    End Select
End Sub

Private Sub ShowTransDetails()
    If (CurTrans Is Nothing) Then Exit Sub
    With CurTrans
       Text_id = Format(.Id)

       Text_ClientActivity = .clientActivity
       Text_ClientRef = .clientReference
       
       On Error Resume Next    'handle using old API
       Text_deliveryId.text = Format(.DeliveryData.DeliveryID)
       On Error GoTo 0         'normal error handling
       
       Select Case .State
       Case TransactionState_Authorised
            Text_state = "Authorised"
       Case TransactionState_Cancelled
            Text_state = "Cancelled"
       Case TransactionState_Cleared
            Text_state = "Cleared"
       Case TransactionState_Completed
            Text_state = "Completed"
       Case TransactionState_Fuelling
            Text_state = "Fuelling"
       Case TransactionState_Reserved
            Text_state = "Reserved"
       End Select
       
       If (.Attendant Is Nothing) Then
            Text_attendant = "none"
       Else
            Text_attendant = .Attendant.name
       End If
       
       Check_isLocked = IsValue(.IsLocked)
       Text_lockedById = .LockedById
       If (.IsLocked) Then
        Text_lockedBy = Format(.LockedBy.Id) + " \ " + .LockedBy.name
       Else
        Text_lockedBy = ""
       End If
       
       If (.hose Is Nothing) Then
            Text_hose = "none"
       Else
            Text_hose = Format(.hose.number) + " \ " + .hose.Grade.name
       End If
        
       If (.Pump Is Nothing) Then
           Text_pump = "none"
        Else
           Text_pump = Format(.Pump.number) + " \ " + .Pump.name
       End If
       
       Select Case .DeliveryType
        Case DeliveryTypes_Attendant
            Text_deliverytype = "Attendant"
        Case DeliveryTypes_AvailablePreauth
            Text_deliverytype = "Available Preauth"
        Case DeliveryTypes_AvailablePrePayRefund
            Text_deliverytype = "Available PrePayRefund"
        Case DeliveryTypes_Current
            Text_deliverytype = "Current"
        Case DeliveryTypes_DriveOff
            Text_deliverytype = "Drive Off"
        Case DeliveryTypes_Monitor
            Text_deliverytype = "Monitor"
        Case DeliveryTypes_Normal
            Text_deliverytype = "Normal"
        Case DeliveryTypes_Offline
            Text_deliverytype = "Offline"
        Case DeliveryTypes_PreAuth
            Text_deliverytype = "PreAuth"
        Case DeliveryTypes_PrePay
            Text_deliverytype = "PrePay"
        Case DeliveryTypes_PrePayRefund
            Text_deliverytype = "PrePay Refund"
        Case DeliveryTypes_PrePayRefundLost
            Text_deliverytype = "PrePay Refund Lost"
        Case DeliveryTypes_Reinstated
            Text_deliverytype = "Reinstated"
        Case DeliveryTypes_Stacked
            Text_deliverytype = "Stacked"
        Case DeliveryTypes_Test
            Text_deliverytype = "Test"
        Case DeliveryTypes_Unknown
            Text_deliverytype = "Unknown"
        End Select
     
    End With
       
    With CurTrans.AuthoriseData
         Text_ad_AuthDate = FormatDateTime(.AuthoriseDateTime)
         
         Select Case .reason
             Case AuthoriseReason_Attendant
                 Text_ad_authReason = "Attendant"
             Case AuthoriseReason_Auto
                 Text_ad_authReason = "Auto"
             Case AuthoriseReason_Client
                 Text_ad_authReason = "Client"
             Case AuthoriseReason_Fallback
                 Text_ad_authReason = "Fallback"
             Case AuthoriseReason_Monitor
                 Text_ad_authReason = "Monitor"
             Case AuthoriseReason_NotAuthorised
                 Text_ad_authReason = "NotAuthorised"
             Case AuthoriseReason_PumpSelf
                 Text_ad_authReason = "Pump Self"
         End Select
         
         Text_ad_MoneyLimit = FormatCurrency(.MoneyLimit)
         Text_ad_pricelevel = Format(.PriceLevel)
         Text_ad_QuantLimit = Format(.QuantityLimit)
         If (.Terminal Is Nothing) Then
             Text_ad_terminal = "none"
         Else
             Text_ad_terminal = Format(.Terminal.Id)
         End If
    End With
       
    With CurTrans.DeliveryData
     If (.Grade Is Nothing) Then
         Text_dd_grade = ""
     Else
         Text_dd_grade = .Grade.name
     End If
     
     Text_dd_Money = FormatCurrency(.Money)
     Text_dd_MoneyTotal = FormatCurrency(.MoneyTotal)
     Text_dd_Quantity = Format(.Quantity)
     Text_dd_QuantityTotal = Format(.QuantityTotal)
     Text_dd_UnitPrice = FormatCurrency(.UnitPrice)
    End With
    
    With CurTrans.HistoryData
     Text_hd_Age = Format(.Age)
     
     Text_hd_AuthoriseDateTime = FormatDateTime(.AuthoriseDateTime)
     Text_hd_ClearedDateTime = FormatDateTime(.ClearedDateTime)
     Text_hd_CompletedDateTime = FormatDateTime(.CompletedDateTime)
     
     Text_hd_ReservedDateTime = FormatDateTime(.ReservedDateTime)
     
     Text_hd_ReservedType = ""
     
     Select Case .ReservedType
     Case ReservedType_Normal: Text_hd_ReservedType = "Normal"
     Case ReservedType_Prepay: Text_hd_ReservedType = "Prepay"
     Case ReservedType_PreAuth: Text_hd_ReservedType = "PreAuth"
     End Select
     
     If (.ReservedBy Is Nothing) Then
         Text_hd_ReservedBy = ""
     Else
         Text_hd_ReservedBy = Format(.ReservedBy.Id) + " \ " + .ReservedBy.name
     End If
     
     If (.ClearedBy Is Nothing) Then
         Text_hd_ClearedBy = ""
     Else
         Text_hd_ClearedBy = Format(.ClearedBy.Id) + " \ " + .ClearedBy.name
     End If
     
     Select Case .CompletionReason
         Case CompletionReason_Cancelled
             Text_hd_CompletionReason = "Cancelled"
         Case CompletionReason_Normal
             Text_hd_CompletionReason = "Normal"
         Case CompletionReason_NotComplete
             Text_hd_CompletionReason = "Not Complete"
         Case CompletionReason_StoppedByClient
             Text_hd_CompletionReason = "Stopped By Client"
         Case CompletionReason_StoppedByError
             Text_hd_CompletionReason = "Stopped By Error"
         Case CompletionReason_StoppedByLimit
             Text_hd_CompletionReason = "Stopped By Limit"
         Case CompletionReason_Timeout
             Text_hd_CompletionReason = "Timeout"
         Case CompletionReason_Zero
             Text_hd_CompletionReason = "Zero"
     End Select
        
    End With
 
    With CurTrans.Blend
        
        Text_bd_Ratio = Format(.Ratio)
        
        If (.Base1 Is Nothing) Then
             Text_bd_Base1 = ""
        Else
             Text_bd_Base1 = FormatCurrency(.Base1.Money) + " \ " + Format(.Base1.Quantity)
        End If
        
        If (.Base2 Is Nothing) Then
             Text_bd_Base2 = ""
        Else
             Text_bd_Base2 = FormatCurrency(.Base2.Money) + " \ " + Format(.Base2.Quantity)
        End If
    
    End With
    
    Combo_cleartype.AddItem "Normal"
    Combo_cleartype.AddItem "Attendant"
    Combo_cleartype.AddItem "Drive Off"
    Combo_cleartype.AddItem "Test"
    Combo_cleartype.ListIndex = 0
End Sub

Private Function IsValue(value As Boolean) As String
    If (value = True) Then
        IsValue = "1"
    Else
        IsValue = "0"
    End If
End Function

Private Sub Combo_transactions_Click()
    Set CurTrans = CurPump.TransactionStack.GetByIndex(Combo_transactions.ListIndex)
    If (Not CurTrans Is Nothing) Then
        ShowTransDetails
    End If
End Sub

Private Sub Command_getLock_Click()
    If (CurTrans Is Nothing) Then Exit Sub

    DoCommand "GetLock", CurTrans.GetLock
End Sub



Private Sub Command_Releaselock_Click()
    If (CurTrans Is Nothing) Then Exit Sub

    DoCommand "ReleaseLock", CurTrans.ReleaseLock
End Sub

Private Sub Command_reinstate_Click()
    DoCommand "Reinstate", CurTrans.Reinstate
End Sub

Private Sub Command_reinstateAndLock_Click()
    DoCommand "Reinstate", CurTrans.ReinstateAndLock
End Sub

Private Sub Command_clear_Click()
    Dim clearType As TransactionClearTypes
    
    If (CurTrans Is Nothing) Then Exit Sub

    clearType = TransactionClearTypes_Normal
    
    Select Case Combo_cleartype.ListIndex
        Case 0
            clearType = TransactionClearTypes_Normal
        Case 1
            clearType = TransactionClearTypes_Attendant
        Case 2
            clearType = TransactionClearTypes_DriveOff
        Case 3
            clearType = TransactionClearTypes_Test
    End Select
    
    
    DoCommand "Clear", CurTrans.Clear(clearType)
End Sub

Private Sub DoCommand(Command As String, result As ApiResult)
    If (result <> ApiResult_Ok) Then
        MsgBox Command + ":" + FormMain.myforecourt.GetResultString(result)
    End If
    ShowTransDetails
End Sub


Private Sub OKButton_Click()
    Unload Me
End Sub

