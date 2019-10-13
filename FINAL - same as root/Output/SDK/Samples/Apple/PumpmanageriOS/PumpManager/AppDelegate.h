//
//  AppDelegate.h
//  Enabler Pump Manager
//
//  Created by ITL on 20/05/15.
//  Copyright © 2015 Integration Technologies Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
@class LoginViewController;
@import EnablerApi;

@interface AppDelegate
: UIResponder<UIApplicationDelegate, ENBForecourtDelegate, UIAlertViewDelegate>

@property(nonatomic, strong) MainViewController* tabbarController;
@property(strong, nonatomic) UIWindow* window;
/**
 *  Forecourt object
 */
@property(nonatomic) ENBForecourt* forecourt;
/**
 *  Indicate the Forecourt connection status
 */
@property BOOL isConnected;

@end
