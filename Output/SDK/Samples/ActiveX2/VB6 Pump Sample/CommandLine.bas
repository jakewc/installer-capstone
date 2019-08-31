Attribute VB_Name = "CommandLine"
Option Explicit

'*****************************************************************
'*
'* Pumpdemo command line processing
'*
'* Copyright (C) 2007 Integration Technologies Limited
'* All rights reserved.
'*
'* Contains some utility procedures for handling command-line
'* parameters to pumpdemo. Likely you will not need these in a real
'* POS application
'*
'******************************************************************

'******************************************************************
'*
'*  ShowUsage - display command line parameters
'*              and end the program
'*
'******************************************************************

Public Sub ShowUsage(ErrorMessage As String)

Dim Message As String

    If ErrorMessage <> "" Then
        Message = ErrorMessage & vbLf & vbLf
    End If
    
    Message = Message _
           & "Usage: PumpDemo [TerminalID] [/trace] [/sync] [/clearpumps]" & vbLf _
           & vbLf _
           & "TerminalID - terminal number to logon with (1 or more)" & vbLf _
           & "/trace - trace pump events at startup" _
           & vbLf _
           & "/sync  - synchronise on logon (release reserves and deliveries)" & vbLf _
           & "/clearpumps - clear stucked prepay/preauth delivery and clear reserved pumps"
           
    MsgBox Message, _
           vbExclamation + vbOKOnly, _
           "POS Demo"
    End
    
End Sub

'******************************************************************
'*
'*  ProcessCommandLine - process parameters set on command line (if any)
'*  This allows you to use a parameter to change terminal ID,
'*  but for a real application you should use a defined terminal ID
'*  since that determines ownership of pumps and deliveries
'*
'******************************************************************

Public Sub ProcessCommandLine(ByRef TerminalID As Long, _
                               ByRef TracePumps As Boolean, _
                               ByRef SyncFlag As Boolean, _
                               ByRef ClearFlag As Boolean)

Dim Parameters() As String
Dim Parameter As String
Dim i As Integer

    Parameters = Split(Command(), " ") ' get parameters as array
        
    On Error GoTo InvalidParameter

    TracePumps = False
    SyncFlag = False
    TerminalID = -1 ' terminal is unknown so far
    
    For i = 0 To UBound(Parameters)
        ' process each parameter in order
        Parameter = LCase(Parameters(i))
        
        If Parameter = "/?" Then
            ' standard windows parameter for showing command line usage
            ShowUsage ""
        ElseIf Parameter = "/trace" Then
            ' for tracing startup events
            TracePumps = True
        ElseIf Parameter = "/sync" Then
            ' for releasing reserves and deliveries (ES-2083)
            SyncFlag = True
        ElseIf Parameter = "/clearpumps" Then
            SyncFlag = True
            ClearFlag = True
        ElseIf TerminalID = -1 Then
            ' terminal not yet assigned; get it from this parameter
            TerminalID = Val(Parameter)
            If TerminalID < 1 Then
                ' terminal out of range
                ShowUsage "Invalid TerminalID '" & Parameter & "'"
            End If
        Else
            ' too many or unknown parameter
            ShowUsage "Unknown parameter '" & Parameter & "'"
        End If
    Next i
            
    If TerminalID = -1 Then
        ' use default terminal
        TerminalID = 1
    End If
    
    ' parameters processed OK.
    Exit Sub
        
InvalidParameter:
    ShowUsage "'" & Err.Description & "'"
    End

End Sub


