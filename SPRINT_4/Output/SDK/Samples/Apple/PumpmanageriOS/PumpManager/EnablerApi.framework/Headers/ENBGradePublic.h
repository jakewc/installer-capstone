//
//  GradePublic.h
//  EnablerApi
//
//  Created by ITL on 8/05/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//
@import Foundation;

#import "ENBGradeStates.h"

/*!
 *  Grade event protocol
 */
@protocol ENBGradeEventDelegates

/*!
 *  Events raised when a status of grade changes.
 *
 *  @param eventType The type of Grade status event for this event.
 */
-(void)OnStatusDidChangeEvent: (ENBGradeStatusEventType) eventType;

@end


/*!
 *  Encapsulates the details of a grade forecourt item (Wet Stock product)
 */
@interface ENBGrade : NSObject

/*!
 *  Unique ID of grade.
 */
@property (readonly) int            ID;

/*!
 *  Grade number
 */
@property (readonly) int            number;

/*!
 *  Reference to forecourt the grade belongs to.
 */
@property (readonly) ENBForecourt *    forecourt;

/*!
 *  The name of this grade.
 */
@property (readonly) NSString *     name;

/*!
 *  Returns the grade code setup in the Enabler Configuration.
 */
@property (readonly) NSString *     code;

/*!
 *  Indicates whether this grade is currently blocked.
 */
@property (readonly) BOOL           isBlocked;

/*!
 *  Returns a bitmap of the reasons the Grade is blocked.
 */
@property (readonly) ENBGradeBlockedReason blockedReason;

/*!
 *  The unit of measure used for this grade
 */
@property (readonly) ENBUnitOfMeasure unit;
/*!
 *  Adds a delegate to list of delegates called on grade events.
 *
 *  @param delegate The delegate to add
 */
-(void) addDelegate:(id<ENBGradeEventDelegates>)delegate;

/*!
 *  Removes the passed delegate from the list of delegates called on grade events.
 *
 *  @param delegate The delegate to remove.
 */
-(void) removeDelegate:(id<ENBGradeEventDelegates>)delegate;

@end


/*!
 *  A collection of Grade objects
 */
@interface ENBGradeCollection : NSObject <ENBGradeEventDelegates, NSFastEnumeration >

/*!
 *  Number of grades in the grade collection.
 */
@property (readonly) int count;

/*!
 *  Get a grade by its Id
 *
 *  @param id The grade id to find.
 *
 *  @return A grade object or nil if not found.
 */
- (ENBGrade *)getById:(int) id;

/*!
 *  Get a grade by its number.
 *
 *  @param number The grade number to find.
 *
 *  @return A grade object or nil if not found.
 */
- (ENBGrade *)getByNumber:(int) number;

/*!
 *  Get the grade by its index in the grade collection
 *
 *  @param index  Index into grade collection.
 *
 *  @return A grade object or nil if not found.
 */
- (ENBGrade *)getByIndex:(int) index;

/*!
 *  Adds a delegate to list of delegates called on any grade events. Adding a delegate to the Grade collection will monitor events for all grades.
 *  Each grade event will return a reference to the grade firing the event.
 *
 *  @param delegate The delegate to add
 */
-(void) addDelegate:(id<ENBGradeEventDelegates>)delegate;

/*!
 *  Removes the passed delegate from the list of delegates called on any grade events.
 *
 *  @param delegate The delegate to remove
 */
-(void) removeDelegate:(id<ENBGradeEventDelegates>)delegate;

@end
