//
//  GradeEvents.h
//  EnablerApi
//
//  Created by ITL on 8/05/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//

/*!
 *  Type of grade status
 */
typedef NS_ENUM( NSUInteger, ENBGradeStatusEventType ){
    /*!
     *  The blocking has changed.
     */
    ENBGradeStatusEventTypeBlocked
};


/*!
  Indicates quantity measured in XXX
 */
typedef NS_ENUM( NSUInteger, ENBUnitOfMeasure)
{
    /*!
     *  Indicates quantity measured in Liters (L or l)
     */
    ENBUnitOfMeasureLiters = 1,
    /*!
     *  Indicates quantity measured in Gallons (G)
     */
    ENBUnitOfMeasureGallons,
    /*!
     *  Indicates quantity measured in Kilograms (Kg)
     */
    ENBUnitOfMeasureKilograms,
    /*!
     *  Indicates quantity measured in Cubic Meters (m3)
     */
    ENBUnitOfMeasureCubicMeter,
};

/*!
 Indicates the block reason
 */
typedef NS_ENUM( NSUInteger, ENBGradeBlockedReason)
{
    /*!
     *  Grade is not blocked
     */
    ENBGradeBlockedReasonNotBlocked = 0,
    /*!
     *  The Grade was blocked manually by calling the SetBlock method on the Grade
     */
    ENBGradeBlockedReasonManual = 1
    
};