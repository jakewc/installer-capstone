//
//  AppDelegate.m
//  Enabler Pump Manager
//
//  Created by ITL on 20/05/15.
//  Copyright © 2015 Integration Technologies Limited. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate {
    UIStoryboard *storyBoard;
    LoginViewController *loginView;
}

/**
 *  Preload necessary views here
 */
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    storyBoard =
    [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    _tabbarController =
    [storyBoard instantiateViewControllerWithIdentifier:@"MainBoard"];
    
    _tabbarController.selectedIndex = 0;
    
    loginView = [storyBoard instantiateViewControllerWithIdentifier:@"Login"];
    
    [self.window setRootViewController:loginView];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state.
    // This can occur for certain types of temporary interruptions (such as an
    // incoming phone call or SMS message) or when the user quits the application
    // and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down
    // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate
    // timers, and store enough application state information to restore your
    // application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called
    // instead of applicationWillTerminate: when the user quits.
    if ([_forecourt isConnected]) {
        [_forecourt disconnectWithMessage:@"Application Enter Background"];
        _forecourt = nil;
        [self.window.rootViewController dismissViewControllerAnimated:YES
                                                           completion:nil];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state;
    // here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the
    // application was inactive. If the application was previously in the
    // background, optionally refresh the user interface.
    if (_forecourt == nil) {
        [self showLoginPage];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if
    // appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Forecourt
/**
 *  Set forecourt object and delegation
 *
 *  @param forecourt forecourt object
 */
- (void)setForecourt:(ENBForecourt *)forecourt {
    _forecourt = forecourt;
    [_forecourt addDelegate:self];
}

#pragma mark Forecourt delegate
- (void)onServerEvent {
    if (_isConnected) {
        // unexpected lost connection
        _isConnected = NO;
        _forecourt = nil;
        
        UIAlertView *lostConnectionView =
        [[UIAlertView alloc] initWithTitle:@"Error"
                                   message:@"Lost Connection"
                                  delegate:self
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [lostConnectionView show];
        });
    }
}

#pragma mark - UIAlert
- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"OK"]) {
        [self.window.rootViewController dismissViewControllerAnimated:YES
                                                           completion:nil];
        
        [self showLoginPage];
    }
}

- (void)showLoginPage {
    loginView = [storyBoard instantiateViewControllerWithIdentifier:@"Login"];
    
    self.window.rootViewController = loginView;
    [self.window makeKeyAndVisible];
}

@end
