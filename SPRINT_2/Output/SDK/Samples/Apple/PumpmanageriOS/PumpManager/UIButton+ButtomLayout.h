//
//  UIButton+ButtomLayout.h
//  IOSPumpDemo
//
//  Created by ITL on 5/06/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Overwrite the UIButton class in order to relocate image and text as we need
 */

@interface UIButton (ButtomLayout)

/**
 *  Locate the image on top and text at the bottom, and both in the center
 */
- (void)centerImageAndTitle;

@end
