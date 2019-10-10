VERSION 5.00
Begin VB.Form DialogGrades 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Grades"
   ClientHeight    =   8775
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   11025
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   8775
   ScaleWidth      =   11025
   ShowInTaskbar   =   0   'False
   Begin VB.ComboBox Combo_Grades 
      Height          =   315
      Left            =   2280
      TabIndex        =   2
      Text            =   "Combo1"
      Top             =   240
      Width           =   3495
   End
   Begin VB.Frame Frame1 
      Caption         =   "Selected Grade"
      Height          =   7935
      Left            =   240
      TabIndex        =   1
      Top             =   720
      Width           =   10455
      Begin VB.ListBox List_events 
         Height          =   1620
         Left            =   240
         TabIndex        =   41
         Top             =   5880
         Width           =   9855
      End
      Begin VB.Frame Frame2 
         Caption         =   "Prices"
         Height          =   3495
         Left            =   5520
         TabIndex        =   33
         Top             =   2160
         Width           =   4575
         Begin VB.TextBox Text_Price 
            Height          =   285
            Left            =   2040
            TabIndex        =   40
            Top             =   1440
            Width           =   1215
         End
         Begin VB.ComboBox Combo_Blend 
            Height          =   315
            Left            =   2040
            TabIndex        =   37
            Top             =   960
            Width           =   1215
         End
         Begin VB.ComboBox Combo_PriceLevel 
            Height          =   315
            Left            =   2040
            TabIndex        =   35
            Top             =   480
            Width           =   1215
         End
         Begin VB.CommandButton Command_SetPrice 
            Caption         =   "Set Price"
            Height          =   375
            Left            =   2040
            TabIndex        =   34
            Top             =   2160
            Width           =   1215
         End
         Begin VB.Label Label18 
            Caption         =   "Price :"
            Height          =   375
            Left            =   840
            TabIndex        =   39
            Top             =   1440
            Width           =   975
         End
         Begin VB.Label Label17 
            Caption         =   "Blend :"
            Height          =   255
            Left            =   840
            TabIndex        =   38
            Top             =   960
            Width           =   975
         End
         Begin VB.Label Label16 
            Caption         =   "Price Level :"
            Height          =   255
            Left            =   840
            TabIndex        =   36
            Top             =   480
            Width           =   1335
         End
      End
      Begin VB.CommandButton Command_block 
         Caption         =   "Toggle Block"
         Height          =   375
         Left            =   3000
         TabIndex        =   32
         Top             =   4320
         Width           =   1815
      End
      Begin VB.TextBox Text_PriceSegment 
         Enabled         =   0   'False
         Height          =   375
         Left            =   7320
         TabIndex        =   30
         Text            =   "Text1"
         Top             =   1440
         Width           =   2775
      End
      Begin VB.TextBox Text_PriceProfileId 
         Enabled         =   0   'False
         Height          =   375
         Left            =   7320
         TabIndex        =   28
         Text            =   "Text1"
         Top             =   960
         Width           =   2775
      End
      Begin VB.TextBox Text_Unit 
         Enabled         =   0   'False
         Height          =   375
         Left            =   7320
         TabIndex        =   26
         Text            =   "Text1"
         Top             =   480
         Width           =   2775
      End
      Begin VB.TextBox Text_PriceLevelCount 
         Enabled         =   0   'False
         Height          =   375
         Left            =   2040
         TabIndex        =   25
         Text            =   "Text1"
         Top             =   4800
         Width           =   2775
      End
      Begin VB.TextBox Text_GradeType 
         Enabled         =   0   'False
         Height          =   375
         Left            =   2040
         TabIndex        =   23
         Text            =   "Text1"
         Top             =   5280
         Width           =   2775
      End
      Begin VB.CheckBox Check_IsBlocked 
         Enabled         =   0   'False
         Height          =   375
         Left            =   2040
         TabIndex        =   21
         Top             =   4320
         Width           =   2175
      End
      Begin VB.TextBox Text_Grade2 
         Enabled         =   0   'False
         Height          =   375
         Left            =   2040
         TabIndex        =   19
         Text            =   "Text1"
         Top             =   3840
         Width           =   2775
      End
      Begin VB.TextBox Text_Grade1 
         Enabled         =   0   'False
         Height          =   375
         Left            =   2040
         TabIndex        =   17
         Text            =   "Text1"
         Top             =   3360
         Width           =   2775
      End
      Begin VB.TextBox Text_DeliveryTimeout 
         Enabled         =   0   'False
         Height          =   375
         Left            =   2040
         TabIndex        =   15
         Text            =   "Text1"
         Top             =   2880
         Width           =   2775
      End
      Begin VB.TextBox Text_AllocationLimitType 
         Enabled         =   0   'False
         Height          =   375
         Left            =   2040
         TabIndex        =   13
         Text            =   "Text1"
         Top             =   1920
         Width           =   2775
      End
      Begin VB.TextBox Text_BlendRatio 
         Enabled         =   0   'False
         Height          =   375
         Left            =   2040
         TabIndex        =   11
         Text            =   "Text1"
         Top             =   2400
         Width           =   2775
      End
      Begin VB.TextBox Text_AllocationLimit 
         Enabled         =   0   'False
         Height          =   375
         Left            =   2040
         TabIndex        =   9
         Text            =   "Text1"
         Top             =   1440
         Width           =   2775
      End
      Begin VB.TextBox Text_Code 
         Enabled         =   0   'False
         Height          =   375
         Left            =   2040
         TabIndex        =   7
         Text            =   "Text1"
         Top             =   960
         Width           =   2775
      End
      Begin VB.TextBox Text_Name 
         Enabled         =   0   'False
         Height          =   375
         Left            =   2040
         TabIndex        =   5
         Text            =   "Text1"
         Top             =   480
         Width           =   2775
      End
      Begin VB.Label Label19 
         Caption         =   "Grade events :"
         Height          =   255
         Left            =   240
         TabIndex        =   42
         Top             =   6000
         Width           =   1455
      End
      Begin VB.Label Label15 
         Caption         =   "Price Segment :"
         Height          =   255
         Left            =   5520
         TabIndex        =   31
         Top             =   1440
         Width           =   1455
      End
      Begin VB.Label Label14 
         Caption         =   "Price Profile ID :"
         Height          =   255
         Left            =   5520
         TabIndex        =   29
         Top             =   960
         Width           =   1455
      End
      Begin VB.Label Label13 
         Caption         =   "Unit :"
         Height          =   255
         Left            =   5520
         TabIndex        =   27
         Top             =   480
         Width           =   1455
      End
      Begin VB.Label Label12 
         Caption         =   "Grade Type :"
         Height          =   255
         Left            =   240
         TabIndex        =   24
         Top             =   5280
         Width           =   1455
      End
      Begin VB.Label Label11 
         Caption         =   "Price Level Count :"
         Height          =   255
         Left            =   240
         TabIndex        =   22
         Top             =   4800
         Width           =   1455
      End
      Begin VB.Label Label10 
         Caption         =   "Is Blocked :"
         Height          =   255
         Left            =   240
         TabIndex        =   20
         Top             =   4320
         Width           =   1455
      End
      Begin VB.Label Label9 
         Caption         =   "Grade 2 for blend :"
         Height          =   255
         Left            =   240
         TabIndex        =   18
         Top             =   3840
         Width           =   1455
      End
      Begin VB.Label Label8 
         Caption         =   "Grade1 fro Blend :"
         Height          =   255
         Left            =   240
         TabIndex        =   16
         Top             =   3360
         Width           =   1455
      End
      Begin VB.Label Label7 
         Caption         =   "Delivery Timeout :"
         Height          =   255
         Left            =   240
         TabIndex        =   14
         Top             =   2880
         Width           =   1455
      End
      Begin VB.Label Label6 
         Caption         =   "Allocation Limit Type :"
         Height          =   255
         Left            =   240
         TabIndex        =   12
         Top             =   1920
         Width           =   1695
      End
      Begin VB.Label Label5 
         Caption         =   "Blend Ratio :"
         Height          =   255
         Left            =   240
         TabIndex        =   10
         Top             =   2400
         Width           =   1455
      End
      Begin VB.Label Label4 
         Caption         =   "Allocation Limit :"
         Height          =   255
         Left            =   240
         TabIndex        =   8
         Top             =   1440
         Width           =   1455
      End
      Begin VB.Label Label3 
         Caption         =   "Code :"
         Height          =   255
         Left            =   240
         TabIndex        =   6
         Top             =   960
         Width           =   1455
      End
      Begin VB.Label Label2 
         Caption         =   "Name :"
         Height          =   255
         Left            =   240
         TabIndex        =   4
         Top             =   480
         Width           =   1455
      End
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "Close"
      Height          =   375
      Left            =   9480
      TabIndex        =   0
      Top             =   120
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Select Grade :"
      Height          =   255
      Left            =   480
      TabIndex        =   3
      Top             =   240
      Width           =   1695
   End
End
Attribute VB_Name = "DialogGrades"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'**************************************************
' Grades Dialog
' Copyright 2013 Integration Technologies Ltd
'
' Select Grade to show
' Set price of grade by Price levele
' Block/Unblock grade
' List Grade events
'**************************************************

Option Explicit

Private WithEvents CurGrade As Grade
Attribute CurGrade.VB_VarHelpID = -1



Private Sub Combo_Grades_Click()
    FindCurrentGrade
    ShowGradeDetail
End Sub


Private Sub Combo_Blend_Click()
    Dim PriceLevel As Integer
    Dim BlendIndex As Integer
    Dim BlendPrices As IGradePriceCollection
    
    Dim BlendPrice As IGradePrice
    

    PriceLevel = Combo_PriceLevel.ListIndex + 1
    BlendIndex = Combo_Blend.ListIndex
    
    CurGrade.GetBlendPrices PriceLevel, BlendPrices
    
    Set BlendPrice = BlendPrices.GetByIndex(BlendIndex)
    
    Text_Price = Format(BlendPrice.Price)
    
End Sub


Private Sub Combo_PriceLevel_Click()
    ShowPrices
End Sub

Private Sub Command_block_Click()
    ' Toggle block
    DoCommand "Block", CurGrade.SetBlock((CurGrade.BlockedReasons And GradeBlockedReasons_Manual) = 0)
End Sub

Private Sub Command_SetPrice_Click()
    Dim NewPrice As Currency
    Dim PriceLevel As Integer
    
    On Error GoTo Error
    
    NewPrice = CCur(Text_Price)
    PriceLevel = Combo_PriceLevel.ListIndex + 1
    If (CurGrade.GradeType = GradeType_VariableBlend) Then
    
    Else
        DoCommand "SetPrice", CurGrade.SetPrice(PriceLevel, NewPrice)
    End If
    
    Exit Sub
    
Error:
    MsgBox "Invalid Price", vbExclamation
    
End Sub

Private Sub DoCommand(Command As String, result As ApiResult)
    If (result <> ApiResult_Ok) Then
        MsgBox Command + ":" + FormMain.myforecourt.GetResultString(result)
    End If
    ShowGradeDetail
End Sub


Private Sub Command1_Click()

End Sub

Private Sub CurGrade_OnGradeStatus(ByVal Grade As ITL_Enabler_API.IGrade, ByVal eventType As ITL_Enabler_API.GradeStatusEventType)
    Select Case eventType
    Case GradeStatusEventType_Blocked
        List_events.AddItem "Event OnGradeStatus Block change:" + Format(CurGrade.BlockedReasons)
    End Select
    
    ShowGradeDetail
End Sub


Private Sub CurGrade_OnPriceChange(ByVal Grade As ITL_Enabler_API.IGrade, ByVal level As Long, ByVal index As Long, ByVal Price As Currency)
    ShowGradeDetail
End Sub

Private Sub Form_Load()
    Dim GradeX As Grade
    
    With FormMain.myforecourt
    
        For Each GradeX In .Grades
            Combo_Grades.AddItem Format(GradeX.Id) + " \ " + GradeX.name
        Next
        If (.Grades.Count > 0) Then Combo_Grades.ListIndex = 0
        
    End With
End Sub


Private Sub ShowGradeDetail()
    If (Not CurGrade Is Nothing) Then
        With CurGrade
            Text_name = .name
            Text_Code = .code
            Text_AllocationLimit = Format(.AllocationLimit)
            
            Select Case .AllocationLimitType
              Case LimitType_NoLimit
                Text_AllocationLimitType = "No Limit"
              Case LimitType_QuantityAllocationLimit
                Text_AllocationLimitType = "Quantity"
              Case LimitType_ValueAllocationLimit
                Text_AllocationLimitType = "Value"
            End Select
            
                
            Text_BlendRatio = Format(.BlendRatio)
            Text_DeliveryTimeout = Format(.DeliveryTimeout)
            
            If (.Grade1 Is Nothing) Then
                Text_Grade1 = "None"
            Else
                Text_Grade1 = .Grade1.name
            End If
            
            If (.Grade2 Is Nothing) Then
                Text_Grade2 = "None"
            Else
                Text_Grade2 = .Grade2.name
            End If
            
            Check_IsBlocked = IsValue(.IsBlocked)
            
            Text_PriceLevelCount = Format(.PriceLevelCount)
            
            Select Case .GradeType
                Case GradeType_Base
                    Text_GradeType = "Base"
                Case GradeType_FixedBlend
                    Text_GradeType = "Fixed Blend"
                Case GradeType_VariableBlend
                    Text_GradeType = "Variable Blend"
            End Select
                    
            Select Case .Unit
                Case UnitOfMeasure_CubicMetre
                    Text_Unit = "Cubic Metre"
                Case UnitOfMeasure_Gallons
                    Text_Unit = "Gallons"
                Case UnitOfMeasure_Kilograms
                    Text_Unit = "Kilograms"
                Case UnitOfMeasure_Litres
                    Text_Unit = "Litres"
            End Select
                    
            Text_PriceProfileId = Format(.PriceProfileId)
            
            Text_PriceSegment = Format(.PriceSignSegment)
            
            Combo_PriceLevel.Clear
            Dim level As Integer
            For level = 1 To .PriceLevelCount
                Combo_PriceLevel.AddItem "Level " + Format(level)
            Next level
            If (.PriceLevelCount > 0) Then Combo_PriceLevel.ListIndex = 0
        
            If (.GradeType = GradeType_VariableBlend) Then
                Combo_Blend.Enabled = True
            Else
                Combo_Blend.Enabled = False
            End If
        
            ShowPrices
        
        End With
    End If
End Sub

Private Sub ShowPrices()
    Dim PriceLevel As Integer
    Dim BlendPrices As IGradePriceCollection
    Dim Blend As IGradePrice
    Dim Price As Currency
   
    With CurGrade


    PriceLevel = Combo_PriceLevel.ListIndex + 1
    If (PriceLevel < 1) Then Exit Sub
    
   If (.GradeType = GradeType_VariableBlend) Then
        
        CurGrade.GetBlendPrices PriceLevel, BlendPrices
        
        Combo_Blend.Clear
        For Each Blend In BlendPrices
            Combo_Blend.AddItem Format(Blend.Ratio) + "%"
        Next
        
        If (BlendPrices.Count > 0) Then Combo_Blend.ListIndex = 0
        
   Else
        CurGrade.GetPrice PriceLevel, Price
        Text_Price = Format(Price)
   End If
    
    End With
    
End Sub

Private Function IsValue(value As Boolean) As String
    If (value = True) Then
        IsValue = "1"
    Else
        IsValue = "0"
    End If
End Function

Private Sub FindCurrentGrade()
    Set CurGrade = FormMain.myforecourt.Grades.GetByIndex(Combo_Grades.ListIndex)
End Sub



Private Sub OKButton_Click()
    Unload Me
End Sub
