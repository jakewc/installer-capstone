//
//  Common.h
//  Enabler Pump Manager
//
//  Created by ITL on 9/07/15.
//  Copyright © 2015 Integration Technologies Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
@import EnablerApi;

#define ANIMATION_CALLING @"calling"
#define ANIMATION_DELIVERING @"delivering"
#define ANIMATION_LOCKED @"locked"
#define ANIMATION_PRICECHANGE @"pricechange"
#define ANIMATION_FLASH @"flash"

/**
 *  This class contains some generic functions
 */
@interface Common : NSObject

+ (NSString*)getLocaleCurrencySymbol;

+ (NSString*)getGradeUnitFromCurrentPump: (ENBPump*)currentPump;

+ (NSString*)getGradeUnitFromTransaction:(ENBTransaction *)trans;

+ (void)updateUI:(dispatch_block_t) block;

+ (void)showDeliveringAnimationOnLayer:(CALayer*)layer;

+ (void)showLockAnimationOnLayer:(CALayer*)layer;

+ (void)showCallingAnimationOnLayer:(CALayer*)layer WithError:(BOOL) error;

+ (void)showPriceChangeAnimationOnLayer:(CALayer*)layer;

+ (void)showFlashAnimationOnLayer:(CALayer*)layer;

@end
