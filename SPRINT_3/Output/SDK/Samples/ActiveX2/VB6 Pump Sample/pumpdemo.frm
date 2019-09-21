VERSION 5.00
Object = "{5E9E78A0-531B-11CF-91F6-C2863C385E30}#1.0#0"; "Msflxgrd.ocx"
Object = "{FE0065C0-1B7B-11CF-9D53-00AA003C9CB6}#1.1#0"; "Comct232.ocx"
Object = "{6B7E6392-850A-101B-AFC0-4210102A8DA7}#1.3#0"; "Comctl32.ocx"
Object = "{EC8C50F3-6809-11D1-9606-0000C04B2BD0}#1.0#0"; "EnbPumpX2.ocx"
Object = "{7E30E4B5-7BA3-11D1-9623-0000C04B2BD0}#1.0#0"; "EnbSessionX2.ocx"
Object = "{52063922-2470-472F-A563-CFCF28C88A5B}#1.0#0"; "EnbAttendantX2.ocx"
Begin VB.Form MainForm 
   Caption         =   "MainForm"
   ClientHeight    =   7515
   ClientLeft      =   825
   ClientTop       =   -270
   ClientWidth     =   9285
   BeginProperty Font 
      Name            =   "Arial"
      Size            =   9.75
      Charset         =   204
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   Icon            =   "pumpdemo.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   7515
   ScaleWidth      =   9285
   StartUpPosition =   1  'CenterOwner
   Begin VB.Timer DelayForClearPumps 
      Enabled         =   0   'False
      Interval        =   5000
      Left            =   1080
      Top             =   2880
   End
   Begin EnbAttendantX2Lib.EnbAttX2 Attendant 
      Height          =   600
      Left            =   480
      TabIndex        =   45
      Top             =   960
      Visible         =   0   'False
      Width           =   600
      _Version        =   65536
      _ExtentX        =   1058
      _ExtentY        =   1058
      _StockProps     =   0
   End
   Begin ENBPUMPX2Lib.EnbPumpX2 Pump 
      Height          =   1260
      Index           =   1
      Left            =   1200
      TabIndex        =   42
      Top             =   240
      Width           =   1260
      _ExtentX        =   2223
      _ExtentY        =   2223
      _StockProps     =   0
   End
   Begin VB.Frame ClearFrame 
      BorderStyle     =   0  'None
      Caption         =   "Sale"
      Height          =   1815
      Left            =   6840
      TabIndex        =   38
      Top             =   5400
      Width           =   855
      Begin VB.CommandButton UndoReinstateButton 
         Caption         =   "Undo Reinstate"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   612
         Left            =   0
         TabIndex        =   40
         Top             =   360
         Width           =   852
      End
      Begin VB.CommandButton Clear 
         Caption         =   "Clear"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   0
         TabIndex        =   39
         Top             =   1080
         Width           =   855
      End
   End
   Begin VB.Frame MiscFrame 
      BorderStyle     =   0  'None
      Caption         =   "Frame1"
      Height          =   2415
      Left            =   4080
      TabIndex        =   25
      Top             =   2880
      Width           =   5055
      Begin VB.CommandButton CaptionText 
         Caption         =   "Set Caption Text"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   960
         TabIndex        =   46
         Top             =   1080
         Width           =   975
      End
      Begin VB.CommandButton ClearMessageButton 
         Caption         =   "OK"
         Height          =   495
         Left            =   4320
         TabIndex        =   43
         Top             =   480
         Width           =   615
      End
      Begin VB.TextBox Subtotal 
         Alignment       =   1  'Right Justify
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   2160
         MultiLine       =   -1  'True
         TabIndex        =   36
         TabStop         =   0   'False
         Top             =   0
         Width           =   2775
      End
      Begin VB.TextBox CurrentPump 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   1080
         TabIndex        =   34
         Text            =   "0"
         Top             =   2040
         Width           =   375
      End
      Begin VB.CommandButton PeriodsButton 
         Caption         =   "Close Period"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   4080
         TabIndex        =   32
         Top             =   1800
         Width           =   855
      End
      Begin VB.CommandButton MenuButton 
         Caption         =   "Prices/ Profile"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   2160
         TabIndex        =   31
         Top             =   1800
         Width           =   855
      End
      Begin VB.CommandButton AttendantButton 
         Caption         =   "Attendant"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   3120
         TabIndex        =   30
         Top             =   1080
         Width           =   855
      End
      Begin VB.CommandButton ManualDelivery 
         Caption         =   "Manual delivery"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   612
         Left            =   4080
         TabIndex        =   29
         Top             =   1080
         Width           =   855
      End
      Begin VB.CommandButton ReinstateButton 
         Caption         =   "Reinstate delivery"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   612
         Left            =   2160
         TabIndex        =   28
         Top             =   1080
         Width           =   852
      End
      Begin VB.CommandButton ActivatePopup 
         Caption         =   "Pump Pop-up"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   612
         Left            =   0
         TabIndex        =   27
         Top             =   1080
         Width           =   852
      End
      Begin VB.CommandButton TankButton 
         Caption         =   "Tanks"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   3120
         TabIndex        =   26
         Top             =   1800
         Width           =   855
      End
      Begin ComCtl2.UpDown CurrentPumpUpDown 
         Height          =   285
         Left            =   1455
         TabIndex        =   33
         TabStop         =   0   'False
         Top             =   2040
         Width           =   240
         _ExtentX        =   450
         _ExtentY        =   503
         _Version        =   327681
         Value           =   1
         BuddyControl    =   "CurrentPump"
         BuddyDispid     =   196619
         OrigLeft        =   2880
         OrigTop         =   6240
         OrigRight       =   3120
         OrigBottom      =   6615
         Max             =   4
         Min             =   1
         SyncBuddy       =   -1  'True
         BuddyProperty   =   65547
         Enabled         =   -1  'True
      End
      Begin VB.Label MessageLabel 
         Caption         =   "Messages..."
         ForeColor       =   &H000000C0&
         Height          =   495
         Left            =   0
         TabIndex        =   44
         Top             =   480
         Width           =   4215
      End
      Begin VB.Label SaleState 
         Alignment       =   1  'Right Justify
         BorderStyle     =   1  'Fixed Single
         Caption         =   "Subtotal"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   0
         TabIndex        =   37
         Top             =   0
         Width           =   2055
      End
      Begin VB.Label CurrentPumpLabel 
         Caption         =   "Current Pump:"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   0
         TabIndex        =   35
         Top             =   2040
         Width           =   1215
      End
   End
   Begin VB.Frame PumpControlFrame 
      Caption         =   "Pump Control"
      Height          =   1815
      Left            =   0
      TabIndex        =   14
      Top             =   5400
      Width           =   3375
      Begin VB.CommandButton AllStop 
         Caption         =   "All Stop"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   840
         TabIndex        =   22
         Top             =   1080
         Width           =   615
      End
      Begin VB.CommandButton AllAuth 
         Caption         =   "All Auth"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   120
         TabIndex        =   21
         Top             =   1080
         Width           =   615
      End
      Begin VB.CommandButton Prepay 
         Caption         =   "Prepay"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   1560
         TabIndex        =   20
         Top             =   1080
         Width           =   735
      End
      Begin VB.CommandButton PreAuth 
         Caption         =   "Preauth"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   2400
         TabIndex        =   19
         Top             =   360
         Width           =   855
      End
      Begin VB.CommandButton Auth 
         Caption         =   "Auth"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   120
         TabIndex        =   18
         Top             =   360
         Width           =   615
      End
      Begin VB.CommandButton TempStop 
         Caption         =   "Temp Stop"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   840
         TabIndex        =   17
         Top             =   360
         Width           =   615
      End
      Begin VB.CommandButton PresetButton 
         Caption         =   "Preset"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   1560
         TabIndex        =   16
         Top             =   360
         Width           =   735
      End
      Begin VB.CommandButton AttendantAuth 
         Caption         =   "Attendant Auth"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   612
         Left            =   2400
         TabIndex        =   15
         Top             =   1080
         Width           =   852
      End
   End
   Begin VB.Frame DeliveryFrame 
      Caption         =   "Delivery"
      Height          =   1815
      Left            =   3480
      TabIndex        =   9
      Top             =   5400
      Width           =   1575
      Begin VB.CommandButton Stack 
         Caption         =   "Stack"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   120
         TabIndex        =   13
         Top             =   360
         Width           =   615
      End
      Begin VB.CommandButton TakeDel 
         Caption         =   "To Sale"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   840
         TabIndex        =   12
         Top             =   360
         Width           =   615
      End
      Begin VB.CommandButton TestDelButton 
         Caption         =   "Test Del"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   120
         TabIndex        =   11
         Top             =   1080
         Width           =   615
      End
      Begin VB.CommandButton DriveOffButton 
         Caption         =   "Drive Off"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   600
         Left            =   840
         TabIndex        =   10
         Top             =   1080
         Width           =   615
      End
   End
   Begin VB.Frame PaymentFrame 
      Caption         =   "Payment"
      Height          =   1815
      Left            =   7800
      TabIndex        =   6
      Top             =   5400
      Width           =   1455
      Begin VB.CommandButton Cash 
         Caption         =   "Cash"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   120
         TabIndex        =   8
         Top             =   360
         Width           =   1215
      End
      Begin VB.CommandButton CreditCard 
         Caption         =   "Credit Card"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   120
         TabIndex        =   7
         Top             =   1080
         Width           =   1215
      End
   End
   Begin VB.Frame ProductsFrame 
      Caption         =   "Products"
      Height          =   1815
      Left            =   5160
      TabIndex        =   3
      Top             =   5400
      Width           =   1575
      Begin VB.CommandButton Product4 
         Caption         =   "News paper"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   840
         TabIndex        =   24
         Top             =   1080
         Width           =   615
      End
      Begin VB.CommandButton Product2 
         Caption         =   "Candy bar"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   840
         TabIndex        =   23
         Top             =   360
         Width           =   615
      End
      Begin VB.CommandButton Product3 
         Caption         =   "Coke Can"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   120
         TabIndex        =   5
         Top             =   1080
         Width           =   615
      End
      Begin VB.CommandButton Product1 
         Caption         =   "Oil Pack"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   120
         TabIndex        =   4
         Top             =   360
         Width           =   615
      End
   End
   Begin ComctlLib.StatusBar PumpStatusBar 
      Align           =   2  'Align Bottom
      Height          =   255
      Left            =   0
      TabIndex        =   1
      Top             =   7260
      Width           =   9285
      _ExtentX        =   16378
      _ExtentY        =   450
      SimpleText      =   ""
      _Version        =   327682
      BeginProperty Panels {0713E89E-850A-101B-AFC0-4210102A8DA7} 
         NumPanels       =   5
         BeginProperty Panel1 {0713E89F-850A-101B-AFC0-4210102A8DA7} 
            Alignment       =   1
            Object.Width           =   1941
            MinWidth        =   1941
            TextSave        =   ""
            Key             =   "Pump"
            Object.Tag             =   ""
         EndProperty
         BeginProperty Panel2 {0713E89F-850A-101B-AFC0-4210102A8DA7} 
            Object.Width           =   4410
            MinWidth        =   4410
            TextSave        =   ""
            Key             =   "Status"
            Object.Tag             =   ""
         EndProperty
         BeginProperty Panel3 {0713E89F-850A-101B-AFC0-4210102A8DA7} 
            Object.Width           =   706
            MinWidth        =   706
            TextSave        =   ""
            Key             =   "Level"
            Object.Tag             =   ""
         EndProperty
         BeginProperty Panel4 {0713E89F-850A-101B-AFC0-4210102A8DA7} 
            Object.Width           =   5292
            MinWidth        =   5292
            TextSave        =   ""
            Key             =   "Current"
            Object.Tag             =   ""
         EndProperty
         BeginProperty Panel5 {0713E89F-850A-101B-AFC0-4210102A8DA7} 
            Object.Width           =   52917
            MinWidth        =   52917
            TextSave        =   ""
            Key             =   "Memory"
            Object.Tag             =   ""
         EndProperty
      EndProperty
   End
   Begin MSFlexGridLib.MSFlexGrid SaleGrid 
      Height          =   2415
      Left            =   4080
      TabIndex        =   0
      TabStop         =   0   'False
      Top             =   360
      Width           =   4935
      _ExtentX        =   8705
      _ExtentY        =   4260
      _Version        =   393216
      Rows            =   1
      Cols            =   4
      FixedCols       =   0
      SelectionMode   =   1
      AllowUserResizing=   1
   End
   Begin ENBSESSIONX2Lib.EnbSessionX2 Session 
      Height          =   600
      Left            =   480
      TabIndex        =   41
      Top             =   240
      Visible         =   0   'False
      Width           =   600
      _Version        =   65536
      _ExtentX        =   1058
      _ExtentY        =   1058
      _StockProps     =   0
   End
   Begin VB.Label SaleWindowLabel 
      Alignment       =   2  'Center
      Caption         =   "Sale Items"
      Height          =   255
      Left            =   4320
      TabIndex        =   2
      Top             =   120
      Width           =   5535
   End
   Begin VB.Menu mnFile 
      Caption         =   "File"
      Begin VB.Menu mnLogon 
         Caption         =   "Logon"
      End
      Begin VB.Menu mnLogoff 
         Caption         =   "Logoff"
      End
      Begin VB.Menu mnExit 
         Caption         =   "Exit"
      End
   End
   Begin VB.Menu mnIconStyle 
      Caption         =   "Icon Style"
      Begin VB.Menu mnSetIconStyle 
         Caption         =   "Landscape"
         Index           =   0
      End
      Begin VB.Menu mnSetIconStyle 
         Caption         =   "Large Icons"
         Checked         =   -1  'True
         Index           =   1
      End
      Begin VB.Menu mnSetIconStyle 
         Caption         =   "Small Icons"
         Index           =   2
      End
      Begin VB.Menu mnSetIconStyle 
         Caption         =   "Money + Volume"
         Index           =   3
      End
      Begin VB.Menu mnIconSep1 
         Caption         =   "-"
      End
      Begin VB.Menu mnPumpIcon_FlatStyle 
         Caption         =   "Flat style"
      End
      Begin VB.Menu mnPumpIcon_UseBackgroundColors 
         Caption         =   "Background colors"
      End
      Begin VB.Menu mnPumpIcon_UseNewIcons 
         Caption         =   "Use New Style Icons"
      End
      Begin VB.Menu mnIconSep2 
         Caption         =   "-"
      End
      Begin VB.Menu mnMonitorTotal 
         Caption         =   "Monitor Total"
         Checked         =   -1  'True
      End
      Begin VB.Menu mnMonitorVol 
         Caption         =   "Monitor Volume"
      End
      Begin VB.Menu mnIconSep3 
         Caption         =   "-"
      End
      Begin VB.Menu mnPumpVisible 
         Caption         =   "Visible"
         Checked         =   -1  'True
      End
   End
   Begin VB.Menu mnOptions 
      Caption         =   "Options"
      Begin VB.Menu mnPopupEnabled 
         Caption         =   "Popup Enabled"
         Checked         =   -1  'True
      End
      Begin VB.Menu mnModalPopup 
         Caption         =   "Modal popup"
         Checked         =   -1  'True
      End
      Begin VB.Menu mnOptionsSep1 
         Caption         =   "-"
      End
      Begin VB.Menu mnTouchScreen 
         Caption         =   "Touch Screen"
         Checked         =   -1  'True
      End
      Begin VB.Menu mnQuickSelect 
         Caption         =   "Quick Select"
         Checked         =   -1  'True
      End
      Begin VB.Menu mnQuickAuth 
         Caption         =   "Quick Auth"
      End
      Begin VB.Menu mnUserInputEnabled 
         Caption         =   "User Input Enabled"
         Checked         =   -1  'True
      End
      Begin VB.Menu mnOptionsSep2 
         Caption         =   "-"
      End
      Begin VB.Menu mnTracePumps 
         Caption         =   "Trace Pump Events"
      End
      Begin VB.Menu mnTraceSelectedPumps 
         Caption         =   "Trace Selected Pump Events"
      End
      Begin VB.Menu mnOptionsSep3 
         Caption         =   "-"
      End
      Begin VB.Menu mnPumpLights 
         Caption         =   "Pump Lights"
      End
      Begin VB.Menu mnOptionsSep4 
         Caption         =   "-"
      End
      Begin VB.Menu mnClearCompletedPreauths 
         Caption         =   "Clear Completed Preauths"
      End
   End
   Begin VB.Menu mnMessages 
      Caption         =   "Messages"
      Begin VB.Menu mnDispServerErrors 
         Caption         =   "Display Server Errors"
         Checked         =   -1  'True
      End
      Begin VB.Menu mnDisplayServerMessages 
         Caption         =   "Display Server Messages"
         Checked         =   -1  'True
      End
      Begin VB.Menu mnPrepayCompleted 
         Caption         =   "Prepay Completed Messages"
         Checked         =   -1  'True
      End
   End
   Begin VB.Menu mnHelp 
      Caption         =   "Help"
      Begin VB.Menu mnAbout 
         Caption         =   "About"
      End
   End
End
Attribute VB_Name = "MainForm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'*****************************************************************
'*
'* Pumpdemo main form
'*
'* Copyright (C) 2007 Integration Technologies Limited
'* All rights reserved.
'*
'* This is the main module in our VB Sample Application.  This module
'* includes code to initialise the EnbSessionX and EnbPumpX controls.
'* This includes lots of basic code to activate functions on the
'* controls, plus code to implement event handlers
'*
'******************************************************************

Option Explicit

Const AppName As String = "PumpDemo"

'use initial Form width/height set with IDE as min size
Dim minWidth, minHeight

Dim iconStyle As Integer
Dim SyncFlag As Boolean
Dim ClearPumpsFlag As Boolean
Private TerminalID As Long

Enum StatusPanels
    pPumpName = 1
    pPumpState
    pPriceLevel
    pCurrentDelivery
    pStackDelivery
End Enum

Public Enum RestartState
    rsNone = 1
    rsReserved
    rsAuthorised
    rsDelivering
    rsDelivered
End Enum

Public Version4 As Boolean



'******************************************************************
'*
'*  ShowPumpStatus - updates the status bar on the bottom of the screen
'*      there are four panels, the second panel request the panel to update,
'*      panel 0 is passed it updates all four.
'*      Panel - function
'*      1 - pump name
'*      2 - pump status
'*      3 - price level
'*      4 - current delivery or running total
'*      5 - first stack delivery
'*
'******************************************************************
Private Sub ShowPumpStatus(PumpNum As Integer, PanelNum As Integer)

Dim grade As String
Dim Price As Currency
Dim Value As Currency
Dim Volume As Currency
Dim DelType As Integer
Dim newText As String

    ' if this is not the currently selected pump then do nothing
    If PumpNum <> Session.SelectedPump Then
        Exit Sub
    End If
    
    ' if this pump number is not installed then treat it as if none were selected
    If PumpNum > 0 And Pump(PumpNum) Is Nothing Then
        PumpNum = 0
    End If
    
    newText = ""
    
    With Pump(Session.SelectedPump)
        ' panel 1 is the pump description
        If PanelNum = 0 Or PanelNum = 1 Then
            If PumpNum = 0 Then
                newText = "None selected"
            Else
                newText = Trim(.Description)
            End If
            
            PumpStatusBar.Panels(1).Text = newText
        End If
        
        ' panel 2 is the pump state
        If PanelNum = 0 Or PanelNum = 2 Then
            newText = ""
            If PumpNum > 0 Then
                newText = .StateString
            End If
            
            PumpStatusBar.Panels(2).Text = newText
        End If
        
        ' panel 3 is price level
        If PanelNum = 0 Or PanelNum = 2 Or PanelNum = 3 Then
            If PumpNum = 0 Then
                PumpStatusBar.Panels(3).Text = ""
            Else
                PumpStatusBar.Panels(3).Text = "L" + CStr(.CurrentLevel)
            End If
        End If
        
        ' panel 4 is the current delivery or the running total
        If PanelNum = 0 Or PanelNum = 4 Then
            
            newText = ""
            If PumpNum <> 0 Then
                If .RunningTotal > 0 Then
                    newText = "Running total  " + Format(.RunningTotal, "currency") + " @ " + CStr(.RunningPrice)
                ElseIf Not .CurrentDelivery Is Nothing Then
                    .GetCurSummary grade, Volume, Value, Price, DelType
                    If grade <> "" And Volume > 0 Then
                        newText = grade + "  " + Format(Value, "currency") + "  " + Format(Volume, "fixed") & "L"
                    End If
                End If
            End If
            
            PumpStatusBar.Panels(4).Text = newText
            
        End If
        
        ' panel 5 is the first delivery in the stack
        If PanelNum = 0 Or PanelNum = 5 Then
            If PumpNum = 0 Then
                PumpStatusBar.Panels(5).Text = ""
            Else
                .GetMemSummary grade, Volume, Value, Price, DelType
                If grade <> "" And Volume > 0 Then
                    PumpStatusBar.Panels(5).Text = grade & "    " & Format(Volume, "fixed") & "L    " & Format(Value, "currency")
                Else
                    PumpStatusBar.Panels(5).Text = ""
                End If
            End If
        End If
        
    End With
    
End Sub

'******************************************************************
'*
'*  Handling of server error messages.
'*     These are displayed in a text label, not a dialog,
'*     so that they don't disrupt the operator using the system
'*
'******************************************************************
Private Sub SetMessage(Text As String)
    MessageLabel.Caption = Text
    ClearMessageButton.Visible = True
    'if one pump is selected for tracing,we ignore server errors
    If TraceForm.SelectedPump <> 0 Then
        Exit Sub
    End If
    ' trace it
    TraceForm.TraceText Text
End Sub

Private Sub ClearMessage()
    MessageLabel.Caption = ""
    ClearMessageButton.Visible = False
End Sub



Private Sub Attendant_TagReadEvent(ByVal TagID As Long, _
                                   ByVal TagData As String, _
                                   ByVal TagPresent As Integer, _
                                   ByVal TagReaderID As Long, _
                                   ByVal PumpNumber As Long, _
                                   ByVal AttendantID As Long)
                                   
    ' Prints the tag read data to the trace window. This event could validate the
    ' tag data and then confirm the pump is calling and authorise the pump from this event
    TraceForm.TraceText "Attendant Tag Read Event =" & _
                        " TagID - " + Format(TagID) & _
                        ", TagPresent - " + Format(TagPresent) & _
                        ", TagReaderID - " + Format(TagReaderID) & _
                        ", PumpNumber - " + Format(PumpNumber) & _
                        ", AttendantID - " + Format(AttendantID) & _
                        ", TagData - " + TagData

End Sub

Private Sub CaptionText_Click()
    ' if no pump is currently selected then cannot reinstate a delivery
    If Session.SelectedPump < 1 Then
        MsgBox "Please select a pump first.", vbExclamation
        Exit Sub
    End If
    
    CaptionDlg.CaptionPump = Session.SelectedPump
    CaptionDlg.Caption = "Pump " & CStr(Session.SelectedPump) & " Caption Text"
    
    CaptionDlg.Show vbModal
End Sub

Private Sub ClearMessageButton_Click()
    ClearMessage
End Sub

'******************************************************************
'*
'*  ActivatePopup_Click
'*     this button demonstrates how to use the EnbPumpX.ActivatePopup
'*     method - this method shows the delivery stack, and buttons to
'*     perform some actions on the selected pump
'*
'******************************************************************
Private Sub ActivatePopup_Click()

    If Session.SelectedPump < 1 Then
        MsgBox "Please select a pump first.", vbExclamation
        Exit Sub
    End If
    
    Pump(Session.SelectedPump).ActivatePopup
    
End Sub

'******************************************************************
'*
'*  AllAuth_Click - click event for AllAuth button
'*
'******************************************************************
Private Sub AllAuth_Click()

    ' note this method does not return a result as the action
    ' taken may vary but always be successful
    ' this authorises all calling pumps
    Session.AllAuthorise
    
End Sub

'******************************************************************
'*
'*  AllStop_Click - click event for AllStop button
'*
'******************************************************************
Private Sub AllStop_Click()

    ' All stop method similarly returns no result
    ' this will temp stop all authorised or deliverying pumps
    Session.AllStop
    
End Sub

Private Sub AttendantLogon_Click()

Dim Att As Attendant
Dim name As String
Dim logonid As String
Dim Password As String
 
    Set Att = Session.Attendant(1)
    
    If Not Att Is Nothing Then
        name = Att.name
        logonid = Att.logonid
        Password = Att.Password
    End If
 
End Sub

Private Sub AttendantAuth_Click()
    Dim NumAtt As Integer
    
    ' if no pump is currently selected then cannot do prepay
    ' delivery
    If Session.SelectedPump < 1 Then
        MsgBox "Please select a pump first.", vbExclamation + vbOKOnly
        Exit Sub
    End If
    
    NumAtt = Session.NumberOfAttendants
    If NumAtt < 1 Then
        MsgBox "No Attendant are setup", vbOKOnly + vbExclamation
        Exit Sub
    End If

    ' start the prepay dialog saving the number of the pump first
    AttAuthDlg.AuthPump = Session.SelectedPump
    
    AttAuthDlg.Show vbModal

End Sub

Private Sub AttendantButton_Click()
    Dim NumAtt As Integer
    
    NumAtt = Session.NumberOfAttendants
    If NumAtt < 1 Then
        MsgBox "No Attendant are setup", vbOKOnly + vbExclamation
        Exit Sub
    End If
    AttendantDlg.Show vbModal
End Sub

'******************************************************************
'*
'*  Auth_Click - click event for Auth button, authorise currently
'*               selected pump
'*
'******************************************************************
Private Sub Auth_Click()

Dim result As Integer
    
    ' if there is currently a selected pump
    ' attempt to authorise this pump
    If Session.SelectedPump >= 1 Then
        TraceForm.TraceText "Authorising Pump" + Str(Pump(Session.SelectedPump).Number) + "..."
        result = Pump(Session.SelectedPump).Authorise
        
        ' check result, if not Okay then display error string
        ' as retrieved from session object
        If result <> OK_RESULT Then
            MsgBox Session.ResultString(result), vbExclamation
        End If
        
    End If
End Sub

'******************************************************************
'*
'*  Cash_Click
'*    process event for Cash button, finalise current sale with cash
'*
'******************************************************************
Private Sub Cash_Click()
    ' FinaliseSale contained in sales.bas
    ' CashFinalised is price level used for prepay deliveries
    If Session.NumberOfPumps > 0 Then
        FinaliseSale "Cash", cashfinalised
    Else
        MsgBox "Cannot finalise sale, Not connected to Pump Server", vbExclamation + vbOKOnly
    End If
End Sub

'******************************************************************
'*
'*  CreditCard_Click
'*    process event for CreditCard button, finalise sale with credit card
'*
'******************************************************************
Private Sub CreditCard_Click()
    ' FinaliseSale contained in sales.bas
    ' CreditFinalised is price level used for prepay deliveries
    If Session.NumberOfPumps > 0 Then
        FinaliseSale "Credit", CreditFinalised
    Else
        MsgBox "Cannot finalise sale, Not connected to Pump Server", vbExclamation + vbOKOnly
    End If
End Sub

'******************************************************************
'*
'*  Clear_Click - click event for Clear button, clears the sale window
'*            if not finalised releases any deliveries and cancels any
'*            any prepays.
'*
'******************************************************************
Private Sub Clear_Click()

Dim result As Integer
Dim i As Integer
Dim ConnectedToPumpServer As Boolean

    ' check we are connected to pump server - there is no specific property for that
    ' but the NumberOfXXX properties all report zero when pump server is disconnected
    ConnectedToPumpServer = Session.NumberOfPumps > 0
    
    ' search all the sale items for locked deliveries or prepay reserves
    For i = 0 To Sale.NumberOfItems - 1
        With Sale.Items(i)
            ' if the .del member is currently assigned then
            ' release the delivery lock and unassign the handle
            If Not .del Is Nothing Then
                
                If ConnectedToPumpServer Then
                    result = .del.ReleaseLock(Session.TerminalID)
                    ' check result, if not Okay then display error string
                    ' as retrieved from session object
                    If result <> OK_RESULT Then
                        MsgBox Session.ResultString(result), vbExclamation
                    End If
                    
                End If
                
                ' this release the delivery object
                Set .del = Nothing
            
            ' if it is a prepay item then cancel the prepay
            ElseIf .ItemType = prepayItem Then
                If ConnectedToPumpServer Then
                    result = Pump(.PumpNumber).CancelPrepay
                    ' check result, if not Okay then display error string
                    ' as retrieved from session object
                    If result <> OK_RESULT Then
                        MsgBox Session.ResultString(result), vbExclamation
                    End If
                End If
            End If
        End With
    Next i

    ' reset all other sale variables to signify an empty sale
    With Sale
        .NumberOfItems = 0
        .State = SaleOpen
        .Subtotal = 0
    End With
    
    SaleGrid.Rows = 1
    SaleGrid.FocusRect = flexFocusLight
    SaleGrid.col = 0
    SaleGrid.ColSel = 0
    
    SaleState.Caption = "Subtotal"
    Subtotal.Text = Format(0, "currency")
    
    ' Pump stuck in RESERVED_FOR_PREPAY? cancel it!
    If Session.SelectedPump >= 1 Then
        If Pump(Session.SelectedPump).ReservedState = RESERVED_FOR_PREPAY Then
            result = Pump(Session.SelectedPump).CancelPrepay
            If result <> OK_RESULT Then
                MsgBox Session.ResultString(result), vbExclamation
            End If
        End If
    End If
    
End Sub



Private Sub MenuButton_Click()
    Dim NumGrades As Integer
    
    NumGrades = Session.NumberOfGrades
    
    If NumGrades < 1 Then
        MsgBox "Could not load list of Grades"
        Exit Sub
    End If
    
    ForecourtDlg.Show vbModal
End Sub

Private Sub mnClearCompletedPreauths_Click()
    mnClearCompletedPreauths.Checked = Not mnClearCompletedPreauths.Checked
End Sub

Private Sub mnPrepayCompleted_Click()
    mnPrepayCompleted.Checked = Not mnPrepayCompleted.Checked
End Sub

'******************************************************************
'*
'* the following code shows how the EnbSessionX.Logoff and
'* EnbSessionX.Logon methods can be used
'*
'******************************************************************
Private Sub mnLogoff_Click()

    Session.Logoff
    
    mnLogoff.Enabled = False
    mnLogon.Enabled = True
    
    ' Remove all items from sale window
    Clear_Click
    
End Sub

Private Sub mnLogon_Click()

Dim i As Integer

    SetSynchroniseOnLogon (SyncFlag)

    ' if the logon fails this demo application will exit
    If CheckLogon(Session.Logon(TerminalID, "PumpDemo")) Then
        mnLogon.Enabled = False
        mnLogoff.Enabled = True
        
        ' after logging off we reassign the Session property on each pump control
        ' Load pump controls
        LoadAllPumps
    End If

End Sub




'******************************************************************
'*
'*  mnPumpLights_Click - click event for PumpLights menu item,
'*      toggles the pump lights on and off
'*
'******************************************************************
Private Sub mnPumpLights_Click()
    
    mnPumpLights.Checked = Not mnPumpLights.Checked
    Session.PumpLights = mnPumpLights.Checked
        
End Sub

Private Sub mnPumpVisible_Click()
Dim i As Integer

    mnPumpVisible.Checked = Not mnPumpVisible.Checked
    For i = 1 To Session.NumberOfPumps
        If Not Pump(i) Is Nothing Then
            If Pump(i).State <> NOT_INSTALLED_PSTATE Then
                Pump(i).Visible = mnPumpVisible.Checked
            End If
        End If
    Next i
End Sub

Private Sub mnQuickAuth_Click()

Dim i As Integer
    
    mnQuickAuth.Checked = Not mnQuickAuth.Checked
    For i = 1 To Session.NumberOfPumps
        If Not Pump(i) Is Nothing Then
            Pump(i).QuickAuthorise = mnQuickAuth.Checked
        End If
    Next i
    
End Sub

Private Sub mnQuickSelect_Click()

Dim i As Integer
    
    mnQuickSelect.Checked = Not mnQuickSelect.Checked
    For i = 1 To Session.NumberOfPumps
        If Not Pump(i) Is Nothing Then
            Pump(i).QuickSaleSelect = mnQuickSelect.Checked
        End If
    Next i
    
End Sub

Private Sub mnPumpIcon_FlatStyle_Click()
    
    mnPumpIcon_FlatStyle.Checked = Not mnPumpIcon_FlatStyle.Checked
    ChangeIconStyle

End Sub

Private Sub mnPumpIcon_UseBackgroundColors_Click()

    mnPumpIcon_UseBackgroundColors.Checked = Not mnPumpIcon_UseBackgroundColors.Checked
    ChangeIconStyle
    
End Sub

Private Sub mnPumpIcon_UseNewIcons_Click()
    
    mnPumpIcon_UseNewIcons.Checked = Not mnPumpIcon_UseNewIcons.Checked
    ChangeIconStyle

End Sub

Private Sub mnSetIconStyle_Click(Index As Integer)

Dim i As Integer
    
    For i = 0 To 3
        mnSetIconStyle(i).Checked = False
    Next i
    mnSetIconStyle(Index).Checked = True

    ChangeIconStyle

End Sub

'******************************************************************
'*
'* here we set the IconStyle on each pump icon, and rearrange
'* rearrange them based on their new size
'*
'******************************************************************
Private Sub ChangeIconStyle()

Dim i As Integer
Dim IconWidth As Integer
Dim IconHeight As Integer
Dim newStyle As Integer

    ' first figure out what the icon style should be...
    newStyle = 0
    For i = 0 To 3
        If mnSetIconStyle(i).Checked Then
            newStyle = i
        End If
    Next
    
    ' background colors are only supported in more recent versions of
    ' V3 ActiveX contols
    If mnPumpIcon_UseBackgroundColors.Checked Then
        newStyle = newStyle + 4
    End If
    
    ' Flat style is only supported in most recent versions of
    ' V3 ActiveX contols
    If mnPumpIcon_FlatStyle.Checked Then
        newStyle = newStyle + 16
    End If
    
    ' New style blue icons is only supported in very latest
    ' V3 Activex controls
    If mnPumpIcon_UseNewIcons.Checked Then
        newStyle = newStyle + 32
    End If
    
    ' now update the icons:
    ' - set IconStyle property on v3 EnbPumpX
    ' or
    ' - set LargeIcon property on v2.5 EnbPumpX
    For i = 1 To Session.NumberOfPumps
        If Not Pump(i) Is Nothing Then
            Pump(i).iconStyle = newStyle

            If IconWidth = 0 Then
                ' we need to refresh the form so the .Width and .Height properties are updated
                MainForm.Refresh
                IconWidth = Pump(i).Width
                IconHeight = Pump(i).Height
            End If
        End If
    Next i
            
    ' apparently there are no pump icons on this form
    If IconWidth = 0 Then
        Exit Sub
    End If
    
    ' optional - we now rearrange the icons, since their height/width could have changed
    ArrangePumpIcons IconWidth, IconHeight
    
End Sub

Private Sub ArrangePumpIcons(IconWidth As Integer, IconHeight As Integer)

Dim i As Integer
Dim IconsPerLine As Integer
Dim IconCount As Integer

    IconsPerLine = (SaleGrid.Left - 100) \ IconWidth
    IconCount = 0
    
    ' now relocate the icons to fit best
    For i = 1 To Session.NumberOfPumps
        If Not Pump(i) Is Nothing And Pump(i).Visible Then
            IconCount = IconCount + 1
            If IconWidth > 0 Then
                ' setup icon position based on new dimensions
                Pump(i).Left = 100 + ((IconCount - 1) Mod IconsPerLine) * (IconWidth + 10)
                Pump(i).Top = 100 + (IconHeight + 10) * ((IconCount - 1) \ IconsPerLine)
            End If
        End If
    Next i

End Sub

Private Sub CurrentPump_Change()

    If CurrentPump.Text <> "" Then
        If CurrentPump.Text <= CurrentPumpUpDown.Max Then
            CurrentPumpUpDown.Value = CurrentPump.Text
            Session.SelectedPump = CurrentPumpUpDown.Value
        End If
    End If
    
End Sub

'******************************************************************
'*
'*  MonitorVol_Click - click event for Monitor Vol menu, used to
'*                     turn value monitoring into volume monitor.
'*
'******************************************************************
Private Sub mnMonitorVol_Click()

Dim i As Integer
    
    mnMonitorVol.Checked = Not mnMonitorVol.Checked
    mnMonitorTotal.Checked = False

    ' turn the global montor totals flag on/off
    Session.RunningTotalOn = mnMonitorVol.Checked

    ' turn the per pump volume monitor flag on/off
    For i = 1 To Session.NumberOfPumps
        If Not Pump(i) Is Nothing Then
            Pump(i).DisplayRunningVolume = mnMonitorVol.Checked
        End If
    Next i
End Sub

'******************************************************************
'*
'*  MonitorTotal_Click - click event for Monitor Total menu, used to
'*                       turn running totals off/on
'*
'******************************************************************
Private Sub mnMonitorTotal_Click()

Dim i As Integer
    
    mnMonitorTotal.Checked = Not mnMonitorTotal.Checked
    mnMonitorVol.Checked = False
    
    ' turn the global montor totals flag on/off
    Session.RunningTotalOn = mnMonitorTotal.Checked
    
    ' turn the per pump volume monitor flag off
    For i = 1 To Session.NumberOfPumps
        If Not Pump(i) Is Nothing Then
            Pump(i).DisplayRunningVolume = False
        End If
    Next i
End Sub

Private Sub mnAbout_Click()
    frmAbout.Show vbModal
End Sub

Private Sub mnDispServerErrors_Click()
    mnDispServerErrors.Checked = Not mnDispServerErrors.Checked
End Sub

Private Sub mnDisplayServerMessages_Click()
    mnDisplayServerMessages.Checked = Not mnDisplayServerMessages.Checked
End Sub

Private Sub mnExit_Click()
    End
End Sub

Private Sub mnModalPopup_Click()

Dim i As Integer
    
    mnModalPopup.Checked = Not mnModalPopup.Checked
    For i = 1 To Session.NumberOfPumps
        If Not Pump(i) Is Nothing Then
            Pump(i).ModalPopup = mnModalPopup.Checked
        End If
    Next i

End Sub

Private Sub mnPopupEnabled_Click()

Dim i As Integer
    
    mnPopupEnabled.Checked = Not mnPopupEnabled.Checked
    For i = 1 To Session.NumberOfPumps
        If Not Pump(i) Is Nothing Then
            Pump(i).PopupEnabled = mnPopupEnabled.Checked
        End If
    Next i
End Sub

Private Sub mnTracePumps_Click()
    TraceForm.Show
End Sub

Private Sub mnTraceSelectedPumps_Click()
    TracePumpForm.Show
End Sub

Private Sub mnUserInputEnabled_Click()
    mnUserInputEnabled.Checked = Not mnUserInputEnabled.Checked
    Session.UserInputEnabled = Not Session.UserInputEnabled
End Sub

Private Sub PeriodsButton_Click()
    PeriodsForm.Show vbModal
End Sub

Private Sub PresetButton_Click()
    
    Dim NumHoses As Integer
    
    ' if no pump is currently selected then cannot do a preset
    If Session.SelectedPump < 1 Then
        MsgBox "Please select a pump first.", vbExclamation
        Exit Sub
    End If
    
    If Session.NumberOfPumps = 0 Then
        MsgBox "Not connected to Pump Server", vbExclamation + vbOKOnly
        Exit Sub
    End If
    
    NumHoses = Pump(Session.SelectedPump).NumberOfHoses
    
    If NumHoses < 1 Then
        MsgBox "No hoses setup for this pump"
        Exit Sub
    End If
    
    ' set the preset number and show the preset dialog
    PresetDlg.PresetPump = Session.SelectedPump
    PresetDlg.Show vbModal

End Sub

'******************************************************************
'*
'*  ProductX_Click - click events for product buttons, to make this
'*   demo more like a real POS - these add drystock to the sale window
'*
'******************************************************************
Private Sub Product1_Click()
    ' routine contained in sales.bas
    AddSaleItem DryStockitem, "Oil Pack, 4Lt", 9.95, 1#, 9.95
End Sub

Private Sub Product2_Click()
    AddSaleItem DryStockitem, "Candy bar, 125g", 1.25, 1#, 1.25
End Sub

Private Sub Product3_Click()
    AddSaleItem DryStockitem, "Coke 330ml", 1#, 1#, 1#
End Sub

Private Sub Product4_Click()
    AddSaleItem DryStockitem, "Newspaper", 0.65, 1#, 0.65
End Sub


Private Sub Pump_DeliveryStackEvent(Index As Integer, ByVal Number As Integer, ByVal newSize As Integer)
    ShowPumpStatus Index, 0
End Sub

Private Sub QuickAuth_Click()

Dim i As Integer
    
    For i = 1 To Session.NumberOfPumps
        If Not Pump(i) Is Nothing Then
            Pump(i).QuickAuthorise = mnQuickAuth.Checked
        End If
    Next i

End Sub

'******************************************************************
'*
'* Pump_PrepayCompletedEvent  (added in EnbPumpX2)
'*   this event is fired when a prepay delivery is completed, and provides
'*   information about the delivered amount, and provides a direct handle
'*   to the refund delivery object
'*
'******************************************************************
Private Sub Pump_PrepayCompletedEvent(Index As Integer, _
                                      ByVal Number As Integer, _
                                      ByVal Delivery_ID As Long, _
                                      ByVal Hose As Object, _
                                      ByVal Refund_Del_ID As Long, _
                                      ByVal RefundDelivery As Object, _
                                      ByVal PriceLevel As Integer, _
                                      ByVal Value As Currency, _
                                      ByVal Volume As Currency, _
                                      ByVal Price As Currency, _
                                      ByVal Volume2 As Currency, _
                                      ByVal Reserved As Long)

Dim Details As String

    Details = " Value " + CStr(Value) + vbCr _
            + " Volume " + CStr(Volume) + vbCr _
            + " Price " + CStr(Price) + vbCr _
            + " Price level " + CStr(PriceLevel) + vbCr _
            + " Delivery ID " + CStr(Delivery_ID) + vbCr

    If RefundDelivery Is Nothing Then
        Details = Details + vbCr _
                + " No refund"
    Else
        Details = Details + vbCr _
                + " Refund ID " + CStr(Refund_Del_ID) + vbCr _
                + " Refund Value " + CStr(RefundDelivery.Value)
        ' note other refund "delivery" details are not meaningful;
        ' only the value is really of interest
    End If
        
    TraceForm.TracePump Number, _
                        "PrepayCompletedEvent " _
                        + Replace(Details, vbCr, "")
        
    ' don't display the dialog if the timer is running
    If DelayForClearPumps.Enabled = True Then
        Exit Sub
    End If
    
    If mnPrepayCompleted.Checked Then
        MsgBox "Prepay delivery completed " + vbCr + vbCr _
               + " Pump " + CStr(Number) + vbCr _
               + Details, _
               vbInformation
    End If

End Sub

'******************************************************************
'*
'* ReinstateButton_Click
'*    This button provides an example of how The Enabler reinstate delivery
'*    functionality works - this
'*
'******************************************************************
Private Sub ReinstateButton_Click()
   
    ' if no pump is currently selected then cannot reinstate a delivery
    If Session.SelectedPump < 1 Then
        MsgBox "Please select a pump first.", vbExclamation
        Exit Sub
    End If
    
    ReinstateDlg.ReinstatePump = Session.SelectedPump
    
    ReinstateDlg.Show vbModal

End Sub

Private Sub Session_TagReadEvent(ByVal TagNumber As Long, ByVal TagData As String, ByVal TagPresent As Integer, ByVal TagReaderID As Long, ByVal PumpNumber As Long, ByVal AttendantID As Long, ByVal TagType As Long)
    Dim STagType As String
    
    Select Case TagType
    Case 1
        STagType = "Vehicle"
    Case 2:
        STagType = "External"
    Case Else
        STagType = "Attendant"
    End Select
    
    ' Prints the tag read data to the trace window.
    TraceForm.TraceText "Session Tag Read Event =" & _
                        "  Tag Number - " + Format(TagNumber) & _
                        ", TagPresent - " + Format(TagPresent) & _
                        ", TagReaderID - " + Format(TagReaderID) & _
                        ", PumpNumber - " + Format(PumpNumber) & _
                        ", AttendantID - " + Format(AttendantID) & _
                        ", Type - " + STagType & _
                        ", TagData - " + TagData

End Sub

Private Sub TankButton_Click()
    Dim NumTanks As Integer
    
    ' get the number of tanks from the session control
    NumTanks = Session.NumberOfTanks
    If NumTanks < 1 Then
        MsgBox "Could not initialise list of Tanks"
        Exit Sub
    End If
    
    TankDlg.Show vbModeless
End Sub

'******************************************************************
'*
'* DriveOffButton_Click
'*   This code provides an example of how to clear a delivery as a
'*   drive off delivery (where the customer left the site without
'*   paying for the fuel delivered).  Most systems that use this
'*   feature would also add this event to their POS audit trail.
'*
'******************************************************************
Private Sub DriveOffButton_Click()

Dim del As Delivery
Dim result As Integer

    ' is there a pump currently selected
    If Session.SelectedPump < 1 Then
        Exit Sub
    End If
    
    With Pump(Session.SelectedPump)
    
        Set del = .CurrentDelivery
        
        ' is there a current sale ?
        If Not del Is Nothing Then
            result = del.GetLock(Session.TerminalID)
            If result = OK_RESULT Then
                result = del.ClearDriveOff(Session.TerminalID)
            End If
            
            ' check result, if not Okay then display error string
            ' as retrieved from session object
            If result = OK_RESULT Then
                ' TODO - add code here to add this event to your site audit trail
            Else
                MsgBox Session.ResultString(result), vbExclamation
            End If
            
        End If
    End With

End Sub

'******************************************************************
'*
'* ManualDelivery_Click
'*   This code begins the process of manually entering a delivery
'*   into the Enabler (for mechanical pumps)
'*
'******************************************************************
Private Sub ManualDelivery_Click()
    
    ' if no pump is currently selected then cannot do manual delivery
    If Session.SelectedPump < 1 Then
        MsgBox "Please select a pump first.", vbExclamation
        Exit Sub
    End If
    
    ' start the manual delivery dialog, first setting the the pump number
    ManualDeliveryDlg.ManualPump = Session.SelectedPump
    ManualDeliveryDlg.Show vbModal
    
End Sub

'******************************************************************
'*
'* TestDelButton_Click
'*   This code provides an example of how to clear a delivery as a test
'*
'******************************************************************
Private Sub TestDelButton_Click()

Dim del As Delivery
Dim result As Integer

    ' is there a pump currently selected
    If Session.SelectedPump < 1 Then
        Exit Sub
    End If
    
    With Pump(Session.SelectedPump)
    
        Set del = .CurrentDelivery
        
        ' is there a current sale ?
        If Not del Is Nothing Then
            result = del.GetLock(Session.TerminalID)
            If result = OK_RESULT Then
                result = del.ClearTestDelivery(Session.TerminalID)
            End If
            
            ' check result, if not Okay then display error string
            ' as retrieved from session object
            If result = OK_RESULT Then
                ' TODO - add code here to add this event to your site audit trail
            Else
                MsgBox Session.ResultString(result), vbExclamation
            End If
            
        End If
    End With
    
End Sub

'******************************************************************
'*
'*  Exit_Click - click event for exit button, terminate app
'*
'******************************************************************
Private Sub Exit_Click()
   End
End Sub

'******************************************************************
'*
'*  SetSynchroniseOnLogon - Flag to do Synchronise on Logon (ON by default).
'                           We turn OFF here to persist delivery locks.
'*                          Available in SessionX2-V4 v4.6.0
'*
'******************************************************************
Private Sub SetSynchroniseOnLogon(flag As Boolean)
On Error GoTo synchronise_error
    Session.SynchroniseOnLogon = flag
    Exit Sub
synchronise_error:
    TraceForm.TraceText "SessionX does not support SynchroniseOnLogon"

End Sub

'******************************************************************
'*
'*  CheckLogon function - checks the result as returned from the
'*                        session logon.
'*
'******************************************************************
Private Function CheckLogon(result As Integer) As Boolean

    ' any one of the following results mean that the logon was effected
    ' however the previous logoff may not have been effected incorrectly
    ' hence the tests for values other the OK_RESULT
    
    If result = OK_RESULT Or _
       result = RESERVES_REMOVED_RESULT Or _
       result = LOCKS_REMOVED_RESULT Or _
       result = RESERVES_AND_LOCKS_REMOVED_RESULT Or _
       result = PREAUTH_LOCK_FOUND_RESULT Then
       CheckLogon = True
       Exit Function
    End If

    ' otherwise display error string
    ' as retrieved from session object
    MsgBox Session.ResultString(result), vbExclamation
    CheckLogon = False
    
End Function


Private Sub DelayForClearPumps_Timer()
    ClearPumps
End Sub


'******************************************************************
'*
'*  Form_load event - called when main form is loaded
'*
'******************************************************************
Private Sub Form_Load()

'Dim i As Integer
Dim SaleItem As String
'Dim Del As Delivery
Dim IconsPerLine As Integer
Dim IconWidth As Integer
Dim IconHeight As Integer
Dim IconCount As Integer
Dim TracePumps As Boolean

Dim enablerrdocn As New rdoConnection

Dim SQLPasswordID As Integer
' a counter for the number of times that tried to login as enabler with the password set
Dim EnablerPassword As String
        
    SQLPasswordID = 1
'------------------------------------------
    On Error GoTo login_error

login:
    ' Return 2 times and then continue with Database connection
 '   If SQLPasswordID < 3 Then
 '       'set the connect string with password from the list
 '       ConnectionStr_RDO = "DSN=enabler;Trusted_Connection=yes;"
 '
 '       ' connect to the Enabler Database
 '       With enablerrdocn
 '          .LoginTimeout = 10
 '         .Connect = ConnectionStr_RDO
 '          .CursorDriver = rdUseOdbc
 '          .EstablishConnection rdDriverNoPrompt
 '          .QueryTimeout = 30
 '       End With
 '   End If
'----------------------------------------------

    
    ' contained in sales.pas, initialises sale structure etc.
    InitialiseGlobals
        
    ' process any command line parameters for terminalID etc
    ProcessCommandLine TerminalID, TracePumps, SyncFlag, ClearPumpsFlag
    If TracePumps Then
        TraceForm.Show
    End If
    
    SetSynchroniseOnLogon (SyncFlag)
    
    ' if the logon fails this demo application will exit
    If Not CheckLogon(Session.Logon(TerminalID, "PumpDemo")) Then
        End
    End If
            
    Caption = "POS Demo - " + CStr(TerminalID) + " - " + Session.Version

    Attendant.Session = Session

    ' now that we have logged on lets load up the pump objects
    ' note that .NumberOfPumps is actaully the highest logical
    ' pump number and as such, if the logical numbers are not in
    ' sequence it will be greater than the actual number of pumps
    ' installed
        
    LoadAllPumps
    
    Session.RunningTotalOn = True
    ' the current pump updown
    CurrentPumpUpDown.Max = Session.NumberOfPumps
    
    EnableVersion3Features True
    
    'use initial Form width/height set with IDE as min size
    minWidth = Width
    minHeight = Height
    
    ' load saved settings
    LoadFormSettings
    
    ' intialise sale grid etc
    With SaleGrid
    
        .Row = 0
        .col = 0
        .CellAlignment = flexAlignLeftCenter
        .col = 1
        .CellAlignment = flexAlignRightCenter
        .col = 2
        .CellAlignment = flexAlignRightCenter
        .col = 3
        .CellAlignment = flexAlignRightCenter
        
        .ColWidth(0) = 1500
        .ColWidth(1) = 1000
        .ColWidth(2) = 1000
        .ColWidth(3) = .Width - 3605
        .TextMatrix(0, 0) = "Description"
        .TextMatrix(0, 1) = "Price"
        .TextMatrix(0, 2) = "Quantity"
        .TextMatrix(0, 3) = "Total"
    End With
    
    If Session.NumberOfPumps > 1 Then
        Session.SelectedPump = 1
    End If
    
    Subtotal.Text = Format(0, "currency")
        
    ShowPumpStatus 0, 0
    
    ClearMessage
    
    'V3 has P as in "Pump server" as first character of version
    'V4 just has version number
    Version4 = Left(Trim(Session.Version), 1) <> "P"
    
    'DelayForClearPumps must be based on Number of pumps: 50ms per pump?
    If ClearPumpsFlag = True Then
        DelayForClearPumps.Interval = 50 * Session.NumberOfPumps
        DelayForClearPumps.Enabled = True
    End If

    Exit Sub
       
login_error:
    ' try next password
    SQLPasswordID = SQLPasswordID + 1
    Resume login
    
End Sub

'EP-3493
Private Sub ClearPumps()
    Dim i As Integer
    Dim del As Delivery
    
    If ClearPumpsFlag = False Then
        Exit Sub
    End If
    
    ' By default, don't fire timer anymore
    DelayForClearPumps.Enabled = False
    For i = 1 To Session.NumberOfPumps
        With Pump(i)
            If .ReservedBy = TerminalID Then ' Reserved by the same Terminal?
                ' Reserve found for same terminal?  Enable timer again!
                ' Postprocessing maybe required for Clearing deliveries, etc.
                DelayForClearPumps.Enabled = True
                If .ReservedState = PREPAY_AUTHORISED Or _
                    .ReservedState = PREAUTH_AUTHORISED Then   ' Authorised by same Terminal?
                    .TempStop
                    ' do the refund if there is one
                ElseIf .ReservedState = PREPAY_DELIVERED Or _
                    .ReservedState = PREAUTH_DELIVERED Then  ' might be a refund here
                        Set del = .CurrentDelivery
                        If Not del Is Nothing Then
                            If .ReservedState = PREPAY_DELIVERED Then
                                del.GetLock Session.TerminalID
                                del.Clear Session.TerminalID
                            ElseIf .ReservedState = PREAUTH_DELIVERED Then
                                del.ClearPreauth TerminalID
                            End If
                        End If
                End If
            End If
        End With
    Next i
    
End Sub

Private Sub UnLoadAllPumps()
    Dim Number As Integer
    Dim i As Integer

    On Error Resume Next
    
    For i = 2 To 100
        Number = Pump(i).Number
        If Err.Number = 0 Then
            Unload Pump(i)
        End If
    Next i
    
End Sub

Private Sub LoadAllPumps()
    Dim Number As Integer
    Dim i As Integer
    Dim del As Delivery

    ' Make sure no pumps are loaded, number of pumps may have changed since last logon
    UnLoadAllPumps

    On Error Resume Next
    
    For i = 1 To Session.NumberOfPumps
        
        ' See if Pump is already loaded, 1 is always loaded as its part of control array
        Number = Pump(i).Number
        If Err.Number <> 0 Then
            Load Pump(i)
        End If
        
       
        ' there are several attributes that can only be assigned
        ' at run time, and must be assigned before the pump object
        ' will function correctly
        
        With Pump(i)
            ' the pump object must be connected to the session object
            .Session = Session
            
            ' and the logical number of pump must be assigned
            ' once both of these attributes have been assigned
            ' the pump object is connected with the pump server
            .Number = i
           
            ' if the number stayed zero it is because there
            ' is no pump with this logical number installed on the server
            If .Number = i Then
                            
                ' do you want the pump stack popup to come up when the
                ' control is clicked by the user ?
                .PopupEnabled = True
                .TouchScreen = True
                .BeepEnabled = True
                .QuickAuthorise = True
                .QuickSaleSelect = True
                
                ' do you want the large icons with running totals etc or the small simple ones
                '.LargeIcon = True
                
                ' if you are integrating the enabler system into an
                ' existing pos system, which already has a user interface
                ' then leave the Visible property false, and
                ' the control becomes an API to the server only
                .Visible = True
            Else
                .Visible = False
            End If
        End With
        
        ' if we previously crashed while doing a preauth delivery
        ' and the delivery is waiting there for us then we had better
        ' clear it as nobody else can
        ' Normally a POS does not do preauth deliveries just OPTs ( Outdoor Payment Terminals )
        
        Set del = Pump(i).CurrentDelivery
        If Not del Is Nothing Then
            If del.LockedBy = Session.TerminalID And _
               del.Type = AVAILABLE_PREAUTH_DELIVERY Then
               del.ClearPreauth Session.TerminalID
            End If
        End If
        
        ' Release delivery object ASAP
        Set del = Nothing
 
    Next i
    
    ' ChangeIconStyle either updates the .IconStyle property or .LargeIcon depending on
    ' which version of the ActiveX control you are using, and also relocates them depending
    ' on their size
    ChangeIconStyle

End Sub
'******************************************************************
'*
'* Form_Resize
'*    Most Enabler client applications use a fixed dialog size and layout,
'*    we have included this simple example of icon layout if you need it
'*
'******************************************************************
Private Sub Form_Resize()

Dim ControlTop As Integer
Dim i As Integer
Dim IconWidth As Integer
Dim IconHeight As Integer

    ' don't do anything if the window is minimised
    If MainForm.WindowState = vbMinimized Then
        Exit Sub
    End If
    
    ' if the form is maximised we're not allowed to change it's size
    If MainForm.WindowState <> vbMaximized Then
        ' first make sure the window is not too small
        If Width < minWidth Then
            Width = minWidth 'initial width set with IDE
        End If
        
        If Height < minHeight Then
            Height = minHeight 'initial height set with IDE
        End If
    End If
    
    ' anchor the buttons to the bottom edge
    ' first row
    ControlTop = ScaleHeight - PumpControlFrame.Height - PumpStatusBar.Height - 100
    PumpControlFrame.Top = ControlTop
    DeliveryFrame.Top = ControlTop
    ProductsFrame.Top = ControlTop
    PaymentFrame.Top = ControlTop
    PaymentFrame.Left = ScaleWidth - PaymentFrame.Width - 100
    ClearFrame.Left = PaymentFrame.Left - ClearFrame.Width - 100
    ClearFrame.Top = ControlTop
        
    MiscFrame.Top = ControlTop - MiscFrame.Height - 100
    MiscFrame.Left = ScaleWidth - SaleGrid.Width - 100
    
    ' anchor the sale window to the right and bottom edges
    SaleWindowLabel.Left = MiscFrame.Left
    SaleGrid.Left = MiscFrame.Left
    SaleGrid.Height = MiscFrame.Top - SaleGrid.Top - 100
        
    ' now rearrange the pump icons to use the space available
    IconHeight = 0
    For i = 1 To Session.NumberOfPumps
        If Not Pump(i) Is Nothing Then
            If IconHeight = 0 Then
                IconHeight = Pump(i).Height
                IconWidth = Pump(i).Width
            End If
        End If
    Next
    
    If IconHeight = 0 Then
        Exit Sub
    End If
    
    ArrangePumpIcons IconWidth, IconHeight
    
End Sub

'******************************************************************
'*
'*  Unload form event - called when this form is closing.
'*
'******************************************************************
Private Sub Form_Unload(Cancel As Integer)

    ' close other forms we might have opened.
    Unload TankDlg
    Unload TraceForm
    
    ' save menu options
    SaveFormSettings

End Sub


'******************************************************************
'*
'*  SaveFormSettings - uses VB Interaction object to write to registry.
'*
'******************************************************************
Sub SaveFormSettings()
    ' [HKEY_CURRENT_USER\Software\VB and VBA Program Settings\PumpDemo\]
    
    'Icon Styles Menu
    '-----------------------------
    
    ' Icon Size (1 of X options)
    Dim i
    For i = 0 To mnSetIconStyle.Count - 1
        If mnSetIconStyle(i).Checked Then Exit For 'stop
    Next i
    SaveSetting AppName, "Display", "IconStyle", i
    
    ' Flat style
    SaveSetting AppName, "Display", "FlatStyle", mnPumpIcon_FlatStyle.Checked
    ' Background Color
    SaveSetting AppName, "Display", "UseBackgroundColor", mnPumpIcon_UseBackgroundColors.Checked
    ' New Icons
    SaveSetting AppName, "Display", "UseNewIcons", mnPumpIcon_UseNewIcons.Checked
    
    ' Monitor Total
    SaveSetting AppName, "Display", "MonitorTotal", mnMonitorTotal.Checked
    ' Monitor Volume
    SaveSetting AppName, "Display", "MonitorVol", mnMonitorVol.Checked
    
    ' Icons Visible - not implemented because visibility is handled by LoadAllPumps
    'SaveSetting AppName, "Display", "IconsVisible", mnPumpVisible.Checked
    
    
    'Options Menu
    '-----------------------------
    
    'Popup Enabled
    SaveSetting AppName, "Options", "PopupEnabled", mnPopupEnabled.Checked
    'Modal Popup
    SaveSetting AppName, "Options", "ModalPopup", mnModalPopup.Checked

    'Touch Screen
    SaveSetting AppName, "Options", "TouchScreen", mnTouchScreen.Checked
    'Quick Select
    SaveSetting AppName, "Options", "QuickSelect", mnQuickSelect.Checked
    'Quick Auth
    SaveSetting AppName, "Options", "QuickAuth", mnQuickAuth.Checked
    'User Input Enabled
    SaveSetting AppName, "Options", "UserInputEnabled", mnUserInputEnabled.Checked
    
    'Pump Lights - not implemented as controlled manually
    'SaveSetting AppName, "Display", "PopupEnabled", mnPumpLights.Checked
    
    'Clear Completed Preauths
    SaveSetting AppName, "Options", "ClearCompletedPreauths", mnClearCompletedPreauths.Checked
        
        
    'Messages Menu
    '-----------------------------
    
    'Display Server Errors
    SaveSetting AppName, "Messages", "ServerErrors", mnDispServerErrors.Checked
    'Display Server Messages
    SaveSetting AppName, "Messages", "ServerMessages", mnDisplayServerMessages.Checked
    'Prepay Complete Messages
    SaveSetting AppName, "Messages", "PrepayCompleteMessages", mnPrepayCompleted.Checked
     
    
    'Window location - not used, but code left here for reference
    '-----------------------------
    '
    'If MainForm.WindowState <> vbMinimized Then
    '    SaveSetting AppName, "Window", "Left", Left
    '    SaveSetting AppName, "Window", "Width", Width
    '    SaveSetting AppName, "Window", "Top", Top
    '    SaveSetting AppName, "Window", "Height", Height
    'End If
    '

End Sub

'******************************************************************
'*
'*  LoadFormSettings - uses GetSettingSafely module to read from registry.
'*
'*  The GetSetting functions take a 'default' value which is used if the registry value cannot be read.
'*  We pass the initial menu item value (set in the IDE) as the default to give expected behaviour.
'*
'******************************************************************
Sub LoadFormSettings()
    ' [HKEY_CURRENT_USER\Software\VB and VBA Program Settings\PumpDemo\]
    
    
    'Icon Styles Menu
    '-----------------------------
    
    ' Icon Size (1 of X options)
    Dim s, i, d
    For i = 0 To 3
        If mnSetIconStyle(i).Checked = True Then d = i 'initial item selected set in IDE
        mnSetIconStyle(i).Checked = False
    Next i
    If IsEmpty(d) Then d = 1 'in case no item set with IDE
    s = GetSettingInteger(AppName, "Display", "IconStyle", d) 'pass default
    If s < 0 Or s > mnSetIconStyle.Count - 1 Then s = 1 'min/max range check
    mnSetIconStyle(s).Checked = True
    
    ' Flat Style
    mnPumpIcon_FlatStyle.Checked = GetSettingBoolean(AppName, "Display", "FlatStyle", mnPumpIcon_FlatStyle.Checked)
    ' Background Color
    mnPumpIcon_UseBackgroundColors.Checked = GetSettingBoolean(AppName, "Display", "UseBackgroundColor", mnPumpIcon_UseBackgroundColors.Checked)
    ' New Icons
    mnPumpIcon_UseNewIcons.Checked = GetSettingBoolean(AppName, "Display", "UseNewIcons", mnPumpIcon_UseNewIcons.Checked)
    
    ' Monitor Total
    mnMonitorTotal.Checked = GetSettingBoolean(AppName, "Display", "MonitorTotal", mnMonitorTotal.Checked)
    ' New Icons
    mnMonitorVol.Checked = GetSettingBoolean(AppName, "Display", "MonitorVol", mnMonitorVol.Checked)
    
    ' Visible - not implemented because visibility is handled by LoadAllPumps
    'mnPumpVisible.Checked = GetSettingBoolean(AppName, "Display", "IconsVisible", mnPumpVisible.Checked)
    'For i = 1 To Session.NumberOfPumps
    '    If Not Pump(i) Is Nothing Then
    '       Pump(i).Visible = False 'mnPumpVisible.Checked
    '    End If
    'Next i
    
    ChangeIconStyle 'apply settings
    
    
    'Options Menu
    '-----------------------------
    
    'Popup Enabled
    mnPopupEnabled.Checked = GetSettingBoolean(AppName, "Options", "PopupEnabled", mnPopupEnabled.Checked)
    'Modal Popup
    mnModalPopup.Checked = GetSettingBoolean(AppName, "Options", "ModalPopup", mnModalPopup.Checked)

    'Touch Screen
    mnTouchScreen.Checked = GetSettingBoolean(AppName, "Options", "TouchScreen", mnTouchScreen.Checked)
    'Quick Select
    mnQuickSelect.Checked = GetSettingBoolean(AppName, "Options", "QuickSelect", mnQuickSelect.Checked)
    'Quick Auth
    mnQuickAuth.Checked = GetSettingBoolean(AppName, "Options", "QuickAuth", mnQuickAuth.Checked)
    'User Input Enabled
    mnUserInputEnabled.Checked = GetSettingBoolean(AppName, "Options", "UserInputEnabled", mnUserInputEnabled.Checked)
    Session.UserInputEnabled = mnUserInputEnabled.Checked

    'Pump Lights - not implemented as controled manually
    'mnPumpLights.Checked = GetSettingBoolean(AppName, "Options", "PumpLights", mnPumpLights.Checked)
    'Session.PumpLights = mnPumpLights.Checked
    
    'Clear Completed Preauths
    mnClearCompletedPreauths.Checked = GetSettingBoolean(AppName, "Options", "ClearCompletedPreAuths", mnClearCompletedPreauths.Checked)
    
    'Apply settings to pump objects
    For i = 1 To Session.NumberOfPumps
        If Not Pump(i) Is Nothing Then
            Pump(i).PopupEnabled = mnPopupEnabled.Checked
            Pump(i).ModalPopup = mnModalPopup.Checked
            Pump(i).TouchScreen = mnTouchScreen.Checked
            Pump(i).QuickSaleSelect = mnQuickSelect.Checked
            Pump(i).QuickAuthorise = mnQuickAuth.Checked
        End If
    Next i
    
        
    'Messages Menu
    '-----------------------------
    
    'Display Server Errors
    mnDispServerErrors.Checked = GetSettingBoolean(AppName, "Messages", "ServerErrors", mnDispServerErrors.Checked)
    'Display Server Messages
    mnDisplayServerMessages.Checked = GetSettingBoolean(AppName, "Messages", "ServerMessages", mnDisplayServerMessages.Checked)
    'Prepay Complete Messages
    mnPrepayCompleted.Checked = GetSettingBoolean(AppName, "Messages", "PrepayCompleteMessages", mnPrepayCompleted.Checked)
        
        
    'Window location - not used, but code left here for reference
    '-----------------------------
    '
    '' centered coordinates
    'Dim x, y, newLeft, newTop, newHeight, newWidth
    'x = (Screen.Width - Width) \ 2
    'y = (Screen.Height - Height) \ 2
    '
    '' get saved values
    'newLeft = GetSettingInteger(AppName, "Window", "Left", x)
    'newTop = GetSettingInteger(AppName, "Window", "Top", y)
    'newWidth = GetSettingInteger(AppName, "Window", "Width", Width)
    'newHeight = GetSettingInteger(AppName, "Window", "Height", Height)
    '
    '' no smaller than original window size
    'If newWidth < Width Then newWidth = Width
    'If newHeight < Height Then newHeight = Height
    '
    '' don't extend past edges of screen
    'If newTop < 0 Then newTop = 0
    'If newLeft < 0 Then newLeft = 0
    'If newTop + Height > Screen.Height Then newTop = Screen.Height - newHeight
    'If newLeft + Width > Screen.Width Then newLeft = Screen.Width - newWidth
    '
    'Move newLeft, newTop, newWidth, newHeight
    '
        
End Sub

'******************************************************************
'*
'*  PreAuth_Click - click event for PreAuth button, launches the
'*                  preauth dialog, note this dialog is provided as
'*                  an example of how to do a preauth delivery, it is
'*                  not intended to be part of a typical POS application
'*
'******************************************************************
Private Sub PreAuth_Click()


    If Session.SelectedPump < 1 Then
        MsgBox "Please select a pump first.", vbExclamation
        Exit Sub
    End If
        
    PreauthDlg.PumpNumber = Session.SelectedPump
    PreauthDlg.Show vbModal
    
End Sub

'******************************************************************
'*
'*  Prepay_Click - click event for Prepay button, launches the
'*                 prepay dialog
'*
'******************************************************************
Private Sub Prepay_Click()

    Dim result As Integer
    
    ' if no pump is currently selected then cannot do prepay
    ' delivery
    If Session.SelectedPump < 1 Then
        MsgBox "Please select a pump first.", vbExclamation
        Exit Sub
    End If
    
    ' attempt to reserve this pump for a prepay delivery
    result = Pump(Session.SelectedPump).ReserveForPrepay
    
    ' check result, if not Okay then display error string
    ' as retrieved from session object
    If result <> OK_RESULT Then
        MsgBox MainForm.Session.ResultString(result), vbExclamation
        Exit Sub
    End If
    
    ' start the prepay dialog saving the number of the pump first
    PrepayDlg.PumpNumber = Session.SelectedPump
    PrepayDlg.Show vbModal
    
End Sub

'******************************************************************
'*
'*  Pump_CurrentDeliveryEvent
'*      CurrentDeliveryEvent event for pump control array, this
'*      event is fired whenever the state of the current delivery
'*      changes.
'*
'******************************************************************
Private Sub Pump_CurrentDeliveryEvent(Index As Integer, ByVal Number As Integer, ByVal hasCurrentDelivery As Boolean)

Dim rby As Integer
Dim rs As Integer
Dim cdel As Delivery
Dim chose As Hose

    ' Get a reference to delivery
    Set cdel = Pump(Number).CurrentDelivery

    If cdel Is Nothing Then
        TraceForm.TracePump Number, "CurrentDelivery: none"
    Else
        TraceForm.TraceDelivery Number, cdel, "CurrentDelivery:"
        Set chose = cdel.Hose
        If chose Is Nothing Then
            TraceForm.TracePump Number, "CurrentDelivery: hose not set"
        Else
            TraceForm.TracePump Number, "Hose " + Format(chose.Number) + " totals, Money:" + Format(chose.MoneyTotal, "currency") + " Volume:" + Format(chose.VolumeTotal, "fixed")
        End If
    End If
    
    ' if a preauth delivery has just been completed that was started by
    ' this terminal then lets finalise the preauth transaction
    rby = Pump(Number).ReservedBy
    rs = Pump(Number).ReservedState
    
    If hasCurrentDelivery And _
       Pump(Number).ReservedBy = Session.TerminalID And _
       Pump(Number).ReservedState = PREAUTH_DELIVERED And _
       Number = PreauthDlg.PumpNumber Then
       PreauthDlg.PreauthDeliveryComplete
    End If
    
    ShowPumpStatus Index, pCurrentDelivery
    
End Sub

'******************************************************************
'*
'*  Pump_DeliveryItemSelected
'*      DeliveryItemSelected event for pump control array, this
'*      event is fired, when the user selects a delivery from the
'*      popup dialog.
'*
'******************************************************************
Private Sub Pump_DeliveryItemSelected(Index As Integer, ByVal Number As Integer, ByVal ItemIndex As Integer)

Dim del As Delivery
Dim result As Integer
Dim grade As String
Dim Price As Currency
Dim Value As Currency
Dim Volume As Currency
Dim DelType As Integer

    With Pump(Number)
    
        ' get delivery from the delivery stack
        Set del = .DeliveryStack(ItemIndex)
        
        ' just to be safe, lets ensure that this delivery does infact exist
        If Not del Is Nothing Then
            
            ' check if we have it locked already, can happen if pupdemo restarted in middle of
            ' operation like preauth
            If del.LockedBy = Session.TerminalID Then
                If FindDelivery(del.ID) Then
                    MsgBox "This delivery is already in the sale window.", vbExclamation
                    Exit Sub
                End If
                TraceForm.TracePump Number, "Delivery " + Str(del.ID) + " Already locked by " + Str(Session.TerminalID)
                result = OK_RESULT
            Else
                ' not locked or locked by someone else
                ' attempt to lock the delivery
                TraceForm.TracePump Number, "Delivery " + Str(del.ID) + " Locked Request"
                result = del.GetLock(Session.TerminalID)
                TraceForm.TracePump Number, "Delivery " + Str(del.ID) + " Locked Response (" + Str(result) + ")"
            End If
            
            ' check result, if Okay then delivery was locked and can proceed
            If result = OK_RESULT Or _
            (result = DELIVERY_ALREADY_LOCKED_RESULT And del.LockedBy = TerminalID) Then
            
                ' get summary details about the delivery
                ' note that there is individual properties for all of these
                ' parameters, however in a DCOM environment getting all with
                ' one method is much faster
                del.GetSummary grade, Volume, Price, Value, DelType
                
                ' add item to sale grid
                If AddSaleItem(DeliveryItem, Format(Number, "00 - ") & grade, Price, Volume, Value) Then
                
                    ' save handle to delivery item in sale store
                    ' otherwise gets released when Del goes out of scope
                    Set Sale.Items(Sale.NumberOfItems - 1).del = del
                    
                    TraceForm.TraceDelivery Number, del, "Selected delivery:"
                Else
                
                    ' if sale grid filled or for any other reason we did
                    ' not succeed best unlock the delivery
                    del.ReleaseLock (Session.TerminalID)
                End If
            Else
            
                ' if lock did not work display error string
                ' as retrieved from session object
                MsgBox Session.ResultString(result), vbExclamation
            End If
        End If
       
    End With
    
End Sub

'******************************************************************
'*
'*  Pump_RunningTotalEvent - RunningTotalEvent event for pump
'*      control array, this event is fired, when the running total
'*      flag or running total changes
'*
'******************************************************************
Private Sub Pump_RunningTotalEvent(Index As Integer, ByVal Number As Integer, ByVal newTotal As Currency)

    ShowPumpStatus Index, pCurrentDelivery
    
End Sub

'******************************************************************
'*
'* Pump_StateChangeEvent - event for for pump state change, is also
'*      fired on pump reserved state change.  Client applications
'*      must include code to caiter for this when prepay or preauth
'*      functionality is used
'*
'******************************************************************
Private Sub Pump_StateChangeEvent(Index As Integer, ByVal Number As Integer, ByVal NewState As Integer)

Dim ReservedState As Integer
Dim P As EnbPumpX2
Dim rs As RestartState

    Set P = Pump(Number)
    ReservedState = P.ReservedState
    
    TraceForm.TracePump Number, _
                     "State " _
                     & Format(NewState, "00") _
                     & " '" _
                     & P.StateString _
                     & "' CurrentHose=" _
                     & P.CurrentHose _
                     & " ReservedState=" _
                     & Format(P.ReservedState, "0") _
                     & "(T=" _
                     & Format(P.ReservedBy, "0") _
                     & ")"

    ' check if restarting a preauth as client may have crashed or was ended
    If PreauthDlg.PumpNumber = -1 Or PreauthDlg.PumpNumber = 0 Then
        rs = PreauthDlg.GetPreauthState(Number)
        If rs <> rsNone And _
            DelayForClearPumps.Enabled = False Then 'Don't show dialog if DelayForClearPumpsFlag is set
            PreauthDlg.PumpNumber = Number
            PreauthDlg.Show vbModal
        End If
    End If

    ' if this pump is being controlled by preauth dialog
    ' then pass events on to that dialog
    If PreauthDlg.PumpNumber = Number Then
        If NewState = DELIVERING_PREAUTH_PSTATE Then
            PreauthDlg.DeliveryStarted
        ElseIf ReservedState <> RESERVED_FOR_PREAUTH And _
            ReservedState <> PREAUTH_AUTHORISED And _
            ReservedState <> PREAUTH_DELIVERING And _
            ReservedState <> PREAUTH_DELIVERED Then
            
            ' for some reason the reserve state has been cleared by the pump server,
            ' so we cannot continue
            PreauthDlg.PreauthDeliveryCancel
        End If
    End If

    If PrepayDlg.PumpNumber = Number Then
        If ReservedState <> RESERVED_FOR_PREPAY _
        And ReservedState <> PREPAY_AUTHORISED _
        And ReservedState <> PREPAY_DELIVERING _
        And ReservedState <> PREPAY_DELIVERED Then
        
            ' for some reason the reserve state has been cleared by the pump server,
            ' so we cannot continue
            PrepayDlg.PrepayDeliveryCancel
            
        End If
    End If
    
    ShowPumpStatus Index, pPumpState
   
End Sub

'******************************************************************
'*
'*  Session_ClientNotification
'*    This event is fired when another client application calls the
'*    EnbSessionX.NotifyClients() method.  This function can be used
'*    by client applications to co-ordinate activities, or notify
'*    each other of custom events. You can pass any value as a
'*    NotificationID - there are no reserved values
'*
'******************************************************************
Private Sub Session_ClientNotification(ByVal NotificationID As Long)
    SetMessage "ClientNotification: Its a " & CStr(NotificationID)
End Sub

'******************************************************************
'*
'*  Session_PumpSelectedEvent - PumpSelectedEvent for the session object
'*      is fired when the user selectes a different pump
'*
'******************************************************************
Private Sub Session_PumpSelectedEvent(ByVal PumpNumber As Integer)
    
    ' we just use it for updating the monitor total check box and
    ' displaying the currently selected pump
    CurrentPumpUpDown.Value = PumpNumber
    ShowPumpStatus PumpNumber, 0
    
    mnPumpLights.Checked = Pump(PumpNumber).PumpLightsOn
    
End Sub


'******************************************************************
'*
'*  Session_ServerMessage - ServerMessage event for the session object
'*      is fired when pump server sends a message to clients, for example
'*      a tank alarm is activated.  Depending on the type of application
'*      you are building, it may be better to log the message than to
'*      display a message box.
'*
'******************************************************************
Private Sub Session_ServerMessage(ByVal EventType As Integer, ByVal EventLevel As Integer, ByVal DeviceType As Integer, ByVal DeviceID As Long, ByVal DeviceNumber As Long, ByVal Text As String)

Dim DeviceName As String
Dim MsgType As Integer

    If Not mnDisplayServerMessages.Checked Then
        Exit Sub
    End If

    If DeviceType = 1 Then
        DeviceName = "Pump " + CStr(DeviceNumber)
    ElseIf DeviceType = 8 Then
        DeviceName = "Price sign " + CStr(DeviceNumber)
    ElseIf DeviceType = 9 Then
        If DeviceNumber = 0 Then
            DeviceName = "Tank gauge "
        Else
            DeviceName = "Tank " + CStr(DeviceNumber)
        End If
    End If
    
    MsgType = vbInformation
    If EventLevel = 2 Then
        MsgType = vbExclamation
    ElseIf EventLevel = 3 Then
        MsgType = vbCritical
    End If
    
    SetMessage DeviceName + " " + Text
    
End Sub

'******************************************************************
'*
'*  Session_ServerError - ServerError event for the session object
'*      is fired when session object detects a problem with the
'*      pump server, shutting the pump server service down is one way
'*      of demonstrating this.
'*
'******************************************************************
Private Sub Session_ServerError(ByVal ErrorCode As Integer)
    
    ' when pump server is shutdown, all clients get a 'forced logoff' server errorcode
    If ErrorCode = PSRVR_FORCED_LOGOFF_RESULT Then
        ' Remove all items from sale window
        Clear_Click
    End If
    
    If ErrorCode = PSRVR_RECONNECTED_RESULT Then
       CheckForPendingPrepay
    End If
    
    If Not mnDispServerErrors.Checked Then
        Exit Sub
    End If

    SetMessage Session.ResultString(ErrorCode)
    
End Sub

'******************************************************************
'*
'*  CheckForPendingPrepay
'*      Here we check if we are in the process of handling a prepay
'*      when pump server disconnected and reconnected.
'*      If any pumps are reserved for prepay by this terminal then redisplay the
'*      prepay dialog
'*
'******************************************************************

Private Sub CheckForPendingPrepay()
    Dim i As Integer
    
    On Error Resume Next
    
    For i = 1 To Session.NumberOfPumps
        With Pump(i)
            If Err.Number = 0 Then
                If .ReservedState = RESERVED_FOR_PREPAY Then
                    If .ReservedBy = TerminalID Then
                        
                        ' Select the pump
                        Session.SelectedPump = i
                            
                        ' start the prepay dialog saving the number of the pump first
                        PrepayDlg.PumpNumber = i
                        PrepayDlg.Show vbModal

                        Exit Sub
                    End If
                End If
            End If
        End With
    Next i

End Sub

'******************************************************************
'*
'*  Stack_Click - click event for Stack button, attempts to stack the
'*       current delivery for the currently selected pump
'*
'******************************************************************
Private Sub Stack_Click()

Dim result As Integer
    
    ' is there a current pump selected
    If Session.SelectedPump >= 1 Then
        
        ' if so attempt to stack the current delivery
        result = Pump(Session.SelectedPump).PushCurrentDelivery
        
        ' check result, if not Okay then display error string
        ' as retrieved from session object
        If result <> OK_RESULT Then
            MsgBox Session.ResultString(result), vbExclamation
        End If
    End If
End Sub

'******************************************************************
'*
'*  TakeDel_Click - click event for TakeDel button, attempts to take
'*      take the current delivery into a sale
'*
'******************************************************************
Private Sub TakeDel_Click()

Dim del As Delivery
Dim result As Integer
Dim grade As String
Dim Price As Currency
Dim Value As Currency
Dim Volume As Currency
Dim DelType As Integer

    ' is there a pump currently selected
    If Session.SelectedPump < 1 Then
        Exit Sub
    End If
    
    With Pump(Session.SelectedPump)
    
        Set del = .CurrentDelivery
        
        ' is there a current sale ?
        If Not del Is Nothing Then
            
            If FindDelivery(del.ID) Then
                MsgBox "This delivery is already in the sale window.", vbExclamation
            Else
                ' if so can I lock it
                result = del.GetLock(Session.TerminalID)
                
                ' check result, if the lock worked then lets put it
                ' into the current sale
                If result = OK_RESULT Then
                
                    ' get the delivery details
                    del.GetSummary grade, Volume, Price, Value, DelType
                    
                    ' add to the sale
                    If AddSaleItem(DeliveryItem, Format(.Number, "00 - ") & grade, Price, Volume, Value) Then
                        Set Sale.Items(Sale.NumberOfItems - 1).del = del
                        
                        TraceForm.TracePump .Number, _
                            "Delivery " & _
                            " Price " + Format(Price) & _
                            " Value " + Format(Value, "currency") & _
                            " Volume " + Format(Volume, "fixed") & _
                            " ValueTotal " + Format(del.ValueTotal, "currency") & _
                            " VolumeTotal " + Format(del.VolumeTotal, "fixed")
                    Else
                        ' if add to sale failed then unlock delivery
                        del.ReleaseLock (Session.TerminalID)
                    End If
                Else
                    MsgBox Session.ResultString(result), vbExclamation
                End If
            End If
        Else
            MsgBox "There is no current delivery.", vbExclamation
        End If
       
    End With
  
End Sub

'******************************************************************
'*
'*  TempStop_Click - click event for TempStop button, attempts to
'*      temp stop the current pump.
'*
'******************************************************************
Private Sub TempStop_Click()

Dim result As Integer

    ' is there a selected pump
    If Session.SelectedPump >= 1 Then
        result = Pump(Session.SelectedPump).TempStop
        
        ' check result, if not Okay then display error string
        ' as retrieved from session object
        If result <> OK_RESULT Then
            MsgBox Session.ResultString(result), vbExclamation
        End If
    End If
End Sub

Private Sub mnTouchScreen_Click()

Dim i As Integer
    
    mnTouchScreen.Checked = Not mnTouchScreen.Checked
    For i = 1 To Session.NumberOfPumps
        If Not Pump(i) Is Nothing Then
            Pump(i).TouchScreen = mnTouchScreen.Checked
        End If
    Next i
End Sub

'******************************************************************
'*
'*  CurrentPumpUpDown_Change - Change event for updown that selects a pump.
'*
'******************************************************************
Private Sub CurrentPumpUpDown_Change()
        Session.SelectedPump = CurrentPumpUpDown.Value
End Sub

'******************************************************************
'*
'* To allow this application to operate with both Enabler V2.5 and V3.0
'* ActiveX controls, we enable and disable some functions depending on
'* the Pump Server version
'*
'******************************************************************
Private Sub EnableVersion3Features(Enable As Boolean)

    mnUserInputEnabled.Enabled = Enable
    ' The first two options in the icon style menu now work on Enabler v2.5
    ' by using the older EnbPumpX.LargeIcon property instead of .IconStyle
    'mnSetIconStyle(1).Enabled = Enable
    'mnSetIconStyle(2).Enabled = Enable
    mnSetIconStyle(3).Enabled = Enable
    mnPumpIcon_UseBackgroundColors.Enabled = Enable
    
End Sub

'******************************************************************
'*
'* This code has been added to show how a POS can undo Delivery.Reinstate.
'* For example in situations where the wrong delivery was reinstated
'*
'* This functionality was first introduced in Enabler v3.40.3, and
'* the code below shows how you can detect pump server versions that do
'* not support this operation
'*
'******************************************************************
Private Sub UndoReinstateButton_Click()

Dim result As Integer
Dim i As Integer

    ' search all the sale items for reinstated deliveries
    For i = 0 To Sale.NumberOfItems - 1
        With Sale.Items(i)
            ' if the .del member is currently assigned then
            ' release the delivery lock and unassign the handle
            If Not .del Is Nothing Then
                If .del.Type = REINSTATED_DELIVERY Then
                    .del.Clear (-Session.TerminalID)
                
                    If result = BAD_TERMINAL_NUMBER_RESULT Then
                        MsgBox "This Pump Server does not allow delivery reinstate to be undone", vbOKOnly + vbExclamation
                        Exit Sub
                    End If
                    
                    ' check result, if not Okay then display error string
                    ' as retrieved from session object
                    If result <> OK_RESULT Then
                        MsgBox Session.ResultString(result), vbExclamation
                    End If
                
                    ' this release the delivery object
                    Set .del = Nothing
                End If
            End If
        End With
    Next i

    ' reset all other sale variables to signify an empty sale
    With Sale
        .NumberOfItems = 0
        .State = SaleOpen
        .Subtotal = 0
    End With
    
    SaleGrid.Rows = 1
    SaleGrid.FocusRect = flexFocusLight
    SaleGrid.col = 0
    SaleGrid.ColSel = 0
    
    SaleState.Caption = "Subtotal"
    Subtotal.Text = Format(0, "currency")

End Sub
