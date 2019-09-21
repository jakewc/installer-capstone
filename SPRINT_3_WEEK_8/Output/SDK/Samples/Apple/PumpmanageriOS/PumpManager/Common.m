//
//  Common.m
//  Enabler Pump Manager
//
//  Created by ITL on 9/07/15.
//  Copyright © 2015 Integration Technologies Limited. All rights reserved.
//

#import "Common.h"


@implementation Common

+ (NSString *)getLocaleCurrencySymbol{
        return [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
}

+ (NSString *)getGradeUnitFromCurrentPump:(ENBPump *)currentPump{
        ENBGrade* grade;
        NSString* gradeUnit;
        
        if ([currentPump currentHose]) {
            grade = currentPump.currentHose.grade;
        } else  if ([currentPump currentTransaction]){
            grade = currentPump.currentTransaction.deliveryData.grade;
        }
        
        if (grade) {
            switch (grade.unit) {
                case ENBUnitOfMeasureCubicMeter:
                    gradeUnit = @"CUBICMETER";
                    break;
                case ENBUnitOfMeasureGallons:
                    gradeUnit = @"GALLON";
                    break;
                case ENBUnitOfMeasureKilograms:
                    gradeUnit = @"KILOGRAM";
                    break;
                case ENBUnitOfMeasureLiters:
                    gradeUnit = @"LITRE";
                    break;
                default:
                    break;
            }
        }
        return [ENBForecourt getResourceString:gradeUnit];
}

+ (NSString*)getGradeUnitFromTransaction:(ENBTransaction *)trans
{
    ENBGrade* grade;
    NSString* gradeUnit;
    
    grade = trans.deliveryData.grade;
    
    if (grade) {
        switch (grade.unit) {
            case ENBUnitOfMeasureCubicMeter:
                gradeUnit = @"CUBICMETER";
                break;
            case ENBUnitOfMeasureGallons:
                gradeUnit = @"GALLON";
                break;
            case ENBUnitOfMeasureKilograms:
                gradeUnit = @"KILOGRAM";
                break;
            case ENBUnitOfMeasureLiters:
                gradeUnit = @"LITRE";
                break;
            default:
                break;
        }
    }
    return [ENBForecourt getResourceString:gradeUnit];
}

#pragma mark - Update UI
+ (void)updateUI:(dispatch_block_t) block
{
    dispatch_async(dispatch_get_main_queue(), block);
}

#pragma mark - Animation on layer
+ (void)showDeliveringAnimationOnLayer:(CALayer*)layer
{
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 0.5; // half second
    animation.repeatCount = 1; // repeat once
    animation.toValue=[NSNumber numberWithFloat:((90.0f* M_PI)/180.0f)];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [layer addAnimation:animation forKey:ANIMATION_DELIVERING];
}

+ (void)showLockAnimationOnLayer:(CALayer*)layer
{
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 0.5; // one second
    animation.repeatCount = 1; // repeat once
    animation.toValue=[NSNumber numberWithFloat:0.0f];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [layer addAnimation:animation forKey:ANIMATION_LOCKED];
}

+ (void)showCallingAnimationOnLayer:(CALayer*)layer WithError:(BOOL) error
{
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"transform.rotation.z";
    if (error) {
        animation.values = @[@0, @((15.0f* M_PI)/180.0f)];
        animation.keyTimes = @[@0, @1];
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
    } else {
        animation.values=@[@0, @((15.0f* M_PI)/180.0f), @0];
        animation.keyTimes = @[@0, @(1/2.0f), @1];
        animation.repeatCount = INFINITY;
    }
    animation.duration = 0.5;
    //animation.additive = YES;
    [layer addAnimation:animation forKey:ANIMATION_CALLING];
}

+ (void)showPriceChangeAnimationOnLayer:(CALayer*)layer
{
    CAKeyframeAnimation* priceChanging = [CAKeyframeAnimation animation];
    priceChanging.keyPath = @"opacity";
    priceChanging.values = @[@1,@0,@1];
    priceChanging.keyTimes = @[@0,@(1/2.0f),@1];
    priceChanging.duration = 1;
    priceChanging.repeatCount = INFINITY;
    
    [layer addAnimation:priceChanging forKey:ANIMATION_PRICECHANGE];
}

// flash a lay to indicate there is an issue
+ (void)showFlashAnimationOnLayer:(CALayer*)layer
{
    CAKeyframeAnimation* priceChange = [CAKeyframeAnimation animation];
    priceChange.keyPath = @"opacity";
    priceChange.values = @[@1,@0,@1];
    priceChange.keyTimes = @[@0,@(1/2.0f),@1];
    priceChange.duration = 1;
    priceChange.repeatCount = INFINITY;
    [layer addAnimation:priceChange forKey:ANIMATION_FLASH];
}
@end
