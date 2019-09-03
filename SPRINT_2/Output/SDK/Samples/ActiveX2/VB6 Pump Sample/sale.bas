Attribute VB_Name = "sales"
'*****************************************************************
'*
'* Copyright (C) 1997-2003 Integration Technologies Limited
'* All rights reserved.
'*
'* This module includes some simple code to allow manipulation of
'* sale items of various types - this is used to allow the mainform
'* to keep a list of sale items (including deliveries)
'*
'******************************************************************/
Option Explicit

'******************************************************************/
'*
'* Sale store declarations
'*
'* TSale     represents one retail transaction
'* TSaleItem represents one item in a sale
'*
'******************************************************************/
Enum ItemType
    NoItem
    DeliveryItem ' post-pay
    prepayItem
    DryStockitem
End Enum

Type TSaleItem
    ItemType As Long
    PumpNumber As Integer
    AllowedHoses As Integer ' bitmap of allowed hoses
    Del As Delivery
    Description As String * 50
    Price As Currency
    Quantity As Double
    Value As Currency
    Reference As Long       ' prepay transaction reference
 End Type
 
 Enum SaleState
    SaleOpen
    cashfinalised
    CreditFinalised
 End Enum
 
 Type TSale
    Items(100) As TSaleItem
    NumberOfItems As Integer
    Subtotal As Currency
    State As Integer
 End Type
 
 Public Sale As TSale

'******************************************************************
'*
'* InitialiseGlobals - called by main form on form load event
'*
'******************************************************************
Public Sub InitialiseGlobals()
   
    With Sale
        .NumberOfItems = 0
        .Subtotal = 0
        .State = SaleOpen
    End With

End Sub

'******************************************************************
'*
'* FinaliseSale - called by main form to finalise sale
'*
'* Parameters
'* Description      - finalisation description
'* FinalisationType - price level associated with finalisation
'*
'******************************************************************
Public Sub FinaliseSale(Description As String, FinalisationType As Integer)
    Dim i As Integer
    Dim result As Integer
    Dim reservedType As Integer
    
    reservedType = 16
    
    With Sale
        If .NumberOfItems >= 1 Then
     
            .State = FinalisationType
            MainForm.SaleState.Caption = Description
        
            ' scan all the sale items to see if any are fuel related
            For i = 0 To .NumberOfItems - 1
                With .Items(i)
                
                    ' if this item has a delivery handle assigned
                    ' then clear the delivery
                    If Not .Del Is Nothing Then
                        Dim Number As Integer
                        Number = .Del.Hose.Pump.Number
                        TraceForm.TracePump Number, "Delivery " + Str(.Del.ID) + " Clear Request"
                        result = .Del.Clear(MainForm.Session.TerminalID)
                        TraceForm.TracePump Number, "Delivery " + Str(.Del.ID) + " Clear Response(" + Str(result) + ")"
                        ' check result, if not Okay then display error string
                        ' as retrieved from session object
                        If result <> OK_RESULT Then
                            ' if for some reason the clear did not work then we need to unlock it anyway
                            MsgBox MainForm.Session.ResultString(result), vbExclamation
                            .Del.ReleaseLock (MainForm.Session.TerminalID)
                        End If
                        
                        ' release the handle to the delivery,
                        ' it is essential that this is done ASAP
                        ' also to prevent clear sale from
                        ' attempting to unlock it
                        Set .Del = Nothing
                        
                    ElseIf .ItemType = prepayItem Then
                    
                        ' if this item is a prepay item then we can
                        ' now authorise the prepay delivery
                        result = MainForm.Pump(.PumpNumber).AuthorisePrepay(.Value, IIf(FinalisationType = cashfinalised, 1, 2), .AllowedHoses, reservedType, .Reference)
                        
                        ' check result, if not Okay then display error string
                        ' as retrieved from session object
                        If result <> OK_RESULT Then
                            MsgBox MainForm.Session.ResultString(result), vbExclamation
                            MainForm.Pump(.PumpNumber).CancelPrepay
                            ' cancel finalisation in this case - we cannot authorise the pump for prepay
                        End If
                        
                        ' flag item as not a prepay to prevent
                        ' clear sale from cancelling it
                        .ItemType = NoItem
                    End If
                End With
            Next i
        
        End If
        .NumberOfItems = 0
    End With
End Sub

'******************************************************************
'*
'* FindDelivery - search for a delivery in the sale
'*
'* used to identify whether the delivery is already in the sale
'*
'******************************************************************
Public Function FindDelivery(ByVal DeliveryID) As Boolean

Dim i As Integer

    FindDelivery = False
    
    With Sale
        For i = 0 To .NumberOfItems - 1
            If .Items(i).ItemType = DeliveryItem Then
                If .Items(i).Del.ID = DeliveryID Then
                    FindDelivery = True
                    Exit Function
                End If
            End If
        Next i
    End With

End Function

'******************************************************************
'*
'* AddSaleItem - called by main form to add an item to the sale
'*
'* Parameters
'* ItemType     - The type of the sale item, one of ItemType enum
'* Description  - Item description, displayed in sale grid
'* Price        - The unit price of the item
'* Quantity     - The quantity of the item
'* Value        - The total value of the item usually Price*Quantity
'*
'******************************************************************
Public Function AddSaleItem(ByVal ItemType As Integer, _
                          ByVal Description As String, _
                          ByVal Price As Currency, _
                          ByVal Quantity As Double, _
                          ByVal Value As Currency, _
                          Optional ByVal Reference As Long) As Boolean
                          
    With Sale
    
        ' if this is the first item in the sale then open the sale
        If .State <> SaleOpen Then
        
            .NumberOfItems = 0
            .State = SaleOpen
            .Subtotal = 0
            With MainForm
                .SaleGrid.Rows = 1
                .SaleState.Caption = "Subtotal"
            End With
            
        ' check to ensure that there is space for this item
        ' in the sale
        ElseIf .NumberOfItems > UBound(.Items) Then
        
            MsgBox "Too many items", vbExclamation
            AddSaleItem = False
            Exit Function
            
        End If
    
        ' add the item in at the end of the sale
        With .Items(.NumberOfItems)
        
            .ItemType = ItemType
            .Description = Description
            .Price = Price
            .Quantity = Quantity
            .Value = Value
            
            If IsMissing(Reference) Then
                .Reference = 0
            Else
                .Reference = Reference
            End If
            
            Set .Del = Nothing
            .PumpNumber = -1
            .AllowedHoses = 0
            
        End With
        
    End With
   
    ' display the item at the end of the sale grid
    With MainForm.SaleGrid
    
        .AddItem Description & Chr(9) & _
            Format(Price) & Chr(9) & _
            Format(Quantity, "fixed") & Chr(9) & _
            Format(Value, "currency")
            
        .Row = .Rows - 1
        .Col = 0
        .CellAlignment = flexAlignLeftCenter
        .Col = 1
        .CellAlignment = flexAlignRightCenter
        .Col = 2
        .CellAlignment = flexAlignRightCenter
        .Col = 3
        .CellAlignment = flexAlignRightCenter
        .FocusRect = flexFocusNone

        .RowSel = .Row
        .ColSel = 0
        
    End With
     
    ' update number of items and sale subtotal
    With Sale
        .NumberOfItems = .NumberOfItems + 1
        .Subtotal = .Subtotal + Value
        MainForm.Subtotal.Text = Format(.Subtotal, "currency")
    End With
    
    AddSaleItem = True
    
End Function

