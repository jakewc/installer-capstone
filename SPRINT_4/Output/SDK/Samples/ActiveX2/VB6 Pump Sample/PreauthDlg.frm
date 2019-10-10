VERSION 5.00
Begin VB.Form PreauthDlg 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Preauth delivery"
   ClientHeight    =   3885
   ClientLeft      =   4470
   ClientTop       =   4095
   ClientWidth     =   5190
   ControlBox      =   0   'False
   Icon            =   "PreauthDlg.frx":0000
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3885
   ScaleWidth      =   5190
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.CheckBox AllHosesCheck 
      Caption         =   "Allow All Hoses"
      Height          =   375
      Left            =   240
      TabIndex        =   15
      Top             =   2400
      Width           =   2415
   End
   Begin VB.ListBox AllowedHoseList 
      Height          =   1935
      IntegralHeight  =   0   'False
      ItemData        =   "PreauthDlg.frx":05FA
      Left            =   2760
      List            =   "PreauthDlg.frx":05FC
      Style           =   1  'Checkbox
      TabIndex        =   13
      Top             =   360
      Width           =   2295
   End
   Begin VB.Frame PriceLevelFrame 
      Caption         =   "Price Level"
      Height          =   975
      Left            =   120
      TabIndex        =   10
      Top             =   1320
      Width           =   2535
      Begin VB.OptionButton LevelOption1 
         Caption         =   "Use level 1 price"
         Height          =   255
         Left            =   120
         TabIndex        =   12
         Top             =   240
         Width           =   2295
      End
      Begin VB.OptionButton LevelOption2 
         Caption         =   "Use level 2 price"
         Height          =   255
         Left            =   120
         TabIndex        =   11
         Top             =   600
         Width           =   2295
      End
   End
   Begin VB.Timer LoadTimer 
      Enabled         =   0   'False
      Interval        =   50
      Left            =   3960
      Top             =   2880
   End
   Begin VB.CommandButton CloseButton 
      Caption         =   "Close"
      Height          =   375
      Left            =   3960
      TabIndex        =   7
      Top             =   3360
      Width           =   1095
   End
   Begin VB.Frame LimitTypeFrame 
      Caption         =   "Limit"
      Height          =   975
      Left            =   120
      TabIndex        =   4
      Top             =   240
      Width           =   2535
      Begin VB.TextBox Limit 
         Alignment       =   1  'Right Justify
         Height          =   375
         Left            =   1320
         TabIndex        =   9
         Text            =   "10.00"
         Top             =   360
         Width           =   975
      End
      Begin VB.OptionButton ValueOption 
         Caption         =   "Money"
         Height          =   255
         Left            =   120
         TabIndex        =   6
         Top             =   240
         Width           =   1215
      End
      Begin VB.OptionButton VolumeOption 
         Caption         =   "Volume"
         Height          =   255
         Left            =   120
         TabIndex        =   5
         Top             =   600
         Width           =   1215
      End
   End
   Begin VB.TextBox DelDescription 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   120
      Locked          =   -1  'True
      TabIndex        =   2
      Top             =   3360
      Width           =   3735
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   2760
      TabIndex        =   1
      Top             =   2400
      Width           =   1095
   End
   Begin VB.CommandButton CancelButton 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   3960
      TabIndex        =   0
      Top             =   2400
      Width           =   1095
   End
   Begin VB.Label AllowedHosesLabel 
      AutoSize        =   -1  'True
      Caption         =   "Allowed Hoses"
      Height          =   195
      Left            =   2760
      TabIndex        =   14
      Top             =   120
      Width           =   1050
   End
   Begin VB.Label WaitingLabel 
      Caption         =   "Waiting for Delivery"
      Height          =   255
      Left            =   120
      TabIndex        =   8
      Top             =   2880
      Width           =   3735
   End
   Begin VB.Label DeliveryLabel 
      Caption         =   "Delivery Details"
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   3120
      Width           =   3735
   End
End
Attribute VB_Name = "PreauthDlg"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'*****************************************************************
'*
'* Copyright (C) 1997-2003 Integration Technologies Limited
'* All rights reserved.
'*
'* This dialog performs a simulation of the type of pump control that
'* an OPT (Outdoor Payment Terminal) controller application must perform.
'* Firstly reserving the pump so no other application can perform
'* transactions, and then authorising the pump for a delivery up to
'* the required limit.  Once the delivery is complete the delivery
'* details are retreived and cleared from the pump.
'*
'******************************************************************
Option Explicit

Public PumpNumber As Integer

Private ReserveOk As Boolean ' did our ReserveForPrepay call succeed?
Private Done As Boolean

'******************************************************************
'*
'* DeliveryStarted - this is called when a delivery has started on
'* the pump.  Here we make sure we don't cancel
'*
'******************************************************************
Public Sub DeliveryStarted()

    CancelButton.Enabled = False
    WaitingLabel.Caption = "Waiting for Delivery Completion"
    
End Sub

'******************************************************************
'*
'*  PreauthDeliveryComplete Sub - called by the main form when it
'*          detects that the preauth delivery has completed
'*
'******************************************************************
Public Sub PreauthDeliveryComplete()
    
Dim grade As String
Dim Price As Currency
Dim Value As Currency
Dim Volume As Currency
Dim DelType As Integer
Dim result As Integer

    DelDescription.Visible = True
    CloseButton.Visible = True
    CancelButton.Enabled = False

    WaitingLabel.Visible = False
    
    ' get the the summary details of this delivery
    ' and display it in the description text box
    ' this is not what would normally be done, at this point the
    ' card terminal app ( OPT app ) would finalise the sale and
    ' print receipt etc.
    
    MainForm.Pump(PumpNumber).CurrentDelivery.GetSummary grade, Volume, Price, Value, DelType
    DelDescription.Text = Trim(grade) & "   " & _
            Format(Price) & "   " & _
            CStr(Volume) & "   " & _
            Format(Value, "currency")
    
    ' now that the delivery details have been successfully retrieved
    ' we can clear the delivery,
    ' note that we did not have to lock the delivery first as preauth
    ' deliveries are automatically locked by for the terminal that
    ' reserved the pump, by the server, on delivery completetion
    If MainForm.mnClearCompletedPreauths.Checked Then
        ClearCompletedPreauth
    End If
       
End Sub

'******************************************************************
'*
'*  PreauthDeliveryCancel Sub - called by the main form when it
'*          detects that the preauth authorise has been cancelled by
'*          the server, ie the authorise has timed out
'*
'******************************************************************
Public Sub PreauthDeliveryCancel()

    ' if we fail to reserve the pump and are waiting for user to click ok on the
    ' message box, there is no reserve to cancel
    If Not ReserveOk Then
        Exit Sub
    End If
    
    If Done Then
        ' We get here if we have called CancelPreauth - see CancelButton_Click()
        Exit Sub
    End If
    
    Done = True ' prevent re-entry
    
    ' The pump is no longer reserved or authorised for a preauth
    ' This can happen for a number of reasons:
    '  - zero delivery
    '  - preauth authorise timeout
    '  - pump has stopped responding while reserved, or authorised
    '  - the pump server restarted while reseved, or authorised
    ' In any case no delivery has occurred, so we can just give up on this attempt
    MsgBox "Pump " + CStr(PumpNumber) + " is no longer reserved or authorised for a preauth" _
            + Chr(10) + Chr(10) + "Preauth cancelled", vbInformation
    Unload Me
    
End Sub

Private Sub AllHosesCheck_Click()
    AllowedHoseList.Enabled = AllHosesCheck.Value <> vbChecked
End Sub

'******************************************************************
'*
'*  CancelButton_Click - Click event for Cancel button, this
'*      closes the preauth dialog and cancels the preauth reserve
'*      on this pump
'*
'******************************************************************
Private Sub CancelButton_Click()

Dim result As Integer

    ' after we call CancelPreauth, we expect to receive a Pump StateChangeEvent, which calls
    ' PreauthDeliveryCancel() above, so we need to prevent that from displaying the timeout
    ' message
    Done = True ' so we don't say the preauth reserve has timed out
        
    result = MainForm.Pump(PumpNumber).CancelPreauth
            
    ' check result, if not Okay then display error string
    ' as retrieved from session object
    If result <> OK_RESULT Then
        MsgBox MainForm.Session.ResultString(result), vbExclamation
    End If
        
    ' remove the form
    Unload Me
    
End Sub

'******************************************************************
'*
'* CloseButton_Click - time to clear the completed preauth delivery
'*
'******************************************************************
Private Sub CloseButton_Click()

    ClearCompletedPreauth
    
End Sub

'******************************************************************
'* here we make sure we can get the current delivery and then we
'* clear it (if possible) to finish the preauth delivery process
'******************************************************************
Private Sub ClearCompletedPreauth()

Dim result As Integer
Dim CurrentDel As Delivery

    Done = True
    
    Set CurrentDel = MainForm.Pump(PumpNumber).CurrentDelivery
    
    If CurrentDel Is Nothing Then
        MsgBox "Cannot clear current delivery now", vbExclamation
        Exit Sub
    End If
    
    result = CurrentDel.ClearPreauth(MainForm.Session.TerminalID)
    
    ' check result, if not Okay then display error string
    ' as retrieved from session object
    If result <> OK_RESULT Then
        MsgBox MainForm.Session.ResultString(result), vbExclamation
        Exit Sub
    End If
    
    Unload Me

End Sub

'******************************************************************
'*
'*  Form_Load - the Load event for the preauth dialog
'*
'******************************************************************
Private Sub Form_Load()

Dim result As Integer
Dim i As Integer
Dim restart As Boolean

    restart = False
    Done = False
    
    Caption = "Preauth delivery pump " + CStr(PumpNumber)
            
    DelDescription.Text = ""
    
    OKButton.Enabled = True
    CancelButton.Enabled = True
    
    AllowedHoseList.Enabled = True
    Limit.Enabled = True
    VolumeOption.Enabled = True
    ValueOption.Enabled = True
    ValueOption.Value = True
    VolumeOption.Value = False
    LevelOption1.Enabled = True
    LevelOption2.Enabled = True
    LevelOption1.Value = True
    
    WaitingLabel.Visible = False
    
    DelDescription.Visible = False
    DeliveryLabel.Visible = False
    CloseButton.Visible = False

    
    AllowedHoseList.Clear
    With MainForm.Pump(PumpNumber)
        For i = 1 To .NumberOfHoses
            AllowedHoseList.AddItem .Hose(i).grade.name
            AllowedHoseList.Selected(i - 1) = True
        Next i
        
    End With
    
    
    Select Case GetPreauthState(PumpNumber)
    Case rsNone
        ' attempt a reserve on the pump.
        result = MainForm.Pump(PumpNumber).ReserveForPreauth
        
        ' check result, if not Okay then display error string
        ' as retrieved from session object
        If result <> OK_RESULT Then
            MsgBox MainForm.Session.ResultString(result), vbExclamation
            ReserveOk = False
            Visible = False
            LoadTimer.Enabled = True
            Exit Sub
        End If
    
    Case rsReserved
    
    Case rsAuthorised
        SetDeliveryToCompleteState
    
    Case rsDelivering
        SetDeliveryToCompleteState
        DeliveryStarted
    
    Case rsDelivered
        SetDeliveryToCompleteState
        DeliveryStarted
        PreauthDeliveryComplete
    
    
    End Select
    
    
    ReserveOk = True
    
End Sub

' Find the current preauth state. Used for restarts
Public Function GetPreauthState(PumpNum As Integer) As RestartState
    
    GetPreauthState = rsNone
    If MainForm.Pump(PumpNum).ReservedBy = MainForm.Session.TerminalID Then
    Debug.Print Format(Time, "h:m:s ") + ":GetPreauthState reserved by me  pmp:" + Format(PumpNum) + " RS:" + Format(MainForm.Pump(PumpNum).ReservedState)
        If MainForm.Pump(PumpNum).ReservedState = NOT_RESERVED Then
            Debug.Print Format(Time, "h:m:s ") + ":GetPreauthState Pump " + Format(PumpNum) + " is not reserved!"
        ' If we have a current delivery, see if preauth
        ElseIf Not MainForm.Pump(PumpNum).CurrentDelivery Is Nothing Then
            With MainForm.Pump(PumpNum).CurrentDelivery
               ' add Error handle for Spot #12532
                On Error GoTo ErrorHandle
                    If .Type = DeliveryTypes.AVAILABLE_PREAUTH_DELIVERY Then
                        GetPreauthState = rsDelivered
                    End If
            End With
        Else
ErrorHandle:
If Not Err.Description = "" Then
    Debug.Print Format(Time) + "Catch an Error:" + Err.Description
    Err.Clear
End If
            Debug.Print Format(Time) + ":GetPreauthState no current,  pmp:" + Format(PumpNum) + " reserved state:" + Format(MainForm.Pump(PumpNum).ReservedState)
            ' No current delivery, see if reserved or Authorised
            Select Case (MainForm.Pump(PumpNum).ReservedState)
            Case ReservedStates.RESERVED_FOR_PREAUTH
                GetPreauthState = rsReserved
            Case ReservedStates.PREAUTH_AUTHORISED
                GetPreauthState = rsAuthorised
            Case ReservedStates.PREAUTH_DELIVERING
                GetPreauthState = rsDelivering
            End Select
        End If

    End If
    
    Debug.Print Format(Time) + ":GetPreauthState exit pmp:" + Format(PumpNum) + " state:" + Format(GetPreauthState)

End Function



'******************************************************************
'*
'* make sure we reset our PumpNumber
'*
'******************************************************************
Private Sub Form_Unload(Cancel As Integer)

    PumpNumber = -1
    
End Sub

Private Sub LoadTimer_Timer()
    
    LoadTimer.Enabled = False
    If Not ReserveOk Then
        Unload Me
    End If

End Sub

'******************************************************************
'*
'*      This causes the POS app to attempt to authorise the previously
'*      reserved pump for a preauth delivery
'*
'******************************************************************
Private Sub OkButton_Click()

Dim result As Integer
Dim LimitValue As Currency
Dim LimitType As Integer
Dim PriceLevel As Integer
Dim HoseMask As Integer
    
    ' first check, ensure that the preauth limit value
    ' entered by the user is valid, and not blank
    On Error GoTo bad_limit
    LimitValue = CCur(Limit.Text)
    
    ' According to the Enabler devlopers ref, a limit of zero for a preauth
    ' is allowed...
    If LimitValue <= 0 Then
        MsgBox "Please enter an amount of at least 0.", vbExclamation
        Exit Sub
    End If
    
    ' ensure that they have entered in multiples of dollars
    'If Value \ 1 <> Value Then
    '    MsgBox "Please enter a preauth amount in whole dollars.", vbExclamation
    '    Exit Sub
    'End If
    
    ' select the limit type (volume or money)
    LimitType = IIf(ValueOption.Value, 4, 6)
    
    ' select the authorising price level - price levels are most commonly used to select
    ' different prices for credit card transactions vs cash transactions
    PriceLevel = IIf(LevelOption1.Value, 1, 2)
    
    If AllHosesCheck.Value = vbChecked Then
        HoseMask = 255 ' all hoses
    Else
        HoseMask = GetHoseBitmap(AllowedHoseList)
    End If
    
    If HoseMask = 0 Then
        MsgBox "Please select one or more products to authorise", vbExclamation
        Exit Sub
    End If
    
    ' now send the authorisation limit to The Enabler
    result = MainForm.Pump(PumpNumber).AuthorisePreauth(LimitType, LimitValue, PriceLevel, HoseMask)
    
    ' check result, if not OK then display error string
    ' as retrieved from session object
    If result <> OK_RESULT Then
        MsgBox MainForm.Session.ResultString(result), vbExclamation
        Exit Sub
    End If
    
    ' if successful lets move on to the next stage and wait for the delivery to complete
    SetDeliveryToCompleteState

    Exit Sub
    
' trap bad preauth value and display error message
bad_limit:
    MsgBox "Invalid Preauth limit, please re-enter.", vbExclamation
    Limit.SetFocus
    
End Sub

Sub SetDeliveryToCompleteState()

    OKButton.Enabled = False
    Limit.Enabled = False
    AllowedHoseList.Enabled = False
    
    LimitTypeFrame.Enabled = False
    VolumeOption.Enabled = False
    ValueOption.Enabled = False
    
    PriceLevelFrame.Enabled = False
    LevelOption1.Enabled = False
    LevelOption2.Enabled = False
    
    WaitingLabel.Visible = True
    WaitingLabel.Caption = "Waiting for Delivery"

End Sub
