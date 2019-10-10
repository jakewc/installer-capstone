VERSION 5.00
Begin VB.Form TraceForm 
   Caption         =   "Pump Trace"
   ClientHeight    =   2505
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   9270
   Icon            =   "TraceForm.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   2505
   ScaleWidth      =   9270
   StartUpPosition =   1  'CenterOwner
   Begin VB.TextBox TraceEdit 
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   2415
      HideSelection   =   0   'False
      Left            =   0
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   0
      Top             =   0
      Width           =   9015
   End
End
Attribute VB_Name = "TraceForm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

'*****************************************************************
'*
'* Copyright (C) 2006 Integration Technologies Limited
'* All rights reserved.
'*
'* This form shows tracing of pump events
'*
'******************************************************************

Option Explicit

Public SelectedPump As Integer

Public Sub SelectPump(Pump As Integer)
    SelectedPump = Pump
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, unloadmode As Integer)
    SelectedPump = 0
End Sub

Public Sub TraceText(ByVal Text As String)
    Dim Savetext As String
    
    If Not TraceForm.Visible Then
        Exit Sub
    End If
    
    ' Truncate if getting too big ( max 64K)
    If Len(TraceEdit.Text) > 64000 Then
        TraceEdit.Text = Right(TraceEdit.Text, 32000)
    End If
    
    TraceEdit.SelLength = 0
    TraceEdit.SelStart = Len(TraceEdit.Text)
    TraceEdit.SelText = FormatLogTime(Timer) & " " & Text & vbCrLf
    
End Sub

Private Sub Form_Resize()
    TraceEdit.Left = 0
    TraceEdit.Width = ScaleWidth
    TraceEdit.Top = 0
    TraceEdit.Height = ScaleHeight
End Sub

Private Function FormatLogTime(Time As Single) As String

    Dim Hours As Single
    Dim Minutes As Single
    Dim Seconds As Single
    
    Hours = Int(Time / 3600)
    Minutes = Int(Time / 60) - Hours * 60
    Seconds = Time - Hours * 3600 - Minutes * 60
    
    FormatLogTime = Format(Hours, "00") _
        & ":" & Format(Minutes, "00") _
        & ":" & Format(Seconds, "00.000")
        
End Function

Public Sub TracePump(ByVal PumpNumber As Long, ByVal Text As String)
    If SelectedPump <> 0 And SelectedPump <> PumpNumber Then
        Exit Sub
    End If
    TraceText "Pump " & Format(PumpNumber, "00") & " " & Text
End Sub

' Prints information about the delivery to the trace window,
' Requires Enabler 3.75.0 or newer to use the Del.ValueTotal and
' Del.VolumeTotal methods which contain the pumps meter totals
' at the time of the delivery finishing.
Public Sub TraceDelivery(ByVal PumpNumber As Long, Del As Delivery, ByVal LeadText As String)
    
    Dim Price1 As Currency
    Dim Value1 As Currency
    Dim Volume1 As Currency
    Dim Price2 As Currency
    Dim Value2 As Currency
    Dim Volume2 As Currency
    Dim Ratio As Currency
 
    
    If SelectedPump <> 0 And SelectedPump <> PumpNumber Then
        Exit Sub
    End If

    If Del.Type = AVAILABLE_PREPAY_REFUND_DELIVERY Then
        TracePump PumpNumber, _
            LeadText & _
            " ID " + Format(Del.ID) & _
            " Prepay Refund " + Format(Del.Value, "currency")
    Else
        Del.GetPostMixSummary Volume1, Value1, Volume2, Value2, Price1, Price2, Ratio
        ' Normal delivery
        TracePump PumpNumber, _
            LeadText & _
            " ID " + Format(Del.ID) & _
            " Price " + Format(Del.UnitPrice) & _
            " Value " + Format(Del.Value, "currency") & _
            " Volume " + Format(Del.Volume, "fixed") & _
            " ValueTotal " + Format(Del.ValueTotal, "currency") & _
            " VolumeTotal " + Format(Del.VolumeTotal, "fixed") & _
            " PriceLevel " + Format(Del.PriceLevel)
        
        If Price2 <> 0 Then
            ' Blended delivery
            TracePump PumpNumber, _
                "Blended from :" & _
                " Ratio " + Format(Ratio, "fixed") & _
                " Price1 " + Format(Price1) & _
                " Value1 " + Format(Value1, "currency") & _
                " Volume1 " + Format(Volume1, "fixed") & _
                " Price2 " + Format(Price2) & _
                " Value2 " + Format(Value2, "currency") & _
                " Volume2 " + Format(Volume2, "fixed") & _
                " PriceLevel " + Format(Del.PriceLevel)
        End If
    End If




End Sub

