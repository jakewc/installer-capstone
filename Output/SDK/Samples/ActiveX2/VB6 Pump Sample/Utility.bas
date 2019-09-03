Attribute VB_Name = "Utility"
'*****************************************************************
'*
'* Copyright (C) 2006 Integration Technologies Limited
'* All rights reserved.
'*
'* This is a module to contain handy utility functions
'*
'******************************************************************
Option Explicit

'******************************************************************/
'*
'* Get a 'bitmap' that indicates the selected hoses
'* in a listbox
'*
'******************************************************************/
Public Function GetHoseBitmap(HoseList As ListBox) As Integer

Dim i As Integer
Dim Bitmap As Integer

    Bitmap = 0
    For i = 0 To HoseList.ListCount - 1
        If HoseList.Selected(i) Then
            Bitmap = Bitmap + 2 ^ i
        End If
    Next i
    
    GetHoseBitmap = Bitmap
    
End Function

