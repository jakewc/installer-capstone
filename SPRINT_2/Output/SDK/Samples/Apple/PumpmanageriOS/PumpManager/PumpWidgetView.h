//
//  PumpWidgetView.h
//  Enabler Pump Manager
//
//  Created by ITL on 30/03/15.
//  Copyright © 2015 Integration Technologies Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EnablerApi/ENBPumpPublic.h>

/**
 *  Contains all pump elements that use to display at pump detail page
 */
@interface PumpWidgetView : UIView<UIGestureRecognizerDelegate,
ENBPumpEventDelegates, UIActionSheetDelegate>

/**
 *  Set up a pump for the widget to represent
 *
 *  @param pump <#pump description#>
 */
- (void)setPump:(ENBPump*)pump;

/**
 *  Initialising all components of a widget
 */
- (void)initialization;

/**
 *  Reload the widget
 */
- (void)reloadLayout;

@end
