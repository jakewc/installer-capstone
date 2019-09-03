//
//  HoseStates.h
//  EnablerApi
//
//  Created by ITL on 29/05/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//

/*!
 *  Reasons why a Hose has been blocked.
 */
typedef NS_ENUM( NSUInteger, ENBHoseBlockedReason)
{
    /*!
     *  The Hose is not blocked.
     */
    ENBHoseBlockedReasonNotBlocked = 0,
    /*!
     *  The grade associated with was manually blocked by user.
     */
    ENBHoseBlockedReasonGradeManual = 1,
    /*!
     *  The Hose is blocked because the associated tank is blocked.
     */
    ENBHoseBlockedReasonTankManual = 2,
    /*!
     *  The Hose is blocked due to a Tanker delivery in progress.
     */
    ENBHoseBlockedReasonTankerDelivery = 4,
    /*!
     *  The Hose is blocked because associated Tank has a Low Level alarm.
     */
    ENBHoseBlockedReasonTankLowLevel = 8,
    /*!
     *  The Hose was manually blocked by user.
     */
    ENBHoseBlockedReasonHoseManual = 16,
    /*!
     *  The Hose is blocked because its Pump is manually blocked.
     */
    ENBHoseBlockedReasonPumpManual = 32,
    /*!
     *  The Pump has been Stopped
     */
    ENBHoseBlockedReasonPumpStop = 64,
};
