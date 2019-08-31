//
//  UIButton+ButtomLayout.h
//  Enabler Pump Manager
//
//  Created by ITL on 5/06/15.
//  Copyright © 2015 Integration Technologies Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Overwrite the UIButton class in order to relocate image and text as we need
 */

@interface UIButton (ButtonLayout)

/**
 *  Locate the image on top and text at the bottom, and both in the center
 */
- (void)centerImageAndTitle;

@end
