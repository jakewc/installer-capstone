//
//  Transaction.h
//  EnablerApi
//
//  Created by ITL on 15/05/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//

#import "ENBFuelTransactionStates.h"
@class ENBHose;

/*!
 *  Contains the Authorization details of a transaction.
 */
@interface ENBTransactionAuthoriseData : NSObject

/**
 *  The date and time when the fuel transaction was authorized
 */
@property (readonly)NSDate* authoriseDateTime;

/**
 *  Returns the money limit set when the fuel transaction was authorized, or 0 if there was no money limit
 */
@property (readonly)NSDecimalNumber* moneyLimit;

/**
 *  The price level set when the fuel transaction was authorized
 */
@property (readonly)NSInteger priceLevel;

/**
 *  Returns the quantity limit set when the fuel transaction was authorized, or 0 if there was no quality limit
 */
@property (readonly)NSDecimalNumber* quantityLimit;

/**
 *  Indicates the reason of a fuel transaction was authorized
 */
@property (readonly)ENBAuthoriseReason reason;

/**
 *  Returns the terminal ID that authorized the transaction
 */
@property (readonly)NSInteger terminalID;

@end

/*!
 *  Used to store the running and current delivery information.
 */
@interface ENBDeliveryData : NSObject


/**
 *  Gets the grade object associated with the transaction
 */
@property (readonly)ENBGrade* grade;

/**
 *  Get the total money of the transaction
 */
@property (readonly)NSDecimalNumber* money;

/**
 *  The electronic money total from the pump when the transaction was completed
 */
@property (readonly)NSDecimalNumber* moneyTotal;

/**
 *  Get the total quality of the transaction
 */
@property (readonly)NSDecimalNumber* quantity;

/**
 *  The electronic quality total from the pump when the transaction was completed
 */
@property (readonly)NSDecimalNumber* quantityTotal;

/**
 *  The price per unitOfMeasure for the transaction
 */
@property (readonly)NSDecimalNumber* unitPrice;


@end


/*!
 *  Encapsulates information about a delivery made with a blended grade
 */
@interface ENBBlendData : NSObject

/**
 *  Returns the delivery data for the first base grade in the blend
 */
@property (readonly)ENBDeliveryData* base1;

/**
 *  Returns the delivery data for the second base grade in the blend
 */
@property (readonly)ENBDeliveryData* base2;

/**
 *  The ratio of Base1 in blend mix
 */
@property (readonly)NSDecimalNumber* ratio;

@end

/*!
 *  Class to encapsulate the transaction history properties
 */
@interface ENBTransactionHistory : NSObject

/**
 *  Returns the age of a completed transaction since it was completed to the time it is cleared
 */
@property (readonly)NSInteger age;

/**
 *  Returns the date and time the transaction was authorized
 */
@property (readonly)NSDate* authoriseDateTime;

/**
 *  Returns a terminal id that cleared the transaction
 */
@property (readonly)NSInteger clearedByID;

/**
 *  Returns the date and time the transaction was cleared
 */
@property (readonly)NSDate* clearedDateTime;

/**
 *  Returns the date and time the transaction was completed
 */
@property (readonly)NSDate* completedDateTime;

/**
 *  Returns the reason for completing the transaction
 */
@property (readonly)ENBCompleteReason completionReason;

/**
 *  Returns a terminal id that reserved the transaction
 */
@property (readonly)NSInteger reservedByID;

/**
 *  Returns the date and time the transaction was reserved
 */
@property (readonly)NSDate* reservedDateTime;


@end

/*!
 *  A class to encapsulate the concept of a fuel transaction.
 */
@interface ENBTransaction : NSObject

/**
 *  Returns an attendant id associated with the transaction
 */
@property (readonly)NSInteger attendantID;

/**
 *  Returns a reference to the authorization data associated with the transaction
 */
@property (readonly)ENBTransactionAuthoriseData* authoriseData;

/**
 *  Returns a reference to the BlendData object associated with this transaction for blended deliveries
 */
@property (readonly)ENBBlendData* blend;

/**
 *  Returns a client activity code supplied when this transaction was authorized
 */
@property (readonly)NSString* clientActivity;

/**
 *  Returns a client Reference string supplied when this transaction was authorized
 */
@property (readonly)NSString* clientReference;

/**
 *  Returns a reference to the DeliveryData object associated with this transaction
 */
@property (readonly)ENBDeliveryData* deliveryData;

/**
 *  Returns the delivery type of the transaction
 */
@property (readonly)ENBDeliveryType deliveryType;

/**
 *  Returns error flags of transaction errors type for any error conditions during this transaction
 */
@property (readonly)ENBTransactionErrors errors;

/**
 *  Returns a reference to a TransactionHistory object associated with this transaction
 */
@property (readonly)ENBTransactionHistory* historyData;

/**
 *  Returns a reference to the Hose object associated with the transaction
 */
@property (readonly)ENBHose* hose;

/**
 *  Returns the unique transaction ID
 */
@property (readonly)NSInteger ID;

/**
 *  Returns true if the transaction is locked
 */
@property (readonly) BOOL isLocked;

/**
 *  Returns the terminal id that has locked this transaction
 */
@property (readonly)NSInteger lockedByID;

/**
 *  Returns a reference to the Pump object associated with the transaction
 */
@property (readonly)ENBPump* pump;

/**
 *  Returns the current transaction state of this fuel transaction
 */
@property (readonly)ENBTransactionState state;


// *** Methods ***

/*!
 *  Clear the transaction.
 *
 *  @param clearType Type of transaction to be cleared off (Normal, Test, Drive Off or Attendant )
 *
 *  @return api result code
 */
- (int)clear:(ENBTransactionClearType)clearType;

/*!
 *  Get a lock on the transaction
 *
 *  @return api result code
 */
- (int)getLock;

/*!
 *  Release lock on transaction.
 *
 *  @return api result code
 */
- (int)releaseLock;

/*!
 *  Reinstate current transaction to original pump transaction stack.
 *
 *  @return api result code
 */
- (int)reinstate;

/*!
 *  Reinstate current transaction to original pump transaction stack and get a lock on the transaction for the current terminal ID.
 *
 *  @return api result code
 */
- (int)reinstateAndLock;


@end


/*!
 *  A collection of transaction objects used for the Pump transaction stack.
 */
@interface ENBTransactionCollection : NSObject <NSFastEnumeration>

/*!
 *  Number of transaction in Stack
 */
@property (readonly) NSInteger count;

/*!
 *  Get a transaction by its transaction ID.
 *  If ID not found will return nil.
 *
 *  @param ID ID of transaction to get from transaction stack.
 */
- (ENBTransaction*) getByID:(int)ID;

/*!
 *  Get a transaction by its index in stack.
 *  If index out of bounds then will return nil.
 *
 *  @param index  Index into transaction stack.
 */
- (ENBTransaction*) getByIndex:(int)index;


@end

