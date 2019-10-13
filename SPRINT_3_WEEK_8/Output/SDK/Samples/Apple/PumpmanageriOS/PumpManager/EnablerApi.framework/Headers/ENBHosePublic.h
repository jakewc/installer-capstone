//
//  HosePublic.h
//  EnablerApi
//
//  Created by ITL on 19/05/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//

#import "ENBHoseStates.h"

@class ENBGrade;
@class ENBPump;

/*!
 *  Provides information about a Dispenser hose.
 */
@interface ENBHose : NSObject

/*!
 *  Unique ID of the Hose
 */
@property (readonly) int           ID;

/*!
 *  Number of Hose.
 */
@property (readonly) int number;

/*!
 *  Returns a reference to the Pump object associated with this hose
 */
@property (readonly) ENBPump* pump;

/*!
 *  Returns a reference to the Grade object assigned to this hose
 */
@property (readonly) ENBGrade* grade;

/*!
 *  Indicates whether this hose is currently blocked.
 */
@property (readonly) BOOL isBlocked;

/*!
 *  Returns a reference to the Tank object this hose is connected to.
 */
@property (readonly) NSInteger tank1ID; // we don't have tank object yet, use id instead

/*!
 *  Returns a reference to the 2ND Tank object this hose is connected to.
 */
@property (readonly) NSInteger tank2ID;

/*!
 *  Returns a bitmap of the reasons the Hose is blocked.
 */
@property (readonly) ENBHoseBlockedReason blockedReason;

/*!
 *  Returns the electronic money total associated with the hose.
 */
@property (readonly) NSDecimalNumber * moneyTotal;

/*!
 *  Returns the electronic quantity/volume total associated with this hose
 */
@property (readonly) NSDecimalNumber * quantityTotal;

/*!
 *  Returns the electronic quantity/volume total associated with the 2ND grade for pumps with blended grades.
 */
@property (readonly) NSDecimalNumber * quantityTotal2;


@end

/*!
 *  Hose collection object
 */
@interface ENBHoseCollection : NSObject <NSFastEnumeration>

/*!
 *  Number of Hoses in the hose collection.
 */
@property (readonly) int count;


/*!
 *  Get a Hose by its id.
 *
 *  @param ID Id of Hose to get.
 *
 *  @return Returns the Hose or nil if not found.
 */
- (ENBHose *) getByID:(int)ID;

/*!
 *  Get a Hose by its index in the pump collection.
 *
 *  @param index    index of Hose
 *
 *  @return Returns the Hose or nil if not found.
 */
- (ENBHose *) getByIndex:(int)index;

/*!
 *  Get a Hose by its number.
 *
 *  @param number Number of Hose to get.
 *
 *  @return Returns the Hose or nil if not found.
 */
- (ENBHose *) getByNumber:(int)number;

@end