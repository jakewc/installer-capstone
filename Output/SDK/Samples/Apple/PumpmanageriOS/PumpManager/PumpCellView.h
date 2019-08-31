//
//  PumpCellView.h
//  Enabler Pump Manager
//
//  Created by ITL on 27/05/15.
//  Copyright © 2015 Integration Technologies Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PumpViewController.h"
@import EnablerApi;

/**
 *  Pump Cell View on forecourt page
 */
@interface PumpCellView : UITableViewCell<ENBPumpEventDelegates>

- (void)initPumpCell;
/**
 *  Set up a pump for the cell
 *
 *  @param pump Pump Object
 */
- (void)setupPump:(ENBPump*)pump;

@end
