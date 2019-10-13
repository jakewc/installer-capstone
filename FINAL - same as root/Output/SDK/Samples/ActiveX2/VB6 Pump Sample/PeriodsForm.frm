VERSION 5.00
Begin VB.Form PeriodsForm 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Report Periods"
   ClientHeight    =   2805
   ClientLeft      =   45
   ClientTop       =   345
   ClientWidth     =   3285
   ControlBox      =   0   'False
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2805
   ScaleWidth      =   3285
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton CancelButton 
      Cancel          =   -1  'True
      Caption         =   "Close"
      Height          =   615
      Left            =   240
      TabIndex        =   2
      Top             =   2040
      Width           =   1095
   End
   Begin VB.CommandButton CloseButton 
      Caption         =   "Close Selected Period Type"
      Height          =   615
      Left            =   1440
      TabIndex        =   1
      ToolTipText     =   "Click to close the period type selected  in the list above"
      Top             =   2040
      Width           =   1575
   End
   Begin VB.ListBox PeriodList 
      Height          =   1425
      Left            =   360
      TabIndex        =   0
      Top             =   480
      Width           =   2535
   End
   Begin VB.Label PeriodLabel 
      Caption         =   "Select period to be closed:"
      Height          =   255
      Left            =   360
      TabIndex        =   3
      Top             =   120
      Width           =   2415
   End
End
Attribute VB_Name = "PeriodsForm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'*****************************************************************
'*
'* Copyright (C) 2004 Integration Technologies Limited
'* All rights reserved.
'*
'* This dialog demonstrates how to close periods in The Enabler
'* database - this code uses the Microsoft Remote Data Object, so
'* use this code in an existing application you may need to add
'* this to the list in VB Project -> References... menu
'*
'******************************************************************/

Option Explicit

Public enablerrdocn As New rdoConnection

Private Sub CancelButton_Click()
    Hide
End Sub

Private Sub CloseButton_Click()

Dim SQL As String
Dim SP As rdoQuery
Dim Results As rdoResultset
Dim PeriodType As Integer
Dim PeriodName As String
    
    ' get the period type and name from the listbox
    PeriodType = PeriodList.ItemData(PeriodList.ListIndex)
    PeriodName = PeriodList.List(PeriodList.ListIndex)
    
    ' TODO in a real POS application you might want to:
    ' - check that any oustanding sales are completed
    ' - display details of the actual period being closed (from periods table)
    ' - confirm that the operator is sure they want to close
    ' - make some record of who closed the period
    ' - maybe print a receipt as confirmation
    
    ' now close the selected period type
    On Error GoTo SQLError
    SQL = "{ call sp_close_period( ? ) }"
    
    Set SP = enablerrdocn.CreateQuery("ClosePosPeriod", SQL)
    SP.rdoParameters(0) = PeriodType
    Set Results = SP.OpenResultset(rdOpenStatic)
    SP.Close
    On Error GoTo 0
    
    ' display a confirmation message box
    MsgBox "Period '" & Trim(PeriodName) & "' closed ok", vbInformation, Caption
    
    Exit Sub
    
SQLError:
    MsgBox "Could not close the specified period type", vbOKOnly, "Database error"
    
End Sub

Private Sub Form_Load()
    
Dim SQL As String
Dim SP As rdoQuery
Dim Results As rdoResultset
Dim PeriodName As String
Dim PeriodType As Integer
Dim ConnectionStr_RDO As String

    ConnectionStr_RDO = "DSN=enabler;Trusted_Connection=yes;"
    ' connect to the Enabler Database
    With enablerrdocn
       .LoginTimeout = 40
       .Connect = ConnectionStr_RDO
       .CursorDriver = rdUseOdbc
       .EstablishConnection rdDriverNoPrompt
       .QueryTimeout = 30
    End With

    On Error GoTo SQLError
    ' get a list of the period types setup in the database
    SQL = "SELECT period_type, period_name FROM period_types order by period_type"
    Set SP = enablerrdocn.CreateQuery("QueryPeriodTypes", SQL)
    Set Results = SP.OpenResultset(rdOpenStatic)
    On Error GoTo 0
    
    PeriodList.Clear
    CloseButton.Enabled = False
    
    While Not Results.EOF
        ' add the period types to our list box
        PeriodName = Results.rdoColumns("period_name")
        PeriodType = Results.rdoColumns("period_type")
        PeriodList.AddItem PeriodName
        
        ' store the period_type using List.ItemData
        PeriodList.ItemData(PeriodList.NewIndex) = PeriodType
        
        ' go to next record
        Results.MoveNext
        
        ' there is at least one period type, so we can enable the close button
        CloseButton.Enabled = True
    Wend
    
    SP.Close
    
    ' select first item in the list by default
    PeriodList.ListIndex = 0
    
    Exit Sub
    
SQLError:
    MsgBox "Could not get the list of the period types (from the database)", vbOKOnly, "Database error"
    
End Sub
