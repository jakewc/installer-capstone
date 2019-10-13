VERSION 5.00
Begin VB.Form PrepayDlg 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Prepay Delivery"
   ClientHeight    =   3945
   ClientLeft      =   4470
   ClientTop       =   4095
   ClientWidth     =   2940
   ControlBox      =   0   'False
   Icon            =   "PrepayDlg.frx":0000
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3945
   ScaleWidth      =   2940
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.TextBox Text_CRef 
      Alignment       =   1  'Right Justify
      Height          =   375
      Left            =   1440
      TabIndex        =   7
      Text            =   "10.00"
      Top             =   2880
      Width           =   1335
   End
   Begin VB.CheckBox AllHosesCheck 
      Caption         =   "Allow All Hoses"
      Height          =   255
      Left            =   120
      TabIndex        =   6
      Top             =   2400
      Width           =   2295
   End
   Begin VB.ListBox AllowedHoseList 
      Height          =   1455
      IntegralHeight  =   0   'False
      ItemData        =   "PrepayDlg.frx":05FA
      Left            =   120
      List            =   "PrepayDlg.frx":05FC
      Style           =   1  'Checkbox
      TabIndex        =   1
      Top             =   840
      Width           =   2655
   End
   Begin VB.TextBox Limit 
      Alignment       =   1  'Right Justify
      Height          =   375
      Left            =   1440
      TabIndex        =   0
      Text            =   "10.00"
      Top             =   120
      Width           =   1335
   End
   Begin VB.CommandButton Cancel 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   1680
      TabIndex        =   3
      Top             =   3480
      Width           =   1095
   End
   Begin VB.CommandButton OkButton 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   480
      TabIndex        =   2
      Top             =   3480
      Width           =   1095
   End
   Begin VB.Label Label_ref 
      Caption         =   "Client Reference"
      Height          =   255
      Left            =   120
      TabIndex        =   8
      Top             =   2880
      Width           =   1215
   End
   Begin VB.Label LimitLabel 
      Caption         =   "Money Amount"
      Height          =   255
      Left            =   120
      TabIndex        =   5
      Top             =   120
      Width           =   1215
   End
   Begin VB.Label AllowedHosesLabel 
      AutoSize        =   -1  'True
      Caption         =   "Allowed Hoses"
      Height          =   195
      Left            =   120
      TabIndex        =   4
      Top             =   600
      Width           =   1050
   End
End
Attribute VB_Name = "PrepayDlg"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'*****************************************************************
'*
'* Copyright (C) 1997-2003 Integration Technologies Limited
'* All rights reserved.
'*
'* This module is an example of how a Point Of Sale application would
'* use The Enabler ActiveX controls to perform a prepay sale
'*
'******************************************************************/

Option Explicit

Public PumpNumber As Integer
Private Done As Boolean

Private Sub AllHosesCheck_Click()
    AllowedHoseList.Enabled = AllHosesCheck.Value <> vbChecked
End Sub

'******************************************************************/
'*
'*  Cancel_Click - Click event for the cancel button, this
'*      cancels the prepay attempt, if a reserve is in place
'*      then we need to cancel it
'*
'******************************************************************/
Private Sub Cancel_Click()

Dim result As Integer
    
    Done = True
    
    ' is a reserve in place
    If PumpNumber >= 1 Then
    
        ' if so cancel it
        result = MainForm.Pump(PumpNumber).CancelPrepay
        
        ' check result, if not Okay then display error string
        ' as retrieved from the Enabler SessionX object
        If result <> OK_RESULT Then
            MsgBox MainForm.Session.ResultString(result), vbExclamation
        End If
        
    End If
    
    PumpNumber = -1
    Hide
    
End Sub

'******************************************************************/
'*
'*  Form_Activate - form activate event, initialise the prepay dialog
'*
'******************************************************************/
Private Sub Form_Activate()
    
Dim result As Integer
Dim i As Integer

    Done = False

    ' load the hose listbox with all the names of the grades on
    ' each of this pump's hoses
    AllowedHoseList.Clear
    With MainForm.Pump(PumpNumber)
        For i = 1 To .NumberOfHoses
            AllowedHoseList.AddItem .Hose(i).grade.name
            
            ' select hose 1 by default
            If i = 1 Then
                AllowedHoseList.Selected(0) = True ' listbox is zero based
            End If
        Next i
    End With
    
    Caption = "Prepay delivery on pump " & PumpNumber
    Text_CRef.Text = "0"
    
   ' Only show Client reference if v4 or later
    If MainForm.Version4 Then
        Label_ref.Visible = True
        Text_CRef.Visible = True
    Else
        Label_ref.Visible = False
        Text_CRef.Visible = False
    End If
    
End Sub



'******************************************************************/
'*
'*  OkButton_Click - Click event for the ok button, this is clicked
'*      by the user when the hose and amount have been entered
'*
'******************************************************************/
Private Sub OkButton_Click()
    
Dim Desc As String
Dim Value As Currency
Dim AllowedHoses As Integer
Dim ClientReference As Long
    
    ' check that the limit is a valid number
    On Error GoTo bad_limit
    Value = CCur(Limit.Text)
    
    ' check Client reference
    On Error GoTo bad_ref
    ClientReference = CLng(Text_CRef.Text)
    If ClientReference < 0 Then GoTo bad_ref
    
    ' if amount is valid go ahead and add item to the sale
    With MainForm.Pump(PumpNumber)
        AllowedHoses = GetAllowedHoses
        Desc = "Prepay " & Format(PumpNumber, "00 - Hoses ") & AllowedHoses
        
        ' note the prepay is not authorised at this point but rather
        ' at the time the sale is successfully finalised, this ensures
        ' that no fuel is dispensed until payment processing is complete
        If AddSaleItem(prepayItem, Desc, Value, 1, Value, ClientReference) Then
            With Sale.Items(Sale.NumberOfItems - 1)
                .AllowedHoses = AllowedHoses
                .PumpNumber = PumpNumber
            End With
        Else
            ' if for whatever reason the sale item could not be added
            ' cancel the prepay reserve
            .CancelPrepay
            Exit Sub
        End If
        
    End With
    
    Done = True
    PumpNumber = -1
    Hide
    Exit Sub
    
' trap the invalid pump number error
bad_limit:
    MsgBox "Invalid prepay limit, please re-enter.", vbExclamation
    Limit.SetFocus
    Exit Sub
    
bad_ref:
    MsgBox "Invalid client reference, must be a positive numeric, please re-enter.", vbExclamation
    Text_CRef.SetFocus
    
End Sub


'******************************************************************/
'*
'*  PrepayDeliveryCancelled Sub - called by the main form when it
'*          detects that the prepay authorise has been cancelled by
'*          the server, ie the authorise has timed out
'*
'******************************************************************/
Public Sub PrepayDeliveryCancel()

    If Done Then
        ' We get here if we have called CancelPreauth - see CancelButton_Click()
        Exit Sub
    End If
    
    Done = True
    
    MsgBox "Pump " + CStr(PumpNumber) + " is no longer reserved or authorised for a prepay" _
            + Chr(10) + Chr(10) + "Prepay cancelled", vbInformation
    PumpNumber = -1
    Hide

End Sub


'******************************************************************/
'*
'*  Get a 'bitmap' that indicates the hose(s) allowed
'*
'******************************************************************/
Private Function GetAllowedHoses() As Integer

Dim i As Integer
Dim AllowedHoses As Integer

    If AllHosesCheck.Value = vbChecked Then
        GetAllowedHoses = 255
        Exit Function
    End If
    
    AllowedHoses = 0
    For i = 0 To AllowedHoseList.ListCount - 1
        If AllowedHoseList.Selected(i) Then
            AllowedHoses = AllowedHoses + 2 ^ i
        End If
    Next i
    
    GetAllowedHoses = AllowedHoses
    
End Function
