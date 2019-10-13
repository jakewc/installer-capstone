//
//  PumpEvents.m
//  EnablerApi
//
//  Created by ITL on 30/04/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//

/*!
 *  Hose event type
 */
typedef NS_ENUM( NSUInteger, ENBHoseEventType)
{
    /// 
    /// Hose has been lifted.
    /// See CurrentHose for details.
    /// 
    ENBHoseEventTypeLifted = 0,
    
    /// 
    /// Hose has been replaced.
    /// 
    ENBHoseEventTypeReplaced,
    
    /// 
    /// Hose has been left out on start or end of delivery with no fuel flowing.
    /// See CurrentHose for details.
    /// 
    ENBHoseEventTypeLeftOut,
    
    /// 
    /// The block status has changed on the Hose. See the Hose BlockedReasons for details.
    /// 
    ENBHoseEventTypeBlock,
    
    /// 
    /// The delivery has timed out. Delivery is taking longer then timeout set up in Grade configuration.
    /// 
    ENBHoseEventTypeDeliveryGradeTimeout,
    
    /// 
    /// Hose number changed at delivery start.
    /// 
    /// <remarks>
    /// Some pumps don't supply the hose they are working with until the delivery has
    /// started, this event is fired if the hose number is different from when the hosed was lifted.
    /// </remarks>
    ENBHoseEventTypeHoseChange
    
} ;

/*!
 *  An enumeration for pump transaction events.
 */
typedef NS_ENUM( NSUInteger, ENBTransactionEventType)
{
    /// 
    /// The current transaction has been reserved.
    /// 
    ENBTransactionEventTypeReserved,
    /// 
    /// The current transaction has been authorized.
    /// 
    ENBTransactionEventTypeAuthorised,
    /// 
    /// Fuelling has started for current transaction.
    /// 
    ENBTransactionEventTypeFuelling,
    /// 
    /// Fuelling has completed for current transaction.
    /// 
    ENBTransactionEventTypeCompleted,
    /// 
    /// A transaction ( current or in stack ) has been locked.
    /// 
    ENBTransactionEventTypeLocked,
    /// 
    /// A transaction ( current or in stack ) has been unlocked.
    /// 
    ENBTransactionEventTypeUnlocked,
    /// 
    /// The current transaction has been stacked.
    /// 
    ENBTransactionEventTypeStacked,
    /// 
    /// A transaction ( current or in stack ) has been cleared.
    /// 
    ENBTransactionEventTypeCleared,
    /// 
    /// The delivery not taken timer has run out before the current transaction
    /// has been cleared by the client application.
    /// 
    ENBTransactionEventTypeNotTaken,
    /// 
    /// A transaction has been reinstated to the stack.
    /// 
    ENBTransactionEventTypeReinstated,
    /// 
    /// The user define field "ClientActivity" has been changed by one of the clients.
    /// This includes changes by the current client.
    /// 
    ENBTransactionEventTypeClientActivityChanged
    
} ;

/*!
 *  Pump status event type enum.
 */
typedef NS_ENUM( NSUInteger, ENBPumpStatusEventType)
{
    /// 
    /// Pump state has changed.
    /// 
    ENBPumpStatusEventTypeState,
    /// 
    /// Pump blocked status changed.
    /// 
    ENBPumpStatusEventTypeBlocked,
    /// 
    /// Pump lights have changed status.
    /// 
    ENBPumpStatusEventTypePumpLights,
    /// 
    /// PriceLevel mapping 1 has changed status.
    /// 
    ENBPumpStatusEventTypePriceLevel1,
    /// 
    /// PriceLevel mapping 2 has changed status.
    /// 
    ENBPumpStatusEventTypePriceLevel2,
    /// 
    /// The pump mode / profile has changed.
    /// 
    ENBPumpStatusEventTypeCurrentMode,
    /// 
    /// The FuelFlow property has changed.
    /// 
    ENBPumpStatusEventTypeFuelFlow
    
} ;


/*!
 *  Pump states enumeration.
 */
typedef NS_ENUM( NSUInteger, ENBPumpState)
{
    /// 
    /// Pump has error.
    /// 
    ENBPumpStateError = 0,
    /// 
    /// Pump has lost communication with Enabler.
    /// 
    ENBPumpStateNotResponding,
    /// 
    /// Pump not installed, most likely pump is linked to a port with "Not Installed" as protocol.
    /// 
    ENBPumpStateNotInstalled,
    /// 
    /// Pump is temporarily unavailable, normally when pump is being prepared by Enabler (just after pump coming online).
    /// 
    ENBPumpStateBusy,
    /// 
    /// Pump idle with nozzle in.
    /// 
    ENBPumpStateLocked,
    /// 
    /// Authorization for lifted hose disallowed, hose does not have the authorized product.
    /// 
    ENBPumpStateNotAllowed,
    /// 
    /// Pump idle with nozzle out.
    /// 
    ENBPumpStateCalling,
    /// 
    /// Pump being authorized.
    /// 
    ENBPumpStateAuthorising,
    /// 
    /// Pump's authorization failed (currently not used and to be implemented).
    /// 
    ENBPumpStateAuthorisingFailed,
    /// 
    /// Pump delivering (authorized).
    /// 
    ENBPumpStateDelivering,
    /// 
    /// Pump's delivery completed (remains in delivery state until delivery acknowledged by Enabler).
    /// 
    ENBPumpStateDeliveryFinished,
    /// 
    /// Pump is paused while delivering.
    /// 
    ENBPumpStateDeliveryPaused,
    /// 
    /// Pump was stopped during delivery, stopped deliveries can not be resumed.
    /// 
    ENBPumpStateDeliveryStopped,
    /// 
    /// Pump is manual type or an automatic but not connected thus transactions being logged manually.
    /// 
    ENBPumpStateManual
};


/*!
 *  Pump block reasons enumeration.
 */
typedef NS_ENUM( NSUInteger, ENBPumpBlockedReason)
{
    /// 
    /// Pump is in not blocked state.
    /// 
    ENBPumpBlockedReasonNotBlocked = 0,
    /// 
    /// Pump is blocked manually by SetBlock.
    /// 
    ENBPumpBlockedReasonManual = 1,
    /// 
    /// Pump is blocked because its hoses are blocked, check all hoses for blocking.
    /// 
    ENBPumpBlockedReasonAllHosesBlocked = 2,
    /// 
    /// Pump is blocked by either Stop or AllStop, Stop can be cleared with SetBlock(false).
    /// 
    ENBPumpBlockedReasonStopped = 4
};

/*!
 *  An enumeration for price change status
 */
typedef NS_ENUM(NSUInteger, ENBPumpEventPriceChangeStatus){
    /*!
     *  No price pending or price change completed successfully
     */
    ENBPumpPriceChangeStatusIdle = 0,
    /*!
     *  A price change id pending and will be applied when possible
     */
    ENBPumpPriceChangeStatusPending,
    /*!
     *  A price change is currently running
     */
    ENBPumpPriceChangeStatusRunning,
    /*!
     *  Unable to change price due to price being invalid
     */
    ENBPumpPriceChangeStatusInvalidPrice,
    /*!
     *  Price change failed probably due to lost communication with pump // This will be automatically retried
     */
    ENBPumpPriceChangeStatusFailed
};




