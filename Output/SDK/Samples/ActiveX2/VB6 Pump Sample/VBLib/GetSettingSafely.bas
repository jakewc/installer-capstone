Attribute VB_Name = "GetSettingSafely"
Option Explicit

' Get a Boolean.
Public Function GetSettingBoolean(ByVal AppName As String, ByVal Section As String, ByVal Key As String, ByVal default_value As Boolean) As Boolean
    On Error Resume Next
    GetSettingBoolean = CBool(GetSetting(AppName, Section, Key, default_value))
    If Err.number <> 0 Then GetSettingBoolean = default_value
    Err.Clear
End Function

' Get a Boolean with optional extra values.
' Note that optional values in VB 6 must be Variants or intrinsic values
' so here true_values and false_values are assuemd to be variant arrays.
Public Function GetSettingBooleanExtras(ByVal AppName As String, ByVal Section As String, ByVal Key As String, ByVal default_value As Boolean, Optional true_values As Variant, Optional false_values As Variant) As Boolean
Dim txt As String
Dim i As Integer

    txt = GetSetting(AppName, Section, Key, default_value)

    ' Check for extra values.
    If Not IsMissing(true_values) Then
        For i = LBound(true_values) To UBound(true_values)
            If LCase$(txt) = LCase$(true_values(i)) Then
                GetSettingBooleanExtras = True
                Exit Function
            End If
        Next i
    End If
    If Not IsMissing(false_values) Then
        For i = LBound(false_values) To UBound(false_values)
            If LCase$(txt) = LCase$(false_values(i)) Then
                GetSettingBooleanExtras = False
                Exit Function
            End If
        Next i
    End If

    ' Try to convert whatever we got from the Registry.
    On Error Resume Next
    GetSettingBooleanExtras = CBool(txt)
    If Err.number <> 0 Then GetSettingBooleanExtras = default_value
    Err.Clear
End Function

' Get an Integer.
Public Function GetSettingInteger(ByVal AppName As String, ByVal Section As String, ByVal Key As String, ByVal default_value As Integer) As Integer
    On Error Resume Next
    GetSettingInteger = CInt(GetSetting(AppName, Section, Key, default_value))
    If Err.number <> 0 Then GetSettingInteger = default_value
    Err.Clear
End Function

' Get a String.
Public Function GetSettingString(ByVal AppName As String, ByVal Section As String, ByVal Key As String, ByVal default_value As String) As String
    On Error Resume Next
    GetSettingString = CStr(GetSetting(AppName, Section, Key, default_value))
    If Err.number <> 0 Then GetSettingString = default_value
    Err.Clear
End Function

' Get a Long.
Public Function GetSettingLong(ByVal AppName As String, ByVal Section As String, ByVal Key As String, ByVal default_value As Long) As Long
    On Error Resume Next
    GetSettingLong = CLng(GetSetting(AppName, Section, Key, default_value))
    If Err.number <> 0 Then GetSettingLong = default_value
    Err.Clear
End Function

' Get a Double.
Public Function GetSettingDouble(ByVal AppName As String, ByVal Section As String, ByVal Key As String, ByVal default_value As Double) As Double
    On Error Resume Next
    GetSettingDouble = CDbl(GetSetting(AppName, Section, Key, default_value))
    If Err.number <> 0 Then GetSettingDouble = default_value
    Err.Clear
End Function

' Get a Date.
Public Function GetSettingDate(ByVal AppName As String, ByVal Section As String, ByVal Key As String, ByVal default_value As Date) As Date
    On Error Resume Next
    GetSettingDate = CDate(GetSetting(AppName, Section, Key, default_value))
    If Err.number <> 0 Then GetSettingDate = default_value
    Err.Clear
End Function

' Get a currency
Public Function GetSettingCurrency(ByVal AppName As String, ByVal Section As String, ByVal Key As String, ByVal default_value As Currency) As Currency
    On Error Resume Next
    GetSettingCurrency = CCur(GetSetting(AppName, Section, Key, default_value))
    If Err.number <> 0 Then GetSettingCurrency = default_value
    Err.Clear
End Function
