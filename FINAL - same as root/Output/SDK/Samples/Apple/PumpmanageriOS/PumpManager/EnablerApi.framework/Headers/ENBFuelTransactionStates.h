//
//  FuelTransactionStates.h
//  EnablerApi
//
//  Created by ITL on 14/05/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//

#ifndef EnablerApi_FuelTransactionStates_h
#define EnablerApi_FuelTransactionStates_h

/*!
 *  Enumeration for the state of a transaction.
 */
typedef NS_ENUM( NSUInteger, ENBTransactionState){
 
    /// The transaction has been created by a pump that has been reserved for authorization in the future
    ENBTransactionStateReserved = 2,
    
    /// The transaction was authorized,
    /// but then cancelled before any fuel was delivered
    ENBTransactionStateCancelled,

    /// Transaction has been authorized
    ENBTransactionStateAuthorised,

    /// Transaction is in a fuelling state
    ENBTransactionStateFuelling,

    /// Fuelling has completed and the transaction is ready to be cleared/sold
    ENBTransactionStateCompleted,

    /// Transaction has been cleared
    ENBTransactionStateCleared
};

/*!
 *  Enumeration for possible transaction errors. One or more can be present.
 */
typedef NS_ENUM( NSUInteger, ENBTransactionErrors){
    /// Nozzle was left out,
    /// possibly indicating a driver off
    ENBTransactionErrorsNozzleLeftOut = 1,
    
    /// The delivery took longer than the maximum delivery timeout on the grade
    ENBTransactionErrorsDeliveryGradeTimeout = 2,
    
    /// The age of transaction is older than the configured maximum age
    ENBTransactionErrorsTransactionAgeTimeout = 4,
    
    ///A delivery with a limit on value or quality overrun the preset limit
    ENBTransactionErrorsDeliveryOverRun = 8,
};

/*!
 *  Enumeration for possible delivery types.
 */
typedef NS_ENUM( NSUInteger, ENBDeliveryType)
{
    /// Transaction type is currently unknown
    ENBDeliveryTypeUnknown,
    /// An unsold transaction, the "current transaction"
    ENBDeliveryTypeCurrent,
    /// An unsold transaction, pushed onto the transaction stack
    ENBDeliveryTypeStacked,
    /// Legacy unsold preauth transaction as the "current transaction"
    /// Depreciated for version 4, Available to create in Active X clients and special Reserve only
    ENBDeliveryTypeAvailablePreauth, //3
    /// Legacy unsold prepay transaction as the "current transaction"
    /// Depreciated for version 4, Available to create in Active X clients and special Reserve only
    ENBDeliveryTypeAvailablePrePayRefund,
    /// A transaction cleared by calling the "Transaction.Clear" method with a clear type if "Normal"
    ENBDeliveryTypeNormal,
    /// A transaction cleared automatically by the pump server
    ENBDeliveryTypeMonitor,
    /// A transaction cleared by calling the legacy "Delivery.ClearPreauth"
    /// Depreciated for version 4, Available to create in Active X clients and special Reserve only
    ENBDeliveryTypePreAuth,
    /// A transaction started by calling the legacy Pump.AuthorisePrepay
    ENBDeliveryTypePrepay, // 8
    /// A legacy prepay refund transaction that has been cleared (refunded to the customer)
    /// Depreciated for version 4, Available to create in Active X clients and special Reserve only
    ENBDeliveryTypePrePayRefund,
    /// A legacy prepay refund transaction that was cleared automatically by the pump server
    /// after the configured timeout period, This is called a "lost" refund because the customer did not receive the refund
    /// Depreciated for version 4, Available to create in Active X clients and special Reserve only
    ENBDeliveryTypePrePayRefundLost,
    /// A transaction cleared by calling transaction.Clear method with a clear type of "Test"
    ENBDeliveryTypeTest,
    /// A transaction cleared by calling transaction.Clear method with a clear type of "Driveoff"
    ENBDeliveryTypeDriveOff,
    /// A cleared transaction that was authorized for an attendant
    ENBDeliveryTypeAttendant,
    /// This type indicates an unexpected changes in electronic totals
    ENBDeliveryTypeOffline,
    /// A previously cleared transaction that has been reinstated for re-finalization by calling "Transaction.Reinstate" method after being looked up with the "Forecourt.GetTransactionById" or "Forecourt.GetTransactionByReference"
    ENBDeliveryTypeReinstated, // 15
};

/*!
 *  Enumeration for possible Transaction completion reasons. Why the Transaction was completed.
 */
typedef NS_ENUM( NSUInteger, ENBCompleteReason)
{
    /// Transaction is in progress and not yet complete
    ENBCompleteReasonNotComplete,
    /// Cancelled before nozzle lift, Authorize or Reserve was cancelled
    ENBCompleteReasonCancelled,
    /// Timeout before nozzle lift, The time limit for a Authorize or Reserve expired
    ENBCompleteReasonTimeout,
    /// Normal Delivery, This includes deliveries that stopped at or under the authorized limit
    ENBCompleteReasonNormal,
    /// Fuel transaction which was authorized but no fuel was delivered
    ENBCompleteReasonZero,
    /// Fuel Transaction was stopped by a client during delivery
    ENBCompleteReasonStoppedByClient,
    /// Transaction was stopped by the Enabler to enforce a limit
    ENBCompleteReasonStoppedByLimit,
    /// Fuel transaction was stopped due to an error
    ENBCompleteReasonStoppedByError,
    /// The transaction was created because offline deliveries where detected from the dispenser electronic total
    ENBCompleteReasonOffline,
};

/*!
 *  Enumeration for possible Transaction authorization reasons. How the Transaction was authorized.
 */

typedef NS_ENUM( NSUInteger, ENBAuthoriseReason )
{
    /// Transaction is not authorized
    ENBAuthoriseReasonNotAuthorised,
    /// Explicit authorization by client application
    ENBAuthoriseReasonClient,
    /// Attendant authorization by the Enabler
    ENBAuthoriseReasonAttendant,
    ///Monitor authorization by the Enabler
    ENBAuthoriseReasonMonitor,
    /// Automatic authorization by the Enabler - based on Site or Pump mode configuration
    ENBAuthoriseReasonAuto,
    /// Authorization by Enabler in fallback mode
    ENBAuthoriseReasonFallback,
    /// Transaction authorized by the pump itself
    ENBAuthoriseReasonPumpSelf,
};

/*!
 *  Enumeration for possible Transaction clear type.
 */
typedef NS_ENUM( NSUInteger, ENBTransactionClearType){
    /*!
     *  Normal transaction clear.
     */
    ENBTransactionClearTypeNormal,
    /*!
     *  The Transaction was cleared as a Test delivery.
     */
    ENBTransactionClearTypeTest,
    /*!
     *  Transaction was cleared as a Drive Off.
     */
    ENBTransactionClearTypeDriveOff,
    /*!
     *  Transaction was cleared as an Attendant transaction.
     */
    ENBTransactionClearTypeAttendant,
};

#endif
