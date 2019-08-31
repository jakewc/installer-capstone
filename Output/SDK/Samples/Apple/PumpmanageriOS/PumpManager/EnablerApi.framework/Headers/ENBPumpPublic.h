//
//  PumpPublic.h
//  EnablerApi
//
//  Created by ITL on 8/05/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//


#import "ENBPumpStates.h"
#import "ENBPumpAuthorise.h"
#import "ENBHosePublic.h"

@class ENBPump;
@class ENBTransaction;
@class ENBTransactionCollection;
@class ENBHoseCollection;


/*!
 *  Protocol used to fire events from a pump or pump collection.
 */
@protocol ENBPumpEventDelegates
@optional
/*!
 *  This event is fired when the PumpStatus changes.
 *
 *  @param pump      The pump firing the event.
 *  @param eventType The type of PumpStatus that triggered this event.
 */
-(void)OnStatusDidChangeEvent:(ENBPump*)pump
                    EventType:(ENBPumpStatusEventType)eventType;
/*!
 *  This event is fired every time the running totals have been updated in the current fuel transaction
 *
 *  @param pump      The pump firing the event.
 *  @param value     The current money value of fuel delivered for the current fuel transaction.
 *  @param quantity  The current quantity/volume of fuel delivered for the current fuel transaction.
 *                   For blended products this indicates the total gross volume delivered (primary + secondary product).
 *  @param quantity2 The current quantity/volume of the secondary grade delivered for the current fuel transaction for blended products. 
 *                   Always zero (0) for non-blended transactions.
 */
-(void)OnFuellingProgress:(ENBPump*)pump
                    Value:(NSDecimalNumber *)value
                 Quantity:(NSDecimalNumber *)quantity
                Quantity2:(NSDecimalNumber *)quantity2;
/*!
 *  This event is fired when a hose event occurs.
 *
 *  @param pump      The pump firing the event.
 *  @param eventType The type of hose event that caused the event.
 */
-(void)OnHoseEvent: (ENBPump *)pump
               EventType:(ENBHoseEventType)eventType;
/*!
 *  This event is fired when a TransactionEvent occurs.
 *
 *  @param pump      The pump firing the event.
 *  @param eventType The type of TransactionEvent that triggered this event.
 *  @param transactionId     The associated transaction Id.
 *  @param trans     The associated transaction.
 */
-(void)OnTransactionEvent:(ENBPump *)pump
                 EventType:(ENBTransactionEventType)eventType
            TransactionID:(NSInteger)transactionId
               Transaction:(ENBTransaction*)trans;

/*!
 *  This event is fired when the PriceChange status has changed for this pump
 *
 *  @param pump   The pump firing the event
 *  @param status Pump price change status
 */
- (void)OnPriceChangeEvent: (ENBPump *)pump
                    Status:(ENBPumpEventPriceChangeStatus)status;

@end

/*!
 *  Pump object
 */
@interface ENBPump : NSObject

/*!
 *  Pumps description
 */
@property (readonly) NSString *    description;

/*!
 *  Unique ID of the pump
 */
@property (readonly) int           ID;

/*!
 *  Number of Pump.
 */
@property (readonly) int number;

/*!
 *  State of the fuel flow for the current delivery. If true the fuel is flowing.
 */
@property (readonly) BOOL          fuelFlow;

/*!
 *  Returns true if pump is blocked
 */
@property (readonly) BOOL          isBlocked;

/*!
 *  Returns the current state of the pumps lights
 */
@property (readonly) BOOL            pumpLights;

/*!
 *  Returns a bitmap of the reasons the Pump is blocked.
 */
@property (readonly) ENBPumpBlockedReason blockedReason;

/*!
 *  Returns the current state of the pump
 */
@property (readonly) int           state;

/*!
 *  Gets a reference to the hose object currently lifted from the pump if it is calling or delivering.
 */
@property (readonly) ENBHose*     currentHose;

/*!
 *  Collection of Hoses on pump
 */
@property (readonly) ENBHoseCollection* hoses;

/*!
 *  Returns true if there is a Current Transaction.
 */
@property (readonly) BOOL isCurrentTransaction;

/*!
 *  Returns the current transaction on the pump.  A transaction begins as soon as the pump is reserved or authorized. Once it is completed, the transaction remains on the pump until it is cleared or stacked.
 */
@property (readonly) ENBTransaction* currentTransaction;

/*!
 *  The transaction stack stores a list of Transaction objects for the pump that have been completed and stacked by calling Pump.StackCurrentTransaction but have not yet been cleared (sold).
 *  Returns the Transaction stack collection.
 */
@property (readonly) ENBTransactionCollection* transactionStack;

/*!
 *  Returns the current price change status
 */
@property (readonly) ENBPumpEventPriceChangeStatus priceChangeStatus;

//******************
// Pump commands
//******************

/*!
 *  Authorize the pump with no limits.
 *
 *  @param clientActivity  Client activity is an optional string to indicate activity or what ever the client application wants to store against transaction.
 *  @param clientReference Client reference string(optional). This must match any previous Reserve. The Client reference will be recorded against the transaction. The Transaction can then be looked up using the Client reference.
 *  @param attendantID     Id of attendant for an Attendant authorize or -1 when no attendant.
 *
 *  @return Api result code
 */
-(int)authoriseNoLimitsWithClientActivtity:(NSString *)clientActivity ClientReference:(NSString *)clientReference AttendantID:(int)attendantID;

/*!
 *  Authorize the pump with limits.
 *
 *  @param clientActivity  Client activity is an optional string to indicate activity or what ever the client application wants to store against transaction.
 *  @param clientReference Client reference string(optional). This must match any previous Reserve. The Client reference will be recorded against the transaction. The Transaction can then be looked up using the Client reference.
 *  @param attendantID     Id of attendant for an Attendant authorize or -1 when no attendant.
 *  @param limits           ENBPumpAuthoriseLimits class containing the limits to be applied to Authorize
 *
 *  @return Api result code
 */
-(int)authoriseWithClientActivtity:(NSString *)clientActivity
                    ClientReference:(NSString *)clientReference
                       attendantID:(int)attendantID
               PumpAuthoriseLimits:(ENBPumpAuthoriseLimits *) limits;

/*!
 *  Cancel the Authorization from a pump.
 *
 *  @return Api result code
 */
-(int)cancelAuthorise;

/*!
 *  Cancel a previous reserve against pump
 *
 *  @return Api result code
 */
-(int)cancelReserve;

/*!
 *  Permanently stop an in progress delivery.
 *
 *  @return Api result code
 */
-(int)stop;

/*!
 *  Pause an in progress delivery on the pump.
 *
 *  @return Api result code
 */
-(int)pause;

/*!
 *  Resume an in progress delivery on the pump.
 *
 *  @return Api result code
 */
-(int)resume;

/*!
 *  Move the current Transaction out of the CurrentTransaction to allow a new Transaction to begin and into the Pump.TransactionStack.
 *
 *  @return Api result code
 */
-(int)stackCurrentTransaction;

/*!
 *  Blocks all operations on this pump and prevents it from starting a new transaction.
 *
 *  @param blockState Set to true to block pump, false to unblock.
 *  @param message    An optional message to assign a reason for blocking this pump. This message will be logged in the system journal if present.
 *
 *  @return Api result code
 */
-(int)setBlock:(bool)blockState
 ReasonMessage:(NSString*)message;


/**
 *  Returns the culture specific string resource from framework for the pump state
 *
 *  @param pumpState Pump state to get
 *
 *  @return String containing the requested pump state string
 */
+ (NSString*)getPumpStateString:(ENBPumpState) pumpState;


// Add - Remove client delegates

/*!
 *  Adds a delegate to list of delegates called on pump events.
 *
 *  @param delegate The delegate to add
 */
-(void) addDelegate:(id<ENBPumpEventDelegates>)delegate;

/*!
 *  Removes the passed delegate from the list of delegates called on pump events.
 *
 *  @param delegate The delegate to remove.
 */
-(void) removeDelegate:(id<ENBPumpEventDelegates>)delegate;

@end



/*!
 *  Pump collection object
 */
@interface ENBPumpCollection : NSObject <ENBPumpEventDelegates, NSFastEnumeration>

/*!
 *  Number of pumps in the pump collection.
 */
@property (readonly) int count;

/*!
 *  Get a pump by its id.
 *
 *  @param ID Id of pump to get.
 *
 *  @return Returns the pump or nil if not found.
 */
- (ENBPump *)getById:(int) ID;

/*!
 *  Get a pump by its number.
 *
 *  @param number Number of pump to get.
 *
 *  @return Returns the pump or nil if not found.
 */
- (ENBPump *)getByNumber:(int) number;

/*!
 *  Get a pump by its index in the pump collection.
 *
 *  @param index    index of pump
 *
 *  @return Returns the pump or nil if not found.
 */
- (ENBPump *)getByIndex:(int) index;

/*!
 *  Adds a delegate to list of delegates called on any pump events. Adding a delegate to the Pump collection will monitor events for all pump.
 *  Each pump event will return a reference to the pump firing the event.
 *
 *  @param delegate The delegate to add
 */
-(void) addDelegate:(id<ENBPumpEventDelegates>)delegate;

/*!
 *  Removes the passed delegate from the list of delegates called on any pump events.
 *
 *  @param delegate The delegate to remove
 */
-(void) removeDelegate:(id<ENBPumpEventDelegates>)delegate;

@end

