VERSION 5.00
Begin VB.Form DialogHoses 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Hoses on Pump"
   ClientHeight    =   7980
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   5685
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   7980
   ScaleWidth      =   5685
   ShowInTaskbar   =   0   'False
   Begin VB.ComboBox Combo_hoses 
      Height          =   315
      Left            =   1560
      TabIndex        =   8
      Text            =   "No Hoses"
      Top             =   240
      Width           =   2055
   End
   Begin VB.Frame Frame_details 
      Caption         =   "Hose details"
      Height          =   6735
      Left            =   240
      TabIndex        =   1
      Top             =   720
      Width           =   5295
      Begin VB.CommandButton Command_toggleBlock 
         Caption         =   "Toggle Block"
         Height          =   255
         Left            =   2280
         TabIndex        =   31
         Top             =   2040
         Width           =   1335
      End
      Begin VB.CheckBox Check_hose_user 
         Caption         =   "Hose: User"
         Enabled         =   0   'False
         Height          =   255
         Left            =   1920
         TabIndex        =   30
         Top             =   3060
         Width           =   1215
      End
      Begin VB.CheckBox Check_pump_user 
         Caption         =   "Pump: User"
         Enabled         =   0   'False
         Height          =   255
         Left            =   3240
         TabIndex        =   29
         Top             =   3060
         Width           =   1695
      End
      Begin VB.CheckBox Check_tank_delivery 
         Caption         =   "Tank: Tanker Delivery"
         Enabled         =   0   'False
         Height          =   255
         Left            =   1920
         TabIndex        =   28
         Top             =   2730
         Width           =   2775
      End
      Begin VB.CheckBox Check_grade_user 
         Caption         =   "Grade: User"
         Enabled         =   0   'False
         Height          =   255
         Left            =   1920
         TabIndex        =   27
         Top             =   3360
         Width           =   1575
      End
      Begin VB.CheckBox Check_tank_user 
         Caption         =   "Tank: User"
         Enabled         =   0   'False
         Height          =   255
         Left            =   1920
         TabIndex        =   26
         Top             =   2400
         Width           =   1335
      End
      Begin VB.CheckBox Check_tank_low_level 
         Caption         =   "Tank: Low Level"
         Enabled         =   0   'False
         Height          =   255
         Left            =   3240
         TabIndex        =   25
         Top             =   2400
         Width           =   1695
      End
      Begin VB.Timer Timer1 
         Interval        =   1000
         Left            =   0
         Top             =   5280
      End
      Begin VB.Frame Frame3 
         Caption         =   "Tank details"
         Height          =   1455
         Left            =   240
         TabIndex        =   19
         Top             =   3720
         Width           =   4695
         Begin VB.TextBox Text_tank1 
            Enabled         =   0   'False
            Height          =   285
            Left            =   1680
            TabIndex        =   21
            Top             =   480
            Width           =   1815
         End
         Begin VB.TextBox Text_quantity1 
            Enabled         =   0   'False
            Height          =   285
            Left            =   1680
            TabIndex        =   20
            Top             =   840
            Width           =   1815
         End
         Begin VB.Label Label12 
            Caption         =   "Tank:"
            Height          =   255
            Left            =   240
            TabIndex        =   23
            Top             =   480
            Width           =   1095
         End
         Begin VB.Label Label11 
            Caption         =   "Quantity total :"
            Height          =   255
            Left            =   240
            TabIndex        =   22
            Top             =   840
            Width           =   1095
         End
      End
      Begin VB.Frame Frame2 
         Caption         =   "2nd Tank when blending pump"
         Height          =   1455
         Left            =   240
         TabIndex        =   14
         Top             =   5160
         Width           =   4695
         Begin VB.TextBox Text_quantity2 
            Enabled         =   0   'False
            Height          =   285
            Left            =   1680
            TabIndex        =   17
            Top             =   840
            Width           =   1815
         End
         Begin VB.TextBox Text_tank2 
            Enabled         =   0   'False
            Height          =   285
            Left            =   1680
            TabIndex        =   15
            Text            =   "None"
            Top             =   480
            Width           =   1815
         End
         Begin VB.Label Label10 
            Caption         =   "Quantity total :"
            Height          =   255
            Left            =   240
            TabIndex        =   18
            Top             =   840
            Width           =   1095
         End
         Begin VB.Label Label7 
            Caption         =   "Tank:"
            Height          =   255
            Left            =   240
            TabIndex        =   16
            Top             =   480
            Width           =   1095
         End
      End
      Begin VB.TextBox Text_money 
         Enabled         =   0   'False
         Height          =   285
         Left            =   1920
         TabIndex        =   12
         Text            =   "0"
         Top             =   1560
         Width           =   1815
      End
      Begin VB.TextBox Text_Grade 
         Enabled         =   0   'False
         Height          =   285
         Left            =   1920
         TabIndex        =   10
         Top             =   1200
         Width           =   1815
      End
      Begin VB.TextBox Text_number 
         Enabled         =   0   'False
         Height          =   285
         Left            =   1920
         TabIndex        =   4
         Top             =   840
         Width           =   1815
      End
      Begin VB.TextBox Text_id 
         Enabled         =   0   'False
         Height          =   285
         Left            =   1920
         TabIndex        =   3
         Top             =   480
         Width           =   1815
      End
      Begin VB.CheckBox Check_IsBlocked 
         Enabled         =   0   'False
         Height          =   315
         Left            =   1920
         TabIndex        =   2
         Top             =   2040
         Width           =   615
      End
      Begin VB.Label Label6 
         Caption         =   "Block reasons:"
         Height          =   255
         Left            =   240
         TabIndex        =   24
         Top             =   2400
         Width           =   1455
      End
      Begin VB.Label Label8 
         Caption         =   "Money total :"
         Height          =   255
         Left            =   240
         TabIndex        =   13
         Top             =   1560
         Width           =   1095
      End
      Begin VB.Label Label3 
         Caption         =   "Grade:"
         Height          =   255
         Left            =   240
         TabIndex        =   11
         Top             =   1200
         Width           =   1095
      End
      Begin VB.Label Label4 
         Caption         =   "Number:"
         Height          =   255
         Left            =   240
         TabIndex        =   7
         Top             =   840
         Width           =   1095
      End
      Begin VB.Label Label2 
         Caption         =   "Id:"
         Height          =   255
         Left            =   240
         TabIndex        =   6
         Top             =   480
         Width           =   855
      End
      Begin VB.Label Label5 
         Caption         =   "IsBlocked:"
         Height          =   255
         Left            =   240
         TabIndex        =   5
         Top             =   2040
         Width           =   735
      End
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "Close"
      Height          =   375
      Left            =   4200
      TabIndex        =   0
      Top             =   240
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Select hose :"
      Height          =   375
      Left            =   240
      TabIndex        =   9
      Top             =   240
      Width           =   1095
   End
End
Attribute VB_Name = "DialogHoses"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'**************************************************
' Hoses Dialog
' Copyright 2013 Integration Technologies Ltd
'
' Select hose
' Show details of selected hose
' Block/Unblock hose
'**************************************************
Option Explicit

Private CurHose As hose
Private CurPump As Pump


Public Sub SetPump(Pump As Pump)
    Dim hose As hose
    Set CurPump = Pump
    
    Combo_hoses.Clear
    For Each hose In CurPump.Hoses
        Combo_hoses.AddItem Format(hose.number)
    Next
    If (Combo_hoses.ListCount > 0) Then Combo_hoses.ListIndex = 0
    
    Frame_details.Caption = "Hose details for Pump " + Format(CurPump.number)
End Sub


Private Sub Combo_hoses_Click()
    ShowHoseDetails
End Sub

Private Sub ShowHoseDetails()
    If (CurPump Is Nothing) Then Exit Sub
    
    Set CurHose = CurPump.Hoses.GetByIndex(Combo_hoses.ListIndex)
    If (CurHose Is Nothing) Then Exit Sub
    
    With CurHose
    
        If (.Grade Is Nothing Or .Tank1 Is Nothing) Then Exit Sub
        
        Text_id = Format(.Id)
        Text_number = Format(.number)
        Text_Grade = .Grade.name
        Text_money = FormatCurrency(.MoneyTotal)
        
        If (.IsBlocked = True) Then
            Check_IsBlocked.value = 1
        Else
            Check_IsBlocked.value = 0
        End If
            
           
        Check_tank_user.value = BlockReasonCheckValue(CurHose.BlockedReasons, HoseBlockedReasons_TankManual)
        Check_tank_low_level.value = BlockReasonCheckValue(CurHose.BlockedReasons, HoseBlockedReasons_TankLowLevel)
        Check_tank_delivery.value = BlockReasonCheckValue(CurHose.BlockedReasons, HoseBlockedReasons_TankerDelivery)
        Check_grade_user.value = BlockReasonCheckValue(CurHose.BlockedReasons, GradeBlockedReasons_Manual)
        Check_pump_user.value = BlockReasonCheckValue(CurHose.BlockedReasons, HoseBlockedReasons_PumpManual)
        Check_hose_user.value = BlockReasonCheckValue(CurHose.BlockedReasons, HoseBlockedReasons_HoseManual)
    
        Text_tank1 = Format(.Tank1.Id) + " \ " + .Tank1.name
        Text_quantity1 = Format(.QuantityTotal)
        
        If (Not .Tank2 Is Nothing) Then
            Text_tank2 = Format(.Tank2.Id) + " \ " + .Tank2.name
            Text_quantity2 = Format(.QuantityTotal2)
        End If
    End With

End Sub

Private Function BlockReasonCheckValue(reason As Integer, mask As Integer) As Integer
    If ((reason And mask) > 0) Then
        BlockReasonCheckValue = 1
    Else
        BlockReasonCheckValue = 0
    End If
End Function


Private Sub Command_toggleBlock_Click()
    If (BlockReasonCheckValue(CurHose.BlockedReasons, HoseBlockedReasons_HoseManual) = 0) Then
        DoCommand "Set Block", CurHose.SetBlock(True)
    Else
        DoCommand "Set Block", CurHose.SetBlock(False)
    End If
End Sub

Private Sub OKButton_Click()
    Unload Me
End Sub

' Update hose details by timer
Private Sub Timer1_Timer()
    ShowHoseDetails
End Sub

Private Sub DoCommand(Command As String, result As ApiResult)
    If (result <> ApiResult_Ok) Then
        MsgBox Command + ":" + FormMain.myforecourt.GetResultString(result)
    End If
    ShowHoseDetails
End Sub

