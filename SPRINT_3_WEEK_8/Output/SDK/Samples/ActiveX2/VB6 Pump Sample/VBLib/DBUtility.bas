Attribute VB_Name = "DBUtility"
Public Const DeadLockVictimError As Integer = 1205

'   We have catered for two password becuase we have 2 scenarios, they are:
'   1. Database is MSDE 2000 or SQL Server 2000,
'   2. Database is SQL Server 2005+2008 Standard or Express Editions,
'   therefore we'll limit the login attempts using this constant,
'   so endless attempts are not made, which may looks like a freeze.
Public Const MAX_DB_LOGIN_ATTEMPTS_ALLOWED = 2

' Forces a decimal separator to be a point,
' so that it can se used as part of a SQL statement
' Example: Italian 0,949 becomes 0.949
Function FormatNumberToSQL(Number) As String

    Dim sReturn As String
    
    If IsNumeric(Number) Then
        sReturn = FormatNumber(Number, 4, vbTrue, vbFalse, vbFalse)
        sReturn = Replace(sReturn, ",", ".")
        FormatNumberToSQL = sReturn
    Else
        FormatNumberToSQL = "0"
    End If

End Function

' Try to update the records in a data control
' If retries once every half second up to 10 times or until successful
' If it does not succeed, raises an error
Function UpdateRecord(oDataSource As Data) As Boolean

    On Error GoTo Err_UpdateRecord:
    
    Dim iCount As Integer
    
    ' Try the update
    oDataSource.UpdateRecord
    
    UpdateRecord = True
    
End_UpdateRecord:
    
    Exit Function

Err_UpdateRecord:

    If Err.Number = 524 Or Err.Number = 3197 Then
        Debug.Print "Error " & Err.Number & " caught"
        iCount = iCount + 1
        If iCount < 10 Then
            Debug.Print "Will retry in 1/2s"
            Sleep 500
            Debug.Print "Retrying"
            Resume
        Else
            UpdateRecord = False
            Resume End_UpdateRecord
        End If
    Else
        UpdateRecord = False
        Resume End_UpdateRecord
    End If

End Function

#If USE_RDO = 1 Then
' StoredProcedureParamCount
' Returns the number of parameters in a stored procedure
' Uses the microsoft SQL sp sp_procedure_params_rowset
Function StoredProcedureParamCount(dbconnect As rdoConnection, sp_name As String) As Integer

    Dim mSQL As String
    Dim SP As rdoQuery
    Dim Results As rdoResultset
    
    mSQL = "exec sp_procedure_params_rowset " & "'" & sp_name & "'"
   Set SP = dbconnect.CreateQuery("ProcedureParamCount", mSQL)
   Set Results = SP.OpenResultset(rdOpenStatic)
   StoredProcedureParamCount = Results.RowCount
   SP.Close
 
End Function

' StoredProcedureParamExists
' Returns whether a parameter in the stored procedure exits or not
' Adds the '@' to the front of the parameter name
' Uses the microsoft SQL sp sp_procedure_params_rowset
Function StoredProcedureParamExists(dbconnect As rdoConnection, spName As String, paramName As String) As Boolean

    Dim mSQL As String
    Dim SP As rdoQuery
    Dim Results As rdoResultset

    StoredProcedureParamExists = False
       
    mSQL = "exec sp_procedure_params_rowset '" & spName & "', DEFAULT, DEFAULT, '@" & paramName & "'"
    Set SP = dbconnect.CreateQuery("ProcedureParamExists", mSQL)
    Set Results = SP.OpenResultset(rdOpenStatic)
    StoredProcedureParamExists = Not Results.EOF
    SP.Close

End Function

' GetSQLDateTime
' Returns the getDate() fromn the SQL server in the ISO8601 format yyyy-mm-ddThh:mi:ss.mmm(24h)
' ISO8601 forces a Gregorian calender.  The date is then formatted to vb friendly as yyyy-mm-dd hh:mi:ss
' Returns as a string to prevent any conversion at this end
' This function is useful to get a locale independant date and time - eg thai systems
Function GetSQLDateTime(dbconnect As rdoConnection) As String

    Dim Query As rdoQuery
    Dim Res As rdoResultset
    Dim SQL As String
    Dim DateTime As String
    
    GetSQLDateTime = ""
    SQL = "SELECT CONVERT(char, getdate(), 126) as CurrentDateTime"
    Set Query = dbconnect.CreateQuery("", SQL)
    Set Res = Query.OpenResultset(rdOpenStatic)
    If Not Res.EOF Then
        DateTime = CStr(Res.rdoColumns("CurrentDateTime"))
        DateTime = Trim(Replace(DateTime, "T", " "))
        GetSQLDateTime = Mid(DateTime, 1, Len(DateTime) - 4)
    End If
    Query.Close
    
End Function

'just log RDO error details without a message box.
Public Sub LogRdoError(ErrText As String)

    Dim er As rdoError

    LogException (ErrText)

    For Each er In rdoErrors
        ' 5701 and 5703 are harmless post connection messages
        If (er.Number = 5701) Or (er.Number = 5703) Then
            LogException ("Message Number: " & er.Number & " " & er.Description)
        Else
            LogException ("Error Number: " & er.Number & " " & er.Description)
        End If
    Next er

End Sub

' This function returns the version number of the Microsoft SQL server in use
' The returned type is integer
' Return values:
'   0 = could not connect OR query failed
'   7 = SQL7.0
'   8 = SQL 2000
'   9 = SQL 2005
'  10 = SQL 2008

Public Function SQL_Version_RDO(dbconnect As rdoConnection) As Integer


    Dim Query As rdoQuery
    Dim Res As rdoResultset
    Dim SQL As String
    Dim DateTime As String
    
    SQL_Version_RDO = 0
    
    SQL = "SELECT @@microsoftversion / 0x01000000 as Version"
    
    Set Query = dbconnect.CreateQuery("SQL_Version_Query", SQL)
    
    Set Res = Query.OpenResultset(rdOpenFowardOnly)
    
    If Not Res.EOF Then
        SQL_Version_RDO = Res.rdoColumns("Version").Value
    End If
    
    Query.Close

End Function

' Queries the Interface_File_Mask table for the filemask type.
' Does not do any parsing of the file mask

Public Function GetPlainFileMaskFromInterfaceFileMask(ByVal dbconnect As rdoConnection, ByVal FileMaskType As String, ByRef FilePath As String) As Boolean

    Dim Query As rdoQuery
    Dim Res As rdoResultset
    Dim SQL As String
    Dim Folder As String
    Dim Mask As String
    
    GetPlainFileMaskFromInterfaceFileMask = False
    
    On Error GoTo DBErr_
    
    SQL = "SELECT Mask, Folder FROM Interface_File_Mask WHERE Mask_Type = '" & CStr(FileMaskType) & "'"
    
    Set Query = dbconnect.CreateQuery("FileMaskFolder", SQL)
    
    Set Res = Query.OpenResultset(rdOpenFowardOnly)
    
    If Not Res.EOF Then
    
        If Not IsNull(Res.rdoColumns("Folder")) Then
            Folder = Res.rdoColumns("Folder")
        End If
        
        Folder = Trim(Folder)
        
        If Folder <> "" Then
            ' Ensure slash on end of folder path
            If Right(Folder, 1) <> "\" Then
                Folder = Folder & "\"
            End If
        End If
        
        Mask = Res.rdoColumns("Mask")
        
        Mask = Trim(Mask)
        
        FilePath = Folder & Mask
        
        GetPlainFileMaskFromInterfaceFileMask = True
    End If
    
    Query.Close

    Exit Function
    
DBErr_:
    
    LogRdoError "Error geting file mask for file mask type: " & CStr(FileMaskType)
    GetPlainFileMaskFromInterfaceFileMask = False

End Function


#End If 'USE_RDO

' CreateSQLDateTime
' Returns style 126 SQL date/time format which is safe from regional settings.
' Style 126: yyyy-mm-ddThh:mi:ss.mmm (no spaces) - ISO8601
Function CreateSQLDateTime(DateTime As Date) As String
    
    ' Note: VB Date sone't include milliseconds, so set to .000
    
    CreateSQLDateTime = CStr(Format(DateTime, "yyyy")) & "-" & _
                        CStr(Format(DateTime, "mm")) & "-" & _
                        CStr(Format(DateTime, "dd")) & "T" & _
                        CStr(Format(DateTime, "Hh")) & ":" & _
                        CStr(Format(DateTime, "Nn")) & ":" & _
                        CStr(Format(DateTime, "Ss")) & ".000"
                        
                     
End Function


' Returns the string that must be used to call a SP
' Example: { call sp_log_transaction (?, ..., ?) }
Function SPCallingSkeleton(ByVal spName As String, ByVal NumParams As Integer, Optional HasReturn As Boolean = False) As String

    Dim SQL As String
    Dim i As Integer
    
    SQL = "{ "
    
    If HasReturn Then
        SQL = SQL & "? = "
    End If
    
    SQL = SQL & " call " & spName & "(?"
    For i = 2 To NumParams - 1
        SQL = SQL & ", ?"
    Next
    SQL = SQL & ") }"
    
    SPCallingSkeleton = SQL

End Function


#If USE_ADODB = 1 Then

' This function returns the version number of the Microsoft SQL server in use
' The returned type is integer
' Return values:
'   0 = could not connect OR query failed
'   7 = SQL7.0
'   8 = SQL 2000
'   9 = SQL 2005
'  10 = SQL 2008
' Limitation: requires sa login to query the information
' Note: this function is not currently in use
Public Function SQL_Version(ByVal Password As String) As Integer

    Dim RecordSet As New ADODB.RecordSet               'ADO objects initialized
    Dim connection As New ADODB.connection
    Dim affected As Long                               ' Number of affected records after each SQL query
        
    On Error GoTo sql_error
    
        With connection                                ' Open the connection to the database
            .Provider = "MSDASQL"                      ' Provider
            .Properties("Data Source") = "enabler"     '
            .Properties("User Id") = "sa"              ' Login as sa
            .Properties("Password") = Password         '
            .CursorLocation = adUseClient              ' Recordset resides locally
            .Open
        End With
        
        Set RecordSet = connection.Execute("select @@microsoftversion / 0x01000000", affected)  ' SQL statement that gets version No.
        SQL_Version = Trim(RecordSet.fields.Item(0).Value)   ' Get the value wanted from recordset
        

        If RecordSet.State = adStateOpen Then 'Close connection if it's opened
            RecordSet.Close
        End If
        Set RecordSet = Nothing               'Destroy connection object
        
        If connection.State = adStateOpen Then 'Close connection if it's opened
            connection.Close
        End If
        Set connection = Nothing               'Destroy connection object


        Exit Function
        
sql_error:

        SQL_Version = 0                       ' Return 0 to signal query failing

        MsgBox Err.Description
        
        If RecordSet.State = adStateOpen Then 'Close connection if it's opened
            RecordSet.Close
        End If
        Set RecordSet = Nothing               'Destroy connection object
        
        If connection.State = adStateOpen Then 'Close connection if it's opened
            connection.Close
        End If
        Set connection = Nothing               'Destroy connection object


End Function



Public Function ADODB_CheckFieldExists(reqTableName As String, reqColName As String) As Boolean

    Dim RecordSet As New ADODB.RecordSet               'ADO objects initialized
    Dim connection As New ADODB.connection
    Dim affected As Long
    Dim SQL As String
    Dim ConnectionStr As String
    Dim PasswordID As Integer
    Dim EnablerPassword As String
    
    On Error GoTo DBConnectError
    
    PasswordID = 1
                           
ConnectToDatabase:
        
    #If ENABLE_PCIDSS = 1 Then
    ConnectionStr = "DSN=Enabler;Trusted_Connection=yes;"
    #Else
    EnablerPassword = GetEnablerSQLPassword(PasswordID)
    If EnablerPassword = "" Then
        LogTrace "Could not login to SQL Database Server"
        MsgBox LoadResString(10013) + " !!! ", vbExclamation + vbOKOnly, frmAbout.GetTitle
        End
    Else
        ConnectionStr = "DSN=enabler;UID=enabler;PWD=" + EnablerPassword + ";APP=Visual Basic;"
    End If
    #End If
               
    connection.ConnectionTimeout = 10
    connection.CursorLocation = adUseClient
    connection.Open ConnectionStr
    
    On Error GoTo sql_error_checkfield
    
        SQL = "SELECT count(column_name) ReqC FROM INFORMATION_SCHEMA.COLUMNS where column_name = '"
        SQL = SQL + reqColName + "' and table_name = '" + reqTableName + "'"
        Set RecordSet = connection.Execute(SQL, affected)    ' SQL statement that gets version No.
        If RecordSet.fields.Item(0).Value >= 1 Then
            ADODB_CheckFieldExists = True
        Else
            ADODB_CheckFieldExists = False
            LogTrace "ADODB_CheckFieldExists Error: Missing Field " + reqColName + " in Table " + reqTableName
        End If
        
        GoTo skip_sql_error_checkfield
        
sql_error_checkfield:

        ADODB_CheckFieldExists = False
        'log some error here
        LogTrace ("ADODB_CheckFieldExists Fault Error")
        
skip_sql_error_checkfield:

        If RecordSet.State = adStateOpen Then 'Close connection if it's opened
            RecordSet.Close
        End If
        Set RecordSet = Nothing               'Destroy connection object
        
        If connection.State = adStateOpen Then 'Close connection if it's opened
            connection.Close
        End If
        Set connection = Nothing               'Destroy connection object

        Exit Function
        
DBConnectError:
        PasswordID = PasswordID + 1
        Resume ConnectToDatabase

End Function

#End If

' for compatibility with SQL 2005+ we have changed our enabler database user password,
' this function allows applications to get the defined passwords to connect to the
' database.  The passwords are not stored as a string to obscure them slightly when
' you look inside the executable at the list of strings
' return - the password string
'        - if the PasswordID is not recognised the returned string will be blank
Public Function GetEnablerSQLPassword(PasswordID As Integer) As String

    Select Case PasswordID
        Case 1 ' original password
            ' used for MSDE, MSDE2000
            GetEnablerSQLPassword = "e" & Chr(110) & Chr(97) & Chr(98) _
                                    & Chr(108) & Chr(101) & Chr(114)
            
        Case 2 ' password added for SQL2005 compatibility
            GetEnablerSQLPassword = "E" & Chr(110) & Chr(52) & Chr(98) _
                                    & Chr(108) & Chr(51) & Chr(114)
        
        ' add new passwords if necessary for future SQL Server versions
        
        Case Else
            GetEnablerSQLPassword = ""
            
    End Select
    
End Function

