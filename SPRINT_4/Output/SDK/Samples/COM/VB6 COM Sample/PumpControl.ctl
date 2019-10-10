VERSION 5.00
Begin VB.UserControl PumpControl 
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   2775
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   1680
   ScaleHeight     =   2775
   ScaleWidth      =   1680
   Begin VB.Label Label_pumpstate 
      Caption         =   "Not Installed"
      Height          =   375
      Left            =   120
      TabIndex        =   5
      Top             =   2160
      Width           =   1455
   End
   Begin VB.Label Label_hose 
      Caption         =   "Replaced"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   1800
      Width           =   1455
   End
   Begin VB.Label Label_volume 
      Alignment       =   1  'Right Justify
      Caption         =   "0.000"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   120
      TabIndex        =   3
      Top             =   1320
      Width           =   1455
   End
   Begin VB.Label Label_value 
      Alignment       =   1  'Right Justify
      Caption         =   "0.00"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   120
      TabIndex        =   2
      Top             =   840
      Width           =   1455
   End
   Begin VB.Label Label_grade 
      Alignment       =   1  'Right Justify
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   120
      TabIndex        =   1
      Top             =   360
      Width           =   1455
   End
   Begin VB.Label Label_PumpNumber 
      Caption         =   "01"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   18
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   435
      Left            =   120
      TabIndex        =   0
      Top             =   0
      Width           =   540
   End
End
Attribute VB_Name = "PumpControl"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Private WithEvents myPump As Pump
Attribute myPump.VB_VarHelpID = -1



Private Sub myPump_OnFuellingProgress(ByVal Pump As ITL_Enabler_API.IPump, ByVal value As Currency, ByVal volume As Currency, ByVal volume2 As Currency)
    Label_grade.Caption = Pump.CurrentHose.Grade.name
    Label_value.Caption = FormatCurrency(value, 2)
    Label_volume.Caption = Format(volume, "L 0.000")
    
End Sub

Public Sub SetPump(ByVal Pump As Pump)
    Set myPump = Pump
    Label_PumpNumber.Caption = Format(Pump.number, "00")
    
    SetState
    
    If (myPump.CurrentHose Is Nothing) Then
        Label_hose.Caption = "Replaced"
    Else
        Label_hose.Caption = "Lifted"
    End If
    
End Sub


Private Sub myPump_OnHoseEvent2(ByVal Pump As ITL_Enabler_API.IPump, ByVal eventType As ITL_Enabler_API.HoseEventType)

Select Case eventType
    Case HoseEventType_Lifted
        Label_hose.Caption = "Lifted"
    Case HoseEventType_Replaced
        Label_hose.Caption = "Replaced"
    Case HoseEventType_LeftOut
        Label_hose.Caption = "LeftOut"
End Select
   
End Sub

Private Sub SetState()
     Label_pumpstate.Caption = myPump.GetPumpStateString(myPump.state)
End Sub

Private Sub myPump_OnStatusChange(ByVal Pump As ITL_Enabler_API.IPump, ByVal eventType As ITL_Enabler_API.PumpStatusEventType)

Select Case eventType
    ' Display current Pump state
    Case PumpStatusEventType.PumpStatusEventType_State
        SetState

End Select

End Sub

