Attribute VB_Name = "WinAPI"
Option Explicit



' -----------------------------------------------------------------------------------
' miscellaneous Win32 API declarations
' -----------------------------------------------------------------------------------

' API ERRORS

Public Const ERROR_DEPENDENT_SERVICES_RUNNING = 1051


' -----------------------------------------------------------------------------------
' WINDOW/FORM/DIALOG
' -----------------------------------------------------------------------------------


' Fonts
Public Const LF_FACESIZE = 32
Public Const LF_FULLFACESIZE = 64
Public Const TRUETYPE_FONTTYPE = &H4
Public Const DEVICE_FONTTYPE = &H2
Public Const RASTER_FONTTYPE = &H1
Public Const FIXED_PITCH = 1

' resource types
Public Const RT_STRING As Long = 6&

' GetSystemMetrics() codes
Public Const SM_CXSCREEN = 0
Public Const SM_CYSCREEN = 1
Public Const SM_CXVSCROLL = 2
Public Const SM_CYHSCROLL = 3
Public Const SM_CYCAPTION = 4
Public Const SM_CXBORDER = 5
Public Const SM_CYBORDER = 6
Public Const SM_CXDLGFRAME = 7
Public Const SM_CYDLGFRAME = 8
Public Const SM_CYVTHUMB = 9
Public Const SM_CXHTHUMB = 10
Public Const SM_CXICON = 11
Public Const SM_CYICON = 12
Public Const SM_CXCURSOR = 13
Public Const SM_CYCURSOR = 14
Public Const SM_CYMENU = 15
Public Const SM_CXFULLSCREEN = 16
Public Const SM_CYFULLSCREEN = 17
Public Const SM_CYKANJIWINDOW = 18
Public Const SM_MOUSEPRESENT = 19
Public Const SM_CYVSCROLL = 20
Public Const SM_CXHSCROLL = 21
Public Const SM_DEBUG = 22
Public Const SM_SWAPBUTTON = 23
Public Const SM_RESERVED1 = 24
Public Const SM_RESERVED2 = 25
Public Const SM_RESERVED3 = 26
Public Const SM_RESERVED4 = 27
Public Const SM_CXMIN = 28
Public Const SM_CYMIN = 29
Public Const SM_CXSIZE = 30
Public Const SM_CYSIZE = 31
Public Const SM_CXFRAME = 32
Public Const SM_CYFRAME = 33
Public Const SM_CXMINTRACK = 34
Public Const SM_CYMINTRACK = 35
Public Const SM_CXDOUBLECLK = 36
Public Const SM_CYDOUBLECLK = 37
Public Const SM_CXICONSPACING = 38
Public Const SM_CYICONSPACING = 39
Public Const SM_MENUDROPALIGNMENT = 40
Public Const SM_PENWINDOWS = 41
Public Const SM_DBCSENABLED = 42
Public Const SM_CMOUSEBUTTONS = 43
Public Const SM_CMETRICS = 44
Public Const SM_CXEDGE = 45
Public Const SM_CYEDGE = 46
Public Const SM_CXSIZEFRAME = SM_CXFRAME
Public Const SM_CYSIZEFRAME = SM_CYFRAME
Public Const SM_CXFIXEDFRAME = SM_CXDLGFRAME
Public Const SM_CYFIXEDFRAME = SM_CYDLGFRAME

' these require W2k or higher
Public Const SM_XVIRTUALSCREEN = 76
Public Const SM_YVIRTUALSCREEN = 77
Public Const SM_CXVIRTUALSCREEN = 78
Public Const SM_CYVIRTUALSCREEN = 79
Public Const SM_CMONITORS = 80

' ShowWindow() Commands
Public Const SW_HIDE = 0
Public Const SW_SHOWNORMAL = 1
Public Const SW_NORMAL = 1
Public Const SW_SHOWMINIMIZED = 2
Public Const SW_SHOWMAXIMIZED = 3
Public Const SW_MAXIMIZE = 3
Public Const SW_SHOWNOACTIVATE = 4
Public Const SW_SHOW = 5
Public Const SW_MINIMIZE = 6
Public Const SW_SHOWMINNOACTIVE = 7
Public Const SW_SHOWNA = 8
Public Const SW_RESTORE = 9
Public Const SW_SHOWDEFAULT = 10
Public Const SW_MAX = 10

Public Declare Function FindWindow Lib "user32" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String) As Long
Public Declare Function ShowWindow Lib "user32" (ByVal hwnd As Long, ByVal nCmdShow As Long) As Long
Public Declare Function BringWindowToTop Lib "user32" (ByVal hwnd As Long) As Long

' -----------------------------------------------------------------------------------
' INTERNATIONALISATION
' -----------------------------------------------------------------------------------

Public Const LOCALE_IMEASURE& = &HD&
Public Const LOCALE_SCURRENCY = &H14

Public Const LOCALE_SDAYNAME1 = &H2A        ' long name for Monday
Public Const LOCALE_SABBREVDAYNAME1 = &H31  ' short name for Monday

Public Const ANSI_CHARSET = 0
Public Const DEFAULT_CHARSET = 1
Public Const CHINESEBIG5_CHARSET = 136
Public Const THAI_CHARSET = 222
Public Const GB2312_CHARSET = 134

Public Const LOCALE_USER_DEFAULT = &H400

' values for System Language - Locale ID - these are combinations of LANG, SUBLANG and Location
Public Const LocaleAussie As Long = &HC09            '  3081  SUBLANG_ENGLISH_AUS  LANG_ENGLISH
Public Const LocaleAustralia As Long = &HC09         '  3081  SUBLANG_ENGLISH_AUS  LANG_ENGLISH
Public Const LocaleBrazil As Long = &H416            '  1046
Public Const LocaleChinesePRC As Long = &H804        '  2052
Public Const LocaleChineseSingapore As Long = &H1004 '  4100
Public Const LocaleChineseTaiwan As Long = &H404     '  1028
Public Const LocaleChineseHK As Long = &HC04         '  3076
Public Const LocaleChineseMacao As Long = &H1404     '  5124
Public Const LocaleCostaRica As Long = &H140A        '  5130  COSTA RICA (SPANISH)
Public Const LocaleIndia As Long = &H439             '  1081
Public Const LocaleIndonesia As Long = &H421         '  1057
Public Const LocaleItaly As Long = &H410             '  1040
Public Const LocaleOman As Long = &H2001             '  8193
Public Const LocalePakistanPunjabi = 2118
Public Const LocalePakistanSindhi = 2137
Public Const LocalePhilippines As Long = &H3409      ' 13321
Public Const LocalePortugal As Long = &H816          '  2070
Public Const LocaleRussia As Long = &H419            '  1049
Public Const LocaleThailand As Long = &H41E          '  1054  LANG_THAI, 1 for SUBLANG

' special value for internal use only
Public Const LocaleOther As Long = 0
Public Const LocaleGlobal As Long = 1

Public Const TCI_SRCCODEPAGE = 2
'
'  The following two combinations of primary language ID and
'  sublanguage ID have special semantics:
'
'  Primary Language ID   Sublanguage ID      Result
'  -------------------   ---------------     ------------------------
'  LANG_NEUTRAL          SUBLANG_NEUTRAL     Language neutral
'  LANG_NEUTRAL          SUBLANG_DEFAULT     User default language
'  LANG_NEUTRAL          SUBLANG_SYS_DEFAULT System default language
'
'  Primary language IDs.
'  WARNING! INCOMPLETE! Contains what VB6 already declared
'
Public Const LANG_NEUTRAL = &H0

Public Const LANG_CHINESE = &H4
Public Const LANG_CROATIAN = &H1A
Public Const LANG_CZECH = &H5
Public Const LANG_DANISH = &H6
Public Const LANG_DUTCH = &H13
Public Const LANG_ENGLISH = &H9
Public Const LANG_FINNISH = &HB
Public Const LANG_FRENCH = &HC
Public Const LANG_GERMAN = &H7
Public Const LANG_GREEK = &H8
Public Const LANG_HUNGARIAN = &HE
Public Const LANG_ICELANDIC = &HF
Public Const LANG_ITALIAN = &H10
Public Const LANG_JAPANESE = &H11
Public Const LANG_KOREAN = &H12
Public Const LANG_NORWEGIAN = &H14
Public Const LANG_POLISH = &H15
Public Const LANG_PORTUGUESE = &H16
Public Const LANG_ROMANIAN = &H18
Public Const LANG_RUSSIAN = &H19
Public Const LANG_SLOVAK = &H1B
Public Const LANG_SLOVENIAN = &H24
Public Const LANG_SPANISH = &HA
Public Const LANG_SWEDISH = &H1D
Public Const LANG_THAI = &H1E
Public Const LANG_TURKISH = &H1F
'
'  Sublanguage IDs.
'
'  The name immediately following SUBLANG_ dictates which primary
'  language ID that sublanguage ID can be combined with to form a
'  valid language ID.
'
Public Const SUBLANG_NEUTRAL = &H0                       '  language neutral
Public Const SUBLANG_DEFAULT = &H1                       '  user default
Public Const SUBLANG_SYS_DEFAULT = &H2                   '  system default

Public Const SUBLANG_CHINESE_TRADITIONAL = &H1           '  Chinese (Taiwan)
Public Const SUBLANG_CHINESE_SIMPLIFIED = &H2            '  Chinese (PR China)
Public Const SUBLANG_CHINESE_HONGKONG = &H3              '  Chinese (Hong Kong)
Public Const SUBLANG_CHINESE_SINGAPORE = &H4             '  Chinese (Singapore)
Public Const SUBLANG_DUTCH = &H1                         '  Dutch
Public Const SUBLANG_DUTCH_BELGIAN = &H2                 '  Dutch (Belgian)
Public Const SUBLANG_ENGLISH_US = &H1                    '  English (USA)
Public Const SUBLANG_ENGLISH_UK = &H2                    '  English (UK)
Public Const SUBLANG_ENGLISH_AUS = &H3                   '  English (Australian)
Public Const SUBLANG_ENGLISH_CAN = &H4                   '  English (Canadian)
Public Const SUBLANG_ENGLISH_NZ = &H5                    '  English (New Zealand)
Public Const SUBLANG_ENGLISH_EIRE = &H6                  '  English (Irish)
Public Const SUBLANG_FRENCH = &H1                        '  French
Public Const SUBLANG_FRENCH_BELGIAN = &H2                '  French (Belgian)
Public Const SUBLANG_FRENCH_CANADIAN = &H3               '  French (Canadian)
Public Const SUBLANG_FRENCH_SWISS = &H4                  '  French (Swiss)
Public Const SUBLANG_GERMAN = &H1                        '  German
Public Const SUBLANG_GERMAN_SWISS = &H2                  '  German (Swiss)
Public Const SUBLANG_GERMAN_AUSTRIAN = &H3               '  German (Austrian)
Public Const SUBLANG_ITALIAN = &H1                       '  Italian
Public Const SUBLANG_ITALIAN_SWISS = &H2                 '  Italian (Swiss)
Public Const SUBLANG_NORWEGIAN_BOKMAL = &H1              '  Norwegian (Bokma
Public Const SUBLANG_NORWEGIAN_NYNORSK = &H2             '  Norwegian (Nynorsk)
Public Const SUBLANG_PORTUGUESE = &H2                    '  Portuguese
Public Const SUBLANG_PORTUGUESE_BRAZILIAN = &H1          '  Portuguese (Brazilian)
Public Const SUBLANG_SPANISH = &H1                       '  Spanish (Castilian)
Public Const SUBLANG_SPANISH_MEXICAN = &H2               '  Spanish (Mexican)
Public Const SUBLANG_SPANISH_MODERN = &H3                '  Spanish (Modern)

' -----------------------------------------------------------------------------------

' Window long stuff...
Public Declare Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (ByVal hwnd As Long, ByVal nIndex As Long, ByVal dwNewLong As Long) As Long
Public Declare Function GetWindowLong Lib "user32" Alias "GetWindowLongA" (ByVal hwnd As Long, ByVal nIndex As Long) As Long

Public Const GWL_EXSTYLE = (-20)
Public Const GWL_STYLE = (-16)
Public Const WS_EX_CLIENTEDGE = &H200
Public Const WS_HSCROLL = &H100000
Public Const WS_VSCROLL = &H200000

Private Const WS_EX_STATICEDGE = &H20000
Private Const WS_EX_DLGMODALFRAME = &H1
Private Const WS_CAPTION = &HC00000
Private Const WS_THICKFRAME = &H40000
Private Const WS_MINIMIZE = &H20000000
Private Const WS_MAXIMIZE = &H1000000
Private Const WS_SYSMENU = &H80000

Private Declare Function SetWindowRgn Lib "user32" _
    (ByVal hwnd As Long, ByVal hRgn As Long, _
    ByVal bRedraw As Boolean) As Long

Private Declare Function CreateRectRgn Lib "gdi32" _
    (ByVal X1 As Long, ByVal Y1 As Long, _
    ByVal X2 As Long, ByVal Y2 As Long) As Long

' General functions
Public Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

Public Declare Function GetTickCount Lib "kernel32" () As Long

Public Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" _
    (Destination As Any, _
    Source As Any, _
    ByVal Length As Long)
    
Public Declare Function lstrlen Lib "kernel32" Alias "lstrlenA" _
   (ByVal psString As Long) As Long
    
Public Declare Function GetSystemMetrics Lib "user32" (ByVal nIndex As Long) As Long

Public Declare Function GetLastError Lib "kernel32" () As Long

Public Declare Function EnumFontFamiliesEx Lib "gdi32" Alias "EnumFontFamiliesExA" _
    (ByVal hdc As Long, _
    lpLogFont As LOGFONT, _
    ByVal lpEnumFontProc As Long, _
    ByVal lParam As Long, _
    ByVal dw As Long) As Long

' Resource functions
Public Declare Function FindResourceEx Lib "kernel32" Alias "FindResourceExA" _
    (ByVal hModule As Long, _
    ByVal lpType As Long, _
    ByVal lpName As Long, _
    ByVal wLanguage As Long) As Long
    
Public Declare Function LoadResource Lib "kernel32" _
    (ByVal hInstance As Long, _
    ByVal hResInfo As Long) As Long
    
Public Declare Function SizeofResource Lib "kernel32" _
    (ByVal hInstance As Long, _
    ByVal hResInfo As Long) As Long
    
Public Declare Function LockResource Lib "kernel32" (ByVal hResData As Long) As Long

' International stuff
Public Declare Function TranslateCharsetInfo Lib "gdi32" _
    (ByVal lpSrc As Long, _
    lpcs As CHARSETINFO, _
    ByVal dwFlags As Long) As Long
    
Public Declare Function GetSystemDefaultLCID Lib "kernel32" () As Long
Public Declare Function GetLocaleInfoA Lib "kernel32" (ByVal lLCID As Long, ByVal lLCTYPE As Long, ByVal strLCData As String, ByVal lDataLen As Long) As Long
Public Declare Function GetSystemDefaultLangID Lib "kernel32" () As Integer
Public Declare Function GetACP Lib "kernel32" () As Long
Public Declare Function GetActiveCodePage& Lib "kernel32" Alias "GetACP" ()

' Since we are not Unicode, we can't reliably use user settings, since the
' correct character set needs to be selected as well (system default locale)
Public Declare Function GetUserDefaultLangID Lib "kernel32" () As Integer
Public Declare Function GetUserDefaultLCID Lib "kernel32" () As Long

' -----------------------------------------------------------------------------------
' Shell
' -----------------------------------------------------------------------------------
Public Declare Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" (ByVal hwnd As Long, ByVal lpOperation As String, ByVal lpFile As String, ByVal lpParameters As String, ByVal lpDirectory As String, ByVal nShowCmd As Long) As Long

Private Declare Function GetTempPathA Lib "kernel32" _
   (ByVal nBufferLength As Long, ByVal lpBuffer As String) As Long

' -----------------------------------------------------------------------------------
' WINDOWS SERVICE CONTROL
' -----------------------------------------------------------------------------------



' used for service control by Enb Configuration
Public Const SERVICES_ACTIVE_DATABASE = "ServicesActive"

Public Const SERVICE_CONTROL_STOP = &H1
Public Const SERVICE_CONTROL_PAUSE = &H2

' Service State -- for Enum Requests (Bit Mask)
Public Const SERVICE_ACTIVE = &H1
Public Const SERVICE_INACTIVE = &H2
Public Const SERVICE_STATE_ALL = &H3

' Service State - for CurrentState
Public Const SERVICE_STOPPED = &H1
Public Const SERVICE_START_PENDING = &H2
Public Const SERVICE_STOP_PENDING = &H3
Public Const SERVICE_RUNNING = &H4
Public Const SERVICE_CONTINUE_PENDING = &H5
Public Const SERVICE_PAUSE_PENDING = &H6
Public Const SERVICE_PAUSED = &H7

'Service Control Manager object specific access types
Public Const STANDARD_RIGHTS_REQUIRED = &HF0000
Public Const SC_MANAGER_CONNECT = &H1
Public Const SC_MANAGER_CREATE_SERVICE = &H2
Public Const SC_MANAGER_ENUMERATE_SERVICE = &H4
Public Const SC_MANAGER_LOCK = &H8
Public Const SC_MANAGER_QUERY_LOCK_STATUS = &H10
Public Const SC_MANAGER_MODIFY_BOOT_CONFIG = &H20
Public Const SC_MANAGER_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED Or SC_MANAGER_CONNECT Or SC_MANAGER_CREATE_SERVICE Or SC_MANAGER_ENUMERATE_SERVICE Or SC_MANAGER_LOCK Or SC_MANAGER_QUERY_LOCK_STATUS Or SC_MANAGER_MODIFY_BOOT_CONFIG)

'Service object specific access types
Public Const SERVICE_QUERY_CONFIG = &H1
Public Const SERVICE_CHANGE_CONFIG = &H2
Public Const SERVICE_QUERY_STATUS = &H4
Public Const SERVICE_ENUMERATE_DEPENDENTS = &H8
Public Const SERVICE_START = &H10
Public Const SERVICE_STOP = &H20
Public Const SERVICE_PAUSE_CONTINUE = &H40
Public Const SERVICE_INTERROGATE = &H80
Public Const SERVICE_USER_DEFINED_CONTROL = &H100
Public Const SERVICE_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED Or SERVICE_QUERY_CONFIG Or SERVICE_CHANGE_CONFIG Or SERVICE_QUERY_STATUS Or SERVICE_ENUMERATE_DEPENDENTS Or SERVICE_START Or SERVICE_STOP Or SERVICE_PAUSE_CONTINUE Or SERVICE_INTERROGATE Or SERVICE_USER_DEFINED_CONTROL)


Public Type SERVICE_STATUS
    dwServiceType As Long
    dwCurrentState As Long
    dwControlsAccepted As Long
    dwWin32ExitCode As Long
    dwServiceSpecificExitCode As Long
    dwCheckPoint As Long
    dwWaitHint As Long
End Type

Public Type ENUM_SERVICE_STATUS
    lpServiceName As Long
    lpDisplayName As Long
    ServiceStatus As SERVICE_STATUS
End Type

Public Declare Function CloseServiceHandle Lib "advapi32.dll" _
    (ByVal hSCObject As Long) As Long

Public Declare Function ControlService Lib "advapi32.dll" _
    (ByVal ServiceHandle As Long, _
    ByVal dwControl As Long, _
    lpServiceStatus As SERVICE_STATUS) As Long
    
Public Declare Function OpenSCManager Lib "advapi32.dll" Alias "OpenSCManagerA" _
    (ByVal lpMachineName As String, _
    ByVal lpDatabaseName As String, _
    ByVal dwDesiredAccess As Long) As Long
    
Public Declare Function OpenService Lib "advapi32.dll" Alias "OpenServiceA" _
    (ByVal hSCManager As Long, _
    ByVal lpServiceName As String, _
    ByVal dwDesiredAccess As Long) As Long
    
Public Declare Function QueryServiceStatus Lib "advapi32.dll" _
    (ByVal ServiceHandle As Long, _
    lpServiceStatus As SERVICE_STATUS) As Long
    
Public Declare Function StartService Lib "advapi32.dll" Alias "StartServiceA" _
    (ByVal hService As Long, _
    ByVal dwNumServiceArgs As Long, _
    ByVal lpServiceArgVectors As Long) As Long
    
Public Declare Function EnumDependentServices Lib "advapi32.dll" Alias "EnumDependentServicesA" _
    (ByVal ServiceHandle As Long, _
    ByVal ServiceState As Long, _
    ByRef ServiceStatusBuffer As Any, _
    ByVal ServiceStatusBufferSize As Long, _
    ByRef OutBufferNeeded As Long, _
    ByRef NumberOfDependentsReturned As Long) As Long
  

' -----------------------------------------------------------------------------------
' WINDOWS FONTS
' -----------------------------------------------------------------------------------

Public Type FONTSIGNATURE
        fsUsb(4) As Long
        fsCsb(2) As Long
End Type

Public Type CHARSETINFO
        ciCharset As Long
        ciACP As Long
        fs As FONTSIGNATURE
End Type

Public Type LOGFONT
        lfHeight As Long
        lfWidth As Long
        lfEscapement As Long
        lfOrientation As Long
        lfWeight As Long
        lfItalic As Byte
        lfUnderline As Byte
        lfStrikeOut As Byte
        lfCharSet As Byte
        lfOutPrecision As Byte
        lfClipPrecision As Byte
        lfQuality As Byte
        lfPitchAndFamily As Byte
        lfFaceName(1 To LF_FACESIZE) As Byte
End Type

Public Type ENUMLOGFONTEX
        elfLogFont As LOGFONT
        elfFullName(LF_FULLFACESIZE) As Byte
        elfStyle(LF_FACESIZE) As Byte
        elfScript(LF_FACESIZE) As Byte
End Type

Public Type NEWTEXTMETRIC
        tmHeight As Long
        tmAscent As Long
        tmDescent As Long
        tmInternalLeading As Long
        tmExternalLeading As Long
        tmAveCharWidth As Long
        tmMaxCharWidth As Long
        tmWeight As Long
        tmOverhang As Long
        tmDigitizedAspectX As Long
        tmDigitizedAspectY As Long
        tmFirstChar As Byte
        tmLastChar As Byte
        tmDefaultChar As Byte
        tmBreakChar As Byte
        tmItalic As Byte
        tmUnderlined As Byte
        tmStruckOut As Byte
        tmPitchAndFamily As Byte
        tmCharSet As Byte
        ntmFlags As Long
        ntmSizeEM As Long
        ntmCellHeight As Long
        ntmAveWidth As Long
End Type

Public Type NEWTEXTMETRICEX
        ntmTm As NEWTEXTMETRIC
        ntmFontSig As FONTSIGNATURE
End Type

Public Type TEXTMETRIC
        tmHeight As Long
        tmAscent As Long
        tmDescent As Long
        tmInternalLeading As Long
        tmExternalLeading As Long
        tmAveCharWidth As Long
        tmMaxCharWidth As Long
        tmWeight As Long
        tmOverhang As Long
        tmDigitizedAspectX As Long
        tmDigitizedAspectY As Long
        tmFirstChar As Byte
        tmLastChar As Byte
        tmDefaultChar As Byte
        tmBreakChar As Byte
        tmItalic As Byte
        tmUnderlined As Byte
        tmStruckOut As Byte
        tmPitchAndFamily As Byte
        tmCharSet As Byte
End Type

Type POINTAPI
   x As Long
   Y As Long
End Type

Type RECT
   Left As Long
   Top As Long
   Right As Long
   Bottom As Long
End Type

' -----------------------------------------------------------------------------------
' WINDOW MANIPULATION
' -----------------------------------------------------------------------------------

Const SWP_NOSIZE = &H1
Const SWP_NOMOVE = &H2
Const SWP_NOZORDER = &H4
Const SWP_NOREDRAW = &H8
Const SWP_NOACTIVATE = &H10
Const SWP_FRAMECHANGED = &H20        '  The frame changed: send WM_NCCALCSIZE
Const SWP_SHOWWINDOW = &H40
Const SWP_HIDEWINDOW = &H80
Const SWP_NOCOPYBITS = &H100
Const SWP_NOOWNERZORDER = &H200      '  Don't do owner Z ordering

Const SWP_DRAWFRAME = SWP_FRAMECHANGED
Const SWP_NOREPOSITION = SWP_NOOWNERZORDER

Public Const conHwndTopmost = -1
Public Const conHwndNoTopmost = -2
Public Const conSwpNoSize = &H1
Public Const conSwpNoMove = &H2
Public Const conSwpNoActivate = &H10
Public Const conSwpShowWindow = &H40

Public Declare Function GetClientRect Lib "user32" (ByVal hwnd As Long, lpRect As RECT) As Long
Public Declare Function GetUserName Lib "advapi32.dll" Alias "GetUserNameA" (ByVal lpBuffer As String, nSize As Long) As Long

Declare Function GetWindowRect Lib "user32" _
   (ByVal hwnd As Long, lpRect As RECT) As Long

Declare Function ScreenToClient Lib "user32" _
   (ByVal hwnd As Long, lpPoint As POINTAPI) As Long

Declare Function MoveWindow Lib "user32" _
   (ByVal hwnd As Long, ByVal x As Long, _
    ByVal Y As Long, ByVal nWidth As Long, _
    ByVal nHeight As Long, ByVal bRepaint As Long) As Long

Public Declare Function SetWindowPos Lib "user32" (ByVal hwnd As Long, ByVal hWndInsertAfter As Long, ByVal x As Long, ByVal Y As Long, ByVal cx As Long, ByVal cy As Long, ByVal wFlags_ As Long) As Long


' -----------------------------------------------------------------------------------
' PROCESS CONTROL
' -----------------------------------------------------------------------------------

Public Declare Function GetModuleHandle Lib "kernel32" Alias "GetModuleHandleA" (ByVal lpModuleName As String) As Long

Public Declare Sub ExitProcess Lib "kernel32" (ByVal uExitCode As Long)

Public Declare Function CreateProcess Lib "kernel32" Alias "CreateProcessA" _
         (ByVal lpApplicationName As String, ByVal lpCommandLine As String, _
         lpProcessAttributes As Any, lpThreadAttributes As Any, _
         ByVal bInheritHandles As Long, ByVal dwCreationFlags As Long, _
         lpEnvironment As Any, ByVal lpCurrentDriectory As String, _
         lpStartupInfo As STARTUPINFO, lpProcessInformation As PROCESS_INFORMATION) As Long

'public Declare Function OpenProcess Lib "kernel32.dll" (ByVal dwAccess As Long, _
'         ByVal fInherit As Integer, ByVal hObject As Long) As Long

'public Declare Function TerminateProcess Lib "kernel32" (ByVal hProcess As Long, ByVal uExitCode As Long) As Long
'

Public Declare Function WaitForSingleObject Lib "kernel32.dll" (ByVal hHandle As Long, ByVal dwMilliseconds As Long) As Long

Public Declare Function GetExitCodeProcess Lib "kernel32" (ByVal hProcess As Long, lpExitCode As Long) As Long


Public Type PROCESS_INFORMATION
    hProcess As Long
    hThread As Long
    dwProcessID As Long
    dwThreadID As Long
End Type

Public Type STARTUPINFO
    cb As Long
    lpReserved As String
    lpDesktop As String
    lpTitle As String
    dwX As Long
    dwY As Long
    dwXSize As Long
    dwYSize As Long
    dwXCountChars As Long
    dwYCountChars As Long
    dwFillAttribute As Long
    dwFlags As Long
    wShowWindow As Integer
    cbReserved2 As Integer
    lpReserved2 As Long
    hStdInput As Long
    hStdOutput As Long
    hStdError As Long
End Type

Public Const NORMAL_PRIORITY_CLASS      As Long = &H20&
Public Const INFINITE                   As Long = -1&
Public Const SYNCHRONIZE = 1048576
Public Declare Function CloseHandle Lib "kernel32" (ByVal hObject As Long) As Long

' -----------------------------------------------------------------------------------
' Messages
' -----------------------------------------------------------------------------------

Public Const CB_GETITEMHEIGHT = &H154
Public Const EM_GETLINECOUNT = 186
Public Const EM_LINEINDEX = &HBB
Public Const EM_LINELENGTH = &HC1
Public Const EM_LINEFROMCHAR = &HC9

Declare Function SendMessageLong Lib _
   "user32" Alias "SendMessageA" _
   (ByVal hwnd As Long, _
    ByVal wMsg As Long, _
    ByVal wParam As Long, _
    ByVal lParam As Long) As Long
    
' -----------------------------------------------------------------------------------
' Serial ports
' -----------------------------------------------------------------------------------
   
Public Type DCB
        DCBlength As Long
        BaudRate As Long
        fBitFields As Long 'See Comments in Win32API.Txt
        wReserved As Integer
        XonLim As Integer
        XoffLim As Integer
        ByteSize As Byte
        Parity As Byte
        StopBits As Byte
        XonChar As Byte
        XoffChar As Byte
        ErrorChar As Byte
        EofChar As Byte
        EvtChar As Byte
        wReserved1 As Integer 'Reserved; Do Not Use
End Type
    
Public Declare Function GetCommState Lib "kernel32" (ByVal nCid As Long, lpDCB As DCB) As Long
Public Declare Function SetCommState Lib "kernel32" (ByVal hCommDev As Long, lpDCB As DCB) As Long
    
' -----------------------------------------------------------------------------------
' Keyboard
' -----------------------------------------------------------------------------------
    
Public Declare Function GetKeyboardState Lib "user32" (pbKeyState As Byte) As Long

' -----------------------------------------------------------------------------------
' UTF8 String Utilities
' -----------------------------------------------------------------------------------

Public Declare Function WideCharToMultiByte Lib "kernel32" (ByVal Codepage As Long, ByVal dwFlags As Long, ByVal lpWideCharStr As Long, ByVal cchWideChar As Long, ByRef lpMultiByteStr As Any, ByVal cchMultiByte As Long, ByVal lpDefaultChar As String, ByVal lpUsedDefaultChar As Long) As Long
Public Declare Function MultiByteToWideChar Lib "kernel32" (ByVal Codepage As Long, ByVal dwFlags As Long, ByVal lpMultiByteStr As Long, ByVal cchMultiByte As Long, ByVal lpWideCharStr As Long, ByVal cchWideChar As Long) As Long
Public Const CP_UTF8 = 65001

' -----------------------------------------------------------------------------------
' INI files
' -----------------------------------------------------------------------------------

Public Declare Function GetPrivateProfileInt Lib "kernel32" Alias "GetPrivateProfileIntA" (ByVal lpApplicationName As String, ByVal lpKeyName As String, ByVal nDefault As Long, ByVal lpFileName As String) As Long

' -----------------------------------------------------------------------------------
' File Functions
' -----------------------------------------------------------------------------------


Const MAX_PATH As Integer = 260

Public Const INVALID_HANDLE_VALUE As Long = -1

Public Type FILETIME
    dwLowDateTime As Long
    dwHighDateTime As Long
End Type

Public Type WIN32_FIND_DATA
    dwFileAttributes As Long
    ftCreationTime As FILETIME
    ftLastAccessTime As FILETIME
    ftLastWriteTime As FILETIME
    nFileSizeHigh As Long
    nFileSizeLow As Long
    dwReserved0 As Long
    dwReserved1 As Long
    cFileName As String * MAX_PATH
    cAlternateFileName As String * 14
End Type

Public Type SYSTEMTIME
    wYear As Integer
    wMonth As Integer
    wDayOfWeek As Integer
    wDay As Integer
    wHour As Integer
    wMinute As Integer
    wSecond As Integer
    wMilliseconds As Integer
End Type

Public Declare Function FindFirstFile Lib "kernel32" Alias "FindFirstFileA" _
    (ByVal lpFileName As String, lpFindFileData As WIN32_FIND_DATA) As Long

Public Declare Function FindNextFile Lib "kernel32" Alias "FindNextFileA" _
    (ByVal hFindFile As Long, lpFindFileData As WIN32_FIND_DATA) As Long

Public Declare Function FindClose Lib "kernel32" (ByVal hFindFile As Long) As Long

Public Declare Function FileTimeToLocalFileTime Lib "kernel32" _
    (lpFileTime As FILETIME, lpLocalFileTime As FILETIME) As Long

Public Declare Function FileTimeToSystemTime Lib "kernel32" _
    (lpFileTime As FILETIME, lpSystemTime As SYSTEMTIME) As Long
    
Public Declare Function SystemTimeToFileTime Lib "kernel32" _
    (lpSystemTime As SYSTEMTIME, lpFileTime As FILETIME) As Long
    
' -----------------------------------------------------------------------------------
' Windows version
' -----------------------------------------------------------------------------------
  
Public Declare Function GetVersionEx Lib "kernel32" Alias "GetVersionExA" _
    (lpVersionInformation As OSVERSIONINFO) As Long

Public Type OSVERSIONINFO
  OSVSize         As Long
  dwVerMajor      As Long
  dwVerMinor      As Long
  dwBuildNumber   As Long
  PlatformID      As Long
  szCSDVersion    As String * 128
End Type

Public Const VER_PLATFORM_WIN32s = 0
Public Const VER_PLATFORM_WIN32_WINDOWS = 1
Public Const VER_PLATFORM_WIN32_NT = 2





' -----------------------------------------------------------------------------------
' Utilities
' -----------------------------------------------------------------------------------
Public Const CB_SETDROPPEDWIDTH = &H160
    
Public Sub SetComboBoxDropDownItems(hParent As Long, _
                                    ComboBoxIn As ComboBox, _
                                    NumberOfItemsTall As Long)
  Dim Point As POINTAPI
  Dim Rectangle As RECT
  Dim ComboBoxWidth As Long
  Dim NewComboBoxHeight As Long
  Dim EditAreaHeight As Long
  Dim OldScaleMode As Long
  Dim ListAreaHeight As Long
  ComboBoxWidth = ComboBoxIn.Width \ Screen.TwipsPerPixelX
  ListAreaHeight = SendMessageLong(ComboBoxIn.hwnd, _
                                   CB_GETITEMHEIGHT, 0, 0)
  EditAreaHeight = SendMessageLong(ComboBoxIn.hwnd, _
                                   CB_GETITEMHEIGHT, -1, 0)
  NewComboBoxHeight = ListAreaHeight * NumberOfItemsTall + _
                      2 * EditAreaHeight
  GetWindowRect ComboBoxIn.hwnd, Rectangle
  Point.x = Rectangle.Left
  Point.Y = Rectangle.Top
  ScreenToClient hParent, Point
  MoveWindow ComboBoxIn.hwnd, Point.x, Point.Y, _
             ComboBoxWidth, NewComboBoxHeight, True
  
End Sub

' Set a Combo box dropdown width in pixels

Public Sub SetComboDropDownWidth(ComboBox As ComboBox, ByVal lWidth As Long)
    SendMessageLong ComboBox.hwnd, CB_SETDROPPEDWIDTH, lWidth, ByVal 0&
End Sub

' some API calls return C string pointers inside strucutres.  For example EnumDependentServices
' the only way I have found to get the string back out is to put a "Long" in the VB type, and
' use this code to convert the 'Long' back into a VB String
Public Function ANSIPointerToString(ByVal psString As Long) As String

Dim sString As String
Dim nStrLength As Long

    nStrLength = lstrlen(psString)
    If nStrLength Then
        sString = Space$(nStrLength)
        CopyMemory ByVal sString, ByVal psString, nStrLength
        ANSIPointerToString = sString
    End If

End Function

' Workaround for defective VB controls that don't select their
' contents when tabbed into (e.g. text box). You have to call it in
' the _GotFocus event for every control :(
Public Sub ActiveControlSelect()
    Dim btArray(255) As Byte
    Const VK_LBUTTON = &H1

    ' see if mouse button is down - we don't want to select all on mouse click
    Call GetKeyboardState(btArray(0))
    If ((btArray(VK_LBUTTON) And &H80) <> &H80) Then
        With Screen.ActiveControl
            If .SelLength = 0 Then
                .SelStart = 0
                .SelLength = Len(.Text)
            End If
        End With
    End If
End Sub



' File names returned by FindFirstFile and FindNextFile are fixed length
' null terminated strings.  This function removes the null characters
Public Function TrimNull(sFileName As String) As String
    Dim i As Long
    ' Search for the first null character
    i = InStr(1, sFileName, vbNullChar)
    If i = 0 Then
        TrimNull = sFileName
    Else
        ' Return the file name
        TrimNull = Left$(sFileName, i - 1)
    End If
End Function

' This will convert a Unix Epoch Time since 1/1/1970 in seconds to a date and time
Public Function EpochTimeToDate(ByVal epochTime As Long) As Date
    EpochTimeToDate = DateAdd("s", epochTime, DateSerial(1970, 1, 1))
End Function

' Convert a Date into a SYSTEMTIME.
Private Sub DateToSystemTime(ByVal the_date As Date, ByRef system_time As SYSTEMTIME)
    With system_time
        .wYear = Year(the_date)
        .wMonth = Month(the_date)
        .wDay = Day(the_date)
        .wHour = Hour(the_date)
        .wMinute = Minute(the_date)
        .wSecond = Second(the_date)
    End With
End Sub

' Convert a UTC time into local time.
Public Function UTCToLocalTime(ByVal the_date As Date) As Date
Dim system_time As SYSTEMTIME
Dim local_file_time As FILETIME
Dim utc_file_time As FILETIME

    ' Convert it into a SYSTEMTIME.
    DateToSystemTime the_date, system_time

    ' Convert it to a UTC time.
    SystemTimeToFileTime system_time, utc_file_time

    ' Convert it to a Local Date From the UTC file time.
    UTCToLocalTime = FileTimeToDate(utc_file_time)
End Function

' Converts the windows API FILETIME to a VB Date
Public Function FileTimeToDate(lpFileTime As FILETIME) As Date
    Dim lpLocalFileTime As FILETIME
    Dim lpSystemTime As SYSTEMTIME
    Dim dResult As Date
    dResult = Empty
    ' Convert from UTC-based to the local file time
    If FileTimeToLocalFileTime(lpFileTime, lpLocalFileTime) Then
        ' Unpack FILETIME structure to SYSTEMTIME structure
        If FileTimeToSystemTime(lpLocalFileTime, lpSystemTime) Then
            ' Create Visual Basic Date value
            dResult = DateSerial(lpSystemTime.wYear, _
                lpSystemTime.wMonth, lpSystemTime.wDay) _
                + TimeSerial(lpSystemTime.wHour, _
                lpSystemTime.wMinute, lpSystemTime.wSecond)
        End If
    End If
    FileTimeToDate = dResult
End Function
'Returns the path to the temp directory
Public Function GetTempPath() As String
  Dim s As String
  Dim i As Integer
  i = GetTempPathA(0, "")
  s = Space(i)
  Call GetTempPathA(i, s)
  s = Left$(s, i - 1)

  ' Add backslash if one absent
  If Len(s) > 0 Then

    If Right$(s, 1) <> "\" Then
      GetTempPath = s + "\"
    Else
      GetTempPath = s
    End If

  Else
    GetTempPath = "\"
  End If

End Function

' Determine whether Windows version is Vista or newer.  Useful for determining
' whether to do special functions for UAC

Public Function IsVistaOrNewer() As Boolean
    
    Dim osv As OSVERSIONINFO
    osv.OSVSize = Len(osv)
    
    IsVistaOrNewer = False

    If GetVersionEx(osv) = 1 And osv.PlatformID = VER_PLATFORM_WIN32_NT And osv.dwVerMajor > 5 Then
        IsVistaOrNewer = True
    End If
    
End Function

' Sets a thinborder on a windows control
Public Function ThinBorder(ByVal lhWnd As Long, ByVal bState As Boolean)
    Dim rtnVal As Long
    
    rtnVal = GetWindowLong(lhWnd, GWL_STYLE)
    If bState Then

        rtnVal = rtnVal And (Not WS_CAPTION) And (Not WS_THICKFRAME) And (Not WS_MINIMIZE) And (Not WS_MAXIMIZE) And (Not WS_SYSMENU)

    End If

    SetWindowLong lhWnd, GWL_STYLE, rtnVal
    SetWindowPos lhWnd, 0, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE Or SWP_NOOWNERZORDER Or SWP_NOZORDER Or SWP_FRAMECHANGED
   
    ' Get current border style
    rtnVal = GetWindowLong(lhWnd, GWL_EXSTYLE)
   
    ' Set new border style according to bState
    If Not (bState) Then
        ' make the button look normal
        rtnVal = rtnVal Or WS_EX_CLIENTEDGE And Not WS_EX_STATICEDGE
    Else
        ' make it flat
        rtnVal = rtnVal Or WS_EX_STATICEDGE And Not WS_EX_CLIENTEDGE

    End If
    
    ' Apply the change
    SetWindowLong lhWnd, GWL_EXSTYLE, rtnVal
    SetWindowPos lhWnd, 0, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE Or SWP_NOOWNERZORDER Or SWP_NOZORDER Or SWP_FRAMECHANGED

    
End Function

' Creates region around the control to give it a flat look
Public Function RemoveControlBorder(ByVal lhWnd As Long, ByVal ControlTwipWidth As Long, ByVal ControlTwipHeight As Long, ByVal RegionOffset As Long, ByVal TwipsPerPixel As Long, Optional RegionHeightOffset As Long = -999)
    
    Dim hRegion As Long
    
    If RegionHeightOffset = -999 Then
        RegionHeightOffset = RegionOffset
    End If

    'This create a region that will remove the border
    hRegion = CreateRectRgn(RegionOffset, RegionOffset, (ControlTwipWidth / TwipsPerPixel) - RegionOffset, (ControlTwipHeight / TwipsPerPixel) - RegionHeightOffset)
     
    'This will set the region to the commandbutton
    SetWindowRgn lhWnd, hRegion, True
    
End Function

Public Function ExistsInCollection(col As Collection, Index) As Boolean
On Error GoTo ExistsTryNonObject
    Dim o As Object

    Set o = col(Index)
    ExistsInCollection = True
    Exit Function

ExistsTryNonObject:
    ExistsInCollection = ExistsNonObject(col, Index)
End Function

Private Function ExistsNonObject(col, Index) As Boolean
On Error GoTo ExistsNonObjectErrorHandler
    Dim v As Variant

    v = col(Index)
    ExistsNonObject = True
    Exit Function

ExistsNonObjectErrorHandler:
    ExistsNonObject = False
End Function

' Determines whether the array has the specified index
Public Function HasIndex(ControlArray As Object, ByVal Index As Integer) As Boolean
    HasIndex = (VarType(ControlArray(Index)) <> vbObject)
End Function
