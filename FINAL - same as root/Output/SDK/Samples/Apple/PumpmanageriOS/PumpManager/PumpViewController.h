//
//  PumpViewController.h
//  Enabler Pump Manager
//
//  Created by ITL on 27/05/15.
//  Copyright © 2015 Integration Technologies Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrollView.h"
@import EnablerApi;

/**
 *  Controller for Pump Detail page
 */
@interface PumpViewController
: UIViewController<ENBPumpEventDelegates, UITableViewDataSource,
UITableViewDelegate, ScrollViewDataSource,
ScrollViewDelegate, ENBForecourtDelegate>

/**
 *  Represent the current pump object
 */
@property ENBPump* currentPump;

/**
 *  Represent the current index of the forecourt pump collection
 */
@property NSInteger currentIndex;

@end
