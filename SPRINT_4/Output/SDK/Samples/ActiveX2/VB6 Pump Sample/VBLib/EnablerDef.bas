Attribute VB_Name = "EnablerDef"
'*****************************************************************
'*
'* Copyright (C) 1997-2003 Integration Technologies Limited
'* All rights reserved.
'*
'* Created 26/03/2003
'*
'* This is the Visual Basic equivilant definitions of Pump
'* constants that are defined in pumpdef.h
'*
'******************************************************************/

Option Explicit


' Method Result codes, returned when EnbPumpX or EnbSessionX
' methods fail. A text description of these can be obtained
' from the SessionX control Result string property.

Enum MethodResults
    OK_RESULT ' 0
    DELIVERY_ALREADY_LOCKED_RESULT ' 1
    DELIVERY_NOT_LOCKED_RESULT ' 2
    DELIVERY_NOT_LOCKED_BY_YOU_RESULT ' 3
    CANNOT_CLEAR_DELIVERY_TYPE_RESULT ' 4
    SESSION_ALREADY_LOGGED_ON_RESULT ' 5
    TERMINAL_ID_ALREADY_LOGGED_ON_RESULT ' 6
    NOT_LOGGED_ON_RESULT ' 7
    BAD_TERMINAL_NUMBER_RESULT ' 8
    STACKING_NOT_ALLOWED_RESULT ' 9
    NO_CURRENT_DELIVERY_RESULT ' 10
    STACK_FULL_RESULT ' 11
    PUMP_NOT_INSTALLED_RESULT ' 12
    PUMP_NOT_RESPONDING_RESULT ' 13
    HAS_CURRENT_DELIVERY_RESULT ' 14
    PUMP_IS_RESERVED_RESULT ' 15
    NOT_RESERVED_FOR_PREPAY_RESULT ' 16
    NOT_RESERVED_BY_YOU_RESULT ' 17
    INVALID_HOSE_NUMBER_RESULT ' 18
    INVALID_LIMIT_RESULT ' 19
    INVALID_PUMP_NUMBER_RESULT ' 20
    DELIVERY_ALREADY_RESERVED_RESULT ' 21
    CANT_STACK_DELIVERY_TYPE_RESULT ' 22
    PUMP_NOT_AVAILABLE_RESULT ' 23
    POSTPAYS_NOT_ALLOWED_RESULT ' 24
    PREPAYS_NOT_ALLOWED_RESULT ' 25
    PREAUTHS_NOT_ALLOWED_RESULT ' 26
    NOT_RESERVED_RESULT ' 27
    NOT_CONNECT_TO_PSRVR_RESULT ' 28
    ERROR_WITH_PSRVR_RESULT ' 29
    RESERVES_REMOVED_RESULT ' 30
    LOCKS_REMOVED_RESULT ' 31
    RESERVES_AND_LOCKS_REMOVED_RESULT ' 32
    PSRVR_FORCED_LOGOFF_RESULT ' 33
    PREAUTH_LOCK_FOUND_RESULT ' 34
    DELIVERY_ALREADY_LOCKED_BY_YOU_RESULT ' 35
    ERROR_OPENING_EVENTS_PIPE_RESULT ' 36
    TOO_MANY_PUMPS_DELIVERYING_RESULT ' 37
    ATTENDANT_ALREADY_LOGGED_ON_RESULT ' 38
    PUMP_ALREADY_LOGGED_ON_RESULT ' 39
    PUMP_NOT_LOGGED_ON_RESULT ' 40
    ATTENDANT_NOT_LOGGED_ON_TO_PUMP_RESULT ' 41
    ATTENDANT_MODE_NOT_PERMITTED_RESULT ' 42
    ATTENDANT_NOT_LOGGED_ON_RESULT ' 43
    PUMP_NOT_MECHANICAL_RESULT ' 44
    BAD_DELIVERY_DATA_RESULT ' 45
    DELIVERY_NOT_FOUND_RESULT ' 46
    CANNOT_FREE_CURRENT_DELIVERY_RESULT ' 47
    PSRVR_ON_BATTERY_RESULT ' 48
    PSRVR_ON_MAINS_RESULT ' 49
    TERMINAL_ON_BATTERY_RESULT ' 50
    TERMINAL_ON_MAINS_RESULT ' 51
    PRESET_NOT_SUPPORTED_RESULT ' 52
    INCOMPATIBLE_PSRVR_RESULT ' 53
    LIMITATION_TOO_SMALL_RESULT  ' 54
    LIMITATION_EXCEEDS_ALLOCATION_LIMIT ' 55
    PRICE_LEVEL_NOT_SUPPORTED_BY_PUMP_RESULT ' 56
    OPT_NOT_CLAIMED ' 57
    PSRVR_RECONNECTED_RESULT ' 58
    ID_NOT_MATCHED_RESULT '59
    INCORRECT_PASSWORD_RESULT ' 60
    ATTENDANT_STILL_LOGGED_ON_RESULT ' 61
    NOT_IMPLEMENTED_RESULT ' 62
    ATTENDANT_PERIOD_NOT_CLOSED_RESULT ' 63
    ATTENDANT_HAS_DELIVERIES_RESULT ' 64
    ATTENDANT_NOT_FOUND_RESULT ' 65
    ATTENDANT_PERIOD_NOT_RECONCILED_RESULT ' 66
    ATTENDANT_HAS_NO_INITIAL_FLOAT_RESULT ' 67
    CANNOT_CANCEL_PREAUTH_DURING_DELIVERY_RESULT ' 68
    NOT_SUPPORTED_BY_PUMP_RESULT ' 69
    EXCEPTION_RESULT ' 70
    PRICE_CHANGE_PENDING_RESULT    ' 71
    PSRVR_NOT_READY_RESULT         ' 72
    PSRVR_DATABASE_ERROR_RESULT    ' 73
    MAX_RESULTS
End Enum

' Definitions for EnbPumpX methods

' Authorsation types Pump.AuthorisePreset(), Pump.AuthorisePreauth() etc.
Enum AllocationLimitTypes
    NO_LIMIT ' 0
    VALUE_ALLOCATION_LIMIT  ' 1 - obsolete
    VOLUME_ALLOCATION_LIMIT ' 2 - obsolete
    VALUE_PREPAY_LIMIT ' 3
    VALUE_PREAUTH_LIMIT ' 4
    VALUE_PRESET_LIMIT ' 5
    VOLUME_PRESET_LIMIT ' 6
End Enum

' For backwards compatibility
Const PREPAY_LIMIT As Long = VALUE_PREPAY_LIMIT
Const PREAUTH_LIMIT As Long = VALUE_PREAUTH_LIMIT
' Note at this time, the Enabler does not support volume prepay or preauth

' Values for EnbPumpX.State - indicates the current pump status
Enum PumpStates
    UNKNOWN_PSTATE ' 0
    NOT_INSTALLED_PSTATE ' 1
    NOT_RESPONDING_PSTATE ' 2
    LOCKED_PSTATE ' 3
    IDLE_PSTATE ' 4
    CALLING_PSTATE ' 5
    TEMP_STOPPED_PSTATE ' 6
    RESERVED_FOR_PREPAY_PSTATE ' 7
    RESERVED_FOR_PREAUTH_PSTATE ' 8
    AUTHORISED_FOR_PREPAY_PSTATE ' 9
    AUTHORISED_FOR_PREAUTH_PSTATE ' 10
    DELIVERING_PSTATE ' 11
    DELIVERING_PREAUTH_PSTATE ' 12
    DELIVERING_PREPAY_PSTATE ' 13
    DELIVERY_FINISHING_PSTATE ' 14
    DELIVERY_FINISHED_PSTATE ' 15
    PREAUTH_DELIVERY_FINISHED_PSTATE ' 16
    PREPAY_REFUND_TIMEOUT_PSTATE ' 17
    PREPAY_REFUND_TAKEN_TIMEOUT_PSTATE ' 18
    TOTALS_LOST_ERROR_PSTATE ' 19
    DELIVERY_OVERRUN_ERROR_PSTATE ' 20
    PRICE_CHANGING_PSTATE ' 21
    NOZZLE_LEFT_OUT_PSTATE ' 22
    UNDEFINED_ERROR_PSTATE ' 23
    DELIVERY_STARTING_PSTATE ' 24
    PREPAY_STARTING_PSTATE ' 25
    PREAUTH_STARTING_PSTATE ' 26
    DELIVERY_START_TEMP_STOPPED_PSTATE ' 27
    DELIVERING_TEMP_STOPPED_PSTATE ' 28
    MECHANICAL_PUMP_PSTATE ' 29
    PUMP_BUSY_PSTATE ' 30
    INVALID_PRICE_PSTATE '31
End Enum

' values for Pump.ReserveState - for use in PreAuth and PrePay processing
Enum ReservedStates
    UNKNOWN_RESERVED ' 0
    NOT_RESERVED ' 1
    RESERVED_FOR_PREPAY ' 2
    PREPAY_AUTHORISED ' 3
    PREPAY_DELIVERING ' 4
    PREPAY_DELIVERED ' 5
    RESERVED_FOR_PREAUTH ' 6
    PREAUTH_AUTHORISED ' 7
    PREAUTH_DELIVERING ' 8
    PREAUTH_DELIVERED ' 9
End Enum

' values for Delivery.Type
Enum DeliveryTypes
    UNKNOWN_DELIVERY ' 0
    CURRENT_DELIVERY ' 1
    STACKED_DELIVERY ' 2
    AVAILABLE_PREAUTH_DELIVERY ' 3
    AVAILABLE_PREPAY_REFUND_DELIVERY ' 4
    POSTPAY_DELIVERY ' 5
    MONITOR_DELIVERY ' 6
    PREAUTH_DELIVERY ' 7
    PREPAY_DELIVERY ' 8
    PREPAY_REFUND_DELIVERY ' 9
    PREPAY_REFUND_LOST_DELIVERY ' 10
    TEST_DELIVERY ' 11
    DRIVEOFF_DELIVERY ' 12
    ATTENDANT_DELIVERY ' 13
    OFFLINE_DELIVERY ' 14
    REINSTATED_DELIVERY ' 15
    MAX_TYPES_DELIVERY
End Enum

'---------------------------------------------------------------------------
' Definitions for EnbSessionX object methods

' values for Session.Reload() ActionType
Enum UpdateTypes
  RA_NONE
  RA_UPDATE
  RA_DELETE
  RA_ADD
End Enum

' values for Session.Reload() DataType
Enum UpdateDataTypes
  ' 0 - 0x44FF are for Session to Database communication. Only use the following values:
  DT_GRADE         ' Grade_ID
  DT_HOSE          ' Hose_ID
  DT_TANK          ' Tank_ID
  DT_PRICE_PROFILE ' Price_Profile_ID
  DT_PRICE_LEVEL   ' Price_Profile_ID
  DT_PUMP_MODE     ' Pump_Mode_ID
  DT_PUMP          ' Pump_ID
  DT_SITE
  DT_SITE_MODE
  DT_ATTENDANT     ' Attendant_ID
  DT_OPT           ' OPT_ID
  DT_OPT_DOWNLOAD  ' OPT_ID
  DT_UPS
  'DT_AUTO_SITE_MODE Not able to find any references to this data type so removing. Craig
  DT_DELIVERYID
  DT_FALLBACK_MODE ' Fallback mode toggle
  DT_PUMPANDHOSES
  DT_TERMINALS     ' Terminals

  DT_SITE_MODE_CHANGED   ' Site Mode ID changed in Global settings
  DT_TANK_LEVELS_CHANGED ' Tank levels in Tank

  DT_TAG
  DT_TAG_READER
  
  ' > 0x4500 for internal Enabler use
End Enum

'---------------------------------------------------------------------------
' Database values

Enum PeriodStates
    PERIOD_OPEN = 1
    PERIOD_CLOSED = 2
    PERIOD_RECONCILED = 3 ' relevant for cashdrawers, and attendant periods
End Enum

' ---------------------------------------------------------------------------
' Definitions for EnbAttendantX method calls

' Alert status values for EnbAttendantX.LevelAlertEvent()
Enum AttendantAlertStatus
    ATT_STATUS_NORMAL = 0
    ATT_SAFEDROP_WARNING = 1
    ATT_SAFEDROP_ALARM = 2
End Enum

' Block Reasons
Enum AttendantBlockReason
    ATT_BLOCK_CLEAR = 0
    ATT_BLOCK_UNDER_LIMIT = 1
    ATT_BLOCK_OVER_LIMIT = 2
    ATT_ON_BREAK = 3
    ATT_BLOCK_NOT_AVAILABLE = 4 ' e.g. server offline
End Enum

'AmountTypes for the following EnbAttendantX methods and events:
'- EnterAmount
'- GetAmount
'- AttendantAmountEvent
Enum AttendantAmountType
    ATT_INITIAL_FLOAT = 1
    ATT_SAFEDROP = 2
    ATT_AMOUNT_COUNTED = 3
    ATT_AMOUNT_ON_HAND = 4 ' not valid for EnterAmount
End Enum

Enum TankMovementTypes
    TANK_MT_DELIVERYTICKET = 1
    TANK_MT_TESTTRANSFER = 2
    TANK_MT_TANKTOTANK = 3
    TANK_MT_PRODUCTUPLIFT = 4
    TANK_MT_WATERUPLIFT = 5
    TANK_MT_EMPTY = 6
    TANK_MT_DELIVERYTRUCK = 7
End Enum

Enum TankDipTypes
    TANK_DT_NONE = 1
    TANK_DT_DIP_STICK = 2
    TANK_DT_MANUAL_ATG_SENSOR = 3
    TANK_DT_BOOK_CALC = 4
    TANK_DT_ATG_READING = 5
End Enum

' Tank Probe Status Types
Enum TankProbeStatusTypes
    TANK_PROBE_NOT_CONFIGURED = 1
    TANK_PROBE_ONLINE = 2
    TANK_PROBE_OFFLINE = 3
    TANK_PROBE_UNKNOWN = 4
End Enum

Enum TankDipReadingType
    TANK_DIP_READING_VOLUME = 1
    TANK_DIP_READING_WATER = 2
    TANK_DIP_READING_TEMPERATURE = 3
    TANK_DIP_READING_DENSITY = 4
End Enum

' for PCI-DSS Audit use

' EnBConfig objects

Public Const OBJECT_TANK = 7
Public Const OBJECT_PUMP = 11
Public Const OBJECT_SITE_SETTING = 12
Public Const OBJECT_SITE_MODE = 9
Public Const OBJECT_PUMP_MODE = 10
Public Const OBJECT_PORT = 8
Public Const OBJECT_GRADE_PRICING = 6
Public Const OBJECT_TANK_GAUGE = 142
Public Const OBJECT_IDS_OPT = 208
Public Const OBJECT_BLEND_RATIO = 183
Public Const OBJECT_PRICE_LEVEL = 40
Public Const OBJECT_HOSE = 494
Public Const OBJECT_OPT = 208

' EnbMaint Objects
Public Const OBJECT_TANK_TOTALS = 115
Public Const OBJECT_DELIVERIES_HISTORY = 32
Public Const OBJECT_GRADE_PRICE = 8
Public Const OBJECT_PUMP_MODES = 9
Public Const OBJECT_PUMP_TOTAL = 11
Public Const OBJECT_VIEW_EVENT = 12
Public Const OBJECT_ATTENDANT = 131
Public Const OBJECT_GRADE_BLOCK = 34
Public Const OBJECT_TANK_BLOCK = 35

'FuelRecon Objects

Public Const OBJECT_TANK_DROP = 115
Public Const OBJECT_TANK_LOSS = 116
Public Const OBJECT_TANK_TRANSFER = 117
Public Const OBJECT_TANK_DELIVERIES = 106
Public Const OBJECT_TANK_LOSSES = 107
Public Const OBJECT_TANK_TRANSFERS = 108
Public Const OBJECT_PUMP_METERS = 30
Public Const OBJECT_TANK_DIPS = 28
Public Const OBJECT_TANK_DIP_READINGS = 339
Public Const OBJECT_TANK_HISTORY = 10117
Public Const OBJECT_SIRA = 10122
Public Const OBJECT_BOS = 10123

' WetStock Objects

Public Const OBJECT_TANK_DATA = 3
Public Const OBJECT_PUMP_DATA = 4

' For EnbConfig and EnbBlockMgr
Public Const OBJECT_GRADE = 10118

'FuelReconReport object
Public Const OBJECT_FRREPORT = 4

'application Events
Public Const APP_DEVICE_TYPE = 17
Public Const STARTUP_EVENT_TYPE = 167
Public Const ADD_EVENT_TYPE = 168
Public Const DELETE_EVENT_TYPE = 169
Public Const EDIT_EVENT_TYPE = 170
Public Const PRINT_EVENT_TYPE = 171
Public Const SHUTDOWN_EVENT_TYPE = 172
Public Const VALIDATE_EVENT_TYPE = 173
Public Const GENERATE_EVENT_TYPE = 174
Public Const EXPORT_EVENT_TYPE = 175

Public Const IDS_SUCCESS = 10010
Public Const IDS_FAILURE = 10012


Public Const IDS_ADD = 10110
Public Const IDS_EDIT = 10111
Public Const IDS_DELETE = 10112
Public Const IDS_STARTUP = 10113
Public Const IDS_SHUTDOWN = 10114
Public Const IDS_PRINT = 10115
Public Const IDS_VALIDATE = 10119
Public Const IDS_GENERATE = 10120
Public Const IDS_EXPORT = 10121


Public Const IntegratorIniFileName As String = "ITLintegrate.ini"
Public Const DefaultITLCopyright As String = "Copyright 2014 Integration Technologies Limited.  All rights reserved."

' Regkeys
Public Const ENABLER_REG_KEY As String = "SOFTWARE\ITL\Enabler"
Public Const ENABLER_CLIENT_REG_KEY As String = "SOFTWARE\ITL\Enabler\Client"
Public Const REG_KEY_ENBWEB_PORT As String = "EnbWebPort"
Public Const REG_KEY_ENBWEB_HOSTNAME As String = "Hostname"

Private InitConfigDone As Boolean
Private m_EnbWebPort As String
Private m_EnbWebHostName As String

Private Sub InitConfig()

    ' Enabler web server port
    If (GetKeyValue(HK_LOCAL_MACHINE, ENABLER_REG_KEY, REG_KEY_ENBWEB_PORT, m_EnbWebPort) = False) Then
        ' Default to 8081
        m_EnbWebPort = "8081"
    End If
    
    ' Enabler web server hostname
    If (GetKeyValue(HK_LOCAL_MACHINE, ENABLER_CLIENT_REG_KEY, REG_KEY_ENBWEB_HOSTNAME, m_EnbWebHostName) = False) Then
        ' Default to localhost
        m_EnbWebHostName = "localhost"
    End If
    
    InitConfigDone = True

End Sub

Public Property Get EnablerWebServerPort() As String
    
    If Not InitConfigDone Then InitConfig
    
    EnablerWebServerPort = m_EnbWebPort
        
End Property

Public Property Get EnablerWebServerHostName() As String
    
    If Not InitConfigDone Then InitConfig
    
    EnablerWebServerHostName = m_EnbWebHostName
        
End Property


Public Function EnablerDir() As String
    ' to become something else in the future
    EnablerDir = "c:\enabler\"
End Function

Public Function EnablerBlockManagerProgram() As String
    EnablerBlockManagerProgram = EnablerDir & "EnbBlockMgr.exe"
End Function

Public Function EnablerFuelReconProgram() As String
    EnablerFuelReconProgram = EnablerDir & "fuelrecon.exe"
End Function

Public Function WetstockMaintenanceProgram() As String
    WetstockMaintenanceProgram = EnablerFuelReconProgram
End Function

Public Function EnablerConfigurationProgram() As String
    EnablerConfigurationProgram = EnablerDir & "enbconfig.exe"
End Function

Public Function EnablerManagersProgram() As String
    EnablerManagersProgram = EnablerDir & "enbmaint.exe"
End Function

Public Function IntegratorIniPath() As String
    IntegratorIniPath = EnablerDir & IntegratorIniFileName
End Function

