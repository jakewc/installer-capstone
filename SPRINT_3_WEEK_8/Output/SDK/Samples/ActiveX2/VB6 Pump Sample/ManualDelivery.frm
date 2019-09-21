VERSION 5.00
Begin VB.Form ManualDeliveryDlg 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Manual Delivery"
   ClientHeight    =   2175
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   4470
   Icon            =   "ManualDelivery.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2175
   ScaleWidth      =   4470
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.TextBox DeliveryPrice 
      Alignment       =   1  'Right Justify
      Height          =   372
      Left            =   1800
      TabIndex        =   4
      Top             =   1080
      Width           =   2532
   End
   Begin VB.TextBox DeliveryValue 
      Alignment       =   1  'Right Justify
      Height          =   372
      Left            =   1800
      TabIndex        =   3
      Top             =   600
      Width           =   2532
   End
   Begin VB.TextBox DeliveryVolume 
      Alignment       =   1  'Right Justify
      Height          =   372
      Left            =   1800
      TabIndex        =   2
      Top             =   120
      Width           =   2532
   End
   Begin VB.CommandButton CancelButton 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   3120
      TabIndex        =   1
      Top             =   1680
      Width           =   1212
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   1800
      TabIndex        =   0
      Top             =   1680
      Width           =   1215
   End
   Begin VB.Label Label3 
      Alignment       =   1  'Right Justify
      Caption         =   "Delivery Price"
      Height          =   372
      Left            =   120
      TabIndex        =   7
      Top             =   1080
      Width           =   1452
   End
   Begin VB.Label Label2 
      Alignment       =   1  'Right Justify
      Caption         =   "Delivery Value"
      Height          =   372
      Left            =   240
      TabIndex        =   6
      Top             =   600
      Width           =   1332
   End
   Begin VB.Label Label1 
      Alignment       =   1  'Right Justify
      Caption         =   "Delivery volume"
      Height          =   372
      Left            =   120
      TabIndex        =   5
      Top             =   120
      Width           =   1452
   End
End
Attribute VB_Name = "ManualDeliveryDlg"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'*****************************************************************
'*
'* Copyright (C) 1997,1998 Integration Technologies Limited
'* All rights reserved.
'*
'* This dialog demonstrates how to use the LogManualDelivery method
'* for pumps that are setup as "Mechanical Pump" types. This allows
'* manually read delivery details to be recorded in The Enabler
'* database and cleared just like deliveries from electronic pumps.
'*
'******************************************************************

Option Explicit
Public ManualPump As Integer


Private Sub CancelButton_Click()
    Hide
End Sub

Private Sub Form_Activate()
    DeliveryPrice.Text = "0"
    DeliveryVolume.Text = "0"
    DeliveryValue.Text = "0"
End Sub

Private Sub OkButton_Click()
    Dim Desc As String
    Dim Value As Currency
    Dim Volume As Currency
    Dim Price As Currency
    Dim result As Integer
    
    ' check that the values are a valid numbers
    On Error GoTo bad_value
    Value = CCur(DeliveryValue.Text)
    
    On Error GoTo bad_price
    Price = CCur(DeliveryPrice.Text)
    
    On Error GoTo bad_value
    Volume = CCur(DeliveryVolume.Text)
    
        ' ensure that they have entered at least a $1 amount
    If Value < 1# And Volume < 1# Then
        MsgBox "Please enter a value or volume amount first.", vbExclamation
        Exit Sub
    End If

    ' log manual delivery, if we dont send the price then the pump server will
    ' use the current price configured for that hose
    result = MainForm.Pump(ManualPump).LogManualDelivery(1, Value, Volume, Price, 1, 0, 0)
    
    ' check result, if not Okay then display error string
    ' as retrieved from session object
    If result <> OK_RESULT Then
        MsgBox MainForm.Session.ResultString(result), vbExclamation
        Exit Sub
    End If
    
    Hide
    Exit Sub
    
bad_value:
    MsgBox "Invalid delivery value, please re-enter.", vbExclamation
    Exit Sub
    
bad_volume:
    MsgBox "Invalid delivery volume, please re-enter.", vbExclamation
    Exit Sub
    
bad_price:
    MsgBox "Invalid delivery price, please re-enter.", vbExclamation
    Exit Sub

End Sub
