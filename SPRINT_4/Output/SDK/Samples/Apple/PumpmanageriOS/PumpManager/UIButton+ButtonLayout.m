//
//  UIButton+ButtomLayout.m
//  Enabler Pump Manager
//
//  Created by ITL on 5/06/15.
//  Copyright © 2015 Integration Technologies Limited. All rights reserved.
//

#import "UIButton+ButtonLayout.h"

@implementation UIButton (ButtonLayout)

/**
 *  Replace the image on top of the text
 */
- (void)centerImageAndTitle {
    CGFloat imageWidth = self.imageView.image.size.width;
    CGFloat imageHeigh = self.imageView.image.size.height;
    
    self.imageEdgeInsets =
    UIEdgeInsetsMake(-imageHeigh / 20, 0, imageHeigh / 20, 0);
    
    self.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageWidth), imageHeigh / 30, 0);
}
@end
