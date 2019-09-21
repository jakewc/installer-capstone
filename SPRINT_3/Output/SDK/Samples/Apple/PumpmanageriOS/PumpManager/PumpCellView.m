//
//  PumpCellView.m
//  Enabler Pump Manager
//
//  Created by ITL on 27/05/15.
//  Copyright © 2015 Integration Technologies Limited. All rights reserved.
//

#import "PumpCellView.h"
#import "ImageNames.h"
#import "Common.h"

/**
 *  Overwrite a table cell, use to store image and some titles
 */
@implementation PumpCellView {
    // display pump number
    UILabel* _pumpNumber;
    
    // a view represents a pump
    UIView* _pumpView;
    
    // display pump with animation
    UIImageView* _pumpImage;
    
    // display status on top of the pump:
    // price changing, invalid price...
    UIImageView* _pumpStatusLeft;
    
    // display status on the right: block, stop, auth
    UIImageView* _pumpStatusRight;
    
    // labels to display running totals
    UILabel* _pumpRunningTotalValue;
    UILabel* _pumpRunningTotalQuantity;
    
    // represent a pump object
    ENBPump* _currentPump;
    
    // Split a cell unit into several small units, in order to locate emelemts as
    // we need
    float _widthUnit;
    float _heighUnit;
    
    UIColor* runningTotalTextColor;
    
    // currency symbol based on the locale
    NSString* currencySym;
    
    // grade unit symbol
    NSString* unitSym;
}

#pragma mark - Initialiser
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString*)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initPumpCell];
        // Get the currency symbol
        currencySym = [Common getLocaleCurrencySymbol];
    }
    return self;
}

/**
 *  Initialize a pump for a table cell
 */
- (void)initPumpCell {
    _pumpView = [[UIView alloc] init];
    [self addSubview:_pumpView];
    
    _pumpImage = [[UIImageView alloc]
                  initWithImage:[UIImage imageNamed:PUMPCELL_PUMPIMAGE]];
    [_pumpImage setContentMode:UIViewContentModeScaleAspectFit];
    
    _pumpStatusLeft = [[UIImageView alloc] initWithImage:nil];
    [_pumpStatusLeft setContentMode:UIViewContentModeScaleAspectFit];
    
    [_pumpView addSubview:_pumpImage];
    [_pumpView addSubview:_pumpStatusLeft];
    
    _pumpStatusRight = [[UIImageView alloc] initWithImage:nil];
    [_pumpStatusLeft setContentMode:UIViewContentModeScaleAspectFit];
    
    [self addSubview:_pumpStatusRight];
    
    _pumpRunningTotalQuantity = [[UILabel alloc] init];
    _pumpRunningTotalValue = [[UILabel alloc] init];
    
    _pumpRunningTotalQuantity.hidden = YES;
    _pumpRunningTotalValue.hidden = YES;
    
    [self addSubview:_pumpRunningTotalQuantity];
    [self addSubview:_pumpRunningTotalValue];
    
    runningTotalTextColor =
    [UIColor colorWithRed:0 green:125 / 255.0 blue:177 / 255.0 alpha:1];
}

#pragma mark - Setup Pump and init all components
- (void)setupPump:(ENBPump*)pump {
    _currentPump = pump;
    [_currentPump addDelegate:self];
    
    _pumpNumber = [[UILabel alloc] init];
    [_pumpNumber setText:[NSString stringWithFormat:@"%d", _currentPump.number]];
    
    [self addSubview:_pumpNumber];
    
    _widthUnit = self.frame.size.width / 6;
    _heighUnit = self.frame.size.height / 6;
    
    [_pumpNumber setFrame:CGRectMake(0, _heighUnit, _widthUnit, _heighUnit * 4)];
    [_pumpNumber setFont:[UIFont systemFontOfSize:28]];
    [_pumpNumber setTextAlignment:NSTextAlignmentCenter];
    
    [self updateImages];
}

/**
 *  Update Pump Widget based on the auto layout view size
 */
- (void)layoutSubviews {
    float _minUnit = MIN(_widthUnit, _heighUnit * 5);
    
    if (_widthUnit > (_heighUnit * 5))
        [_pumpView
         setFrame:CGRectMake((_widthUnit - _heighUnit * 5) / 2 + _widthUnit,
                             _heighUnit / 2, _minUnit, _minUnit)];
    else
        [_pumpView
         setFrame:CGRectMake(_widthUnit, (_heighUnit * 6 - _widthUnit) / 2,
                             _minUnit, _minUnit)];
    
    [_pumpImage setFrame:CGRectMake(0, 0, _pumpView.frame.size.width,
                                    _pumpView.frame.size.height)];
    [_pumpStatusLeft setFrame:CGRectMake(0, 0, _pumpView.frame.size.width,
                                         _pumpView.frame.size.height)];
    
    _pumpView.layer.borderWidth = 0;
    _pumpView.layer.borderColor = [UIColor colorWithRed:39 / 255.0
                                                  green:170 / 255.0
                                                   blue:255 / 255.0
                                                  alpha:1].CGColor;
    
    [_pumpRunningTotalValue
     setFrame:CGRectMake(_widthUnit * 2.1, _heighUnit * 0.8, _widthUnit * 2.9,
                         _heighUnit * 1.8)];
    [_pumpRunningTotalValue setTextAlignment:NSTextAlignmentLeft];
    
    [_pumpRunningTotalQuantity
     setFrame:CGRectMake(_widthUnit * 2.1, _heighUnit * 3.5, _widthUnit * 2.9,
                         _heighUnit * 1.8)];
    [_pumpRunningTotalQuantity setTextAlignment:NSTextAlignmentLeft];
    
    [_pumpStatusRight
     setFrame:CGRectMake(_widthUnit * 5, 0, _widthUnit, _heighUnit * 6)];
}

/**
 *  Check if a nozzle is blocked
 */
- (void)setNozzleBlock {
    for (ENBHose* hose in _currentPump.hoses) {
        if (hose.isBlocked) {
            [_pumpStatusRight setImage:[UIImage imageNamed:PUMPCELL_BLOCKED]];
            break;
        }
    }
}

#pragma mark - Pump Events
- (void)OnFuellingProgress:(ENBPump*)pump
                     Value:(NSDecimalNumber*)value
                  Quantity:(NSDecimalNumber*)quantity
                 Quantity2:(NSDecimalNumber*)quantity2 {
    _currentPump = pump;
    
    dispatch_block_t block = ^{
        _pumpRunningTotalQuantity.hidden = NO;
        _pumpRunningTotalValue.hidden = NO;
        [_pumpRunningTotalQuantity setTextColor:runningTotalTextColor];
        [_pumpRunningTotalValue setTextColor:runningTotalTextColor];
        
        unitSym = [Common getGradeUnitFromCurrentPump:_currentPump];
        
        _pumpRunningTotalValue.text =
        [NSString stringWithFormat:@"%@ %.2f", currencySym, [value floatValue]];
        _pumpRunningTotalQuantity.text =
        [NSString stringWithFormat:@"%@ %.2f", unitSym, [quantity floatValue]];
    };
    
    [Common updateUI:block];
}

- (void)OnTransactionEvent:(ENBPump*)pump
                 EventType:(ENBTransactionEventType)eventType
             TransactionID:(NSInteger)transactionId
               Transaction:(ENBTransaction*)trans {
    _currentPump = pump;
    
    dispatch_block_t block = ^{
        switch (eventType) {
            case ENBTransactionEventTypeAuthorised:
                [_pumpStatusRight setImage:[UIImage imageNamed:PUMPCELL_AUTHRISED]];
                break;
            case ENBTransactionEventTypeCleared:
                _pumpRunningTotalQuantity.hidden = YES;
                _pumpRunningTotalValue.hidden = YES;
                if ([[_currentPump transactionStack] count] == 0) {
                    [_pumpView setBackgroundColor:[UIColor clearColor]];
                }
                break;
            case ENBTransactionEventTypeClientActivityChanged:
                break;
            case ENBTransactionEventTypeCompleted: {
                {
                    [self transCompleted:trans];
                    break;
                }
            }
            case ENBTransactionEventTypeFuelling:
            case ENBTransactionEventTypeLocked:
            case ENBTransactionEventTypeUnlocked:
            case ENBTransactionEventTypeNotTaken:
            case ENBTransactionEventTypeReinstated:
            case ENBTransactionEventTypeReserved:
                break;
            case ENBTransactionEventTypeStacked: {
                if (_currentPump.transactionStack.count > 0) {
                    [_pumpView setBackgroundColor:[UIColor colorWithRed:212 / 255.0
                                                                  green:238 / 255.0
                                                                   blue:249 / 255.0
                                                                  alpha:1]];
                }
                break;
            }
            default:
                break;
        }
    };
    
    [Common updateUI:block];
    
    [self updateStatusImage];
}

- (void)OnStatusDidChangeEvent:(ENBPump*)pump
                     EventType:(ENBPumpStatusEventType)eventType {
    _currentPump = pump;
    
    switch (eventType) {
        case ENBPumpStatusEventTypeCurrentMode:
        case ENBPumpStatusEventTypeFuelFlow:
        case ENBPumpStatusEventTypePriceLevel1:
        case ENBPumpStatusEventTypePriceLevel2:
        case ENBPumpStatusEventTypePumpLights:
            break;
        case ENBPumpStatusEventTypeBlocked:
        case ENBPumpStatusEventTypeState: {
            [self updateImages];
            break;
        }
        default:
            break;
    }
}

- (void)OnPriceChangeEvent:(ENBPump*)pump
                    Status:(ENBPumpEventPriceChangeStatus)status {
    _currentPump = pump;
    
    [self updatePriceChange:status];
}

- (void)OnHoseEvent:(ENBPump*)pump EventType:(ENBHoseEventType)eventType {
    _currentPump = pump;
    
    switch (eventType) {
        case ENBHoseEventTypeBlock:
            [self updateStatusImage];
            break;
        case ENBHoseEventTypeLifted:
            break;
        case ENBHoseEventTypeReplaced:
            break;
        case ENBHoseEventTypeDeliveryGradeTimeout:
        case ENBHoseEventTypeHoseChange:
        case ENBHoseEventTypeLeftOut:
            break;
        default:
            break;
    }
}

#pragma mark - Update functions
/**
 *  update all images based on current status
 */
- (void)updateImages {
    [self updatePumpImage];
    [self updateTrans];
    [self updateStatusImage];
    [self updatePriceChange:_currentPump.priceChangeStatus];
}

- (void)updatePriceChange:(ENBPumpEventPriceChangeStatus)status {
    dispatch_block_t block = ^{
        // remove all animations
        if (status != ENBPumpPriceChangeStatusIdle) {
            [_pumpStatusLeft.layer removeAllAnimations];
            [_pumpImage setAlpha:0.5];
        }
        
        switch (status) {
            case ENBPumpPriceChangeStatusInvalidPrice:
                [_pumpStatusLeft.layer removeAnimationForKey:ANIMATION_FLASH];
                [_pumpStatusLeft setImage:[UIImage imageNamed:PUMPCELL_INVALIDPRICE]];
                break;
            case ENBPumpPriceChangeStatusPending:
                [_pumpStatusLeft setImage:[UIImage imageNamed:PUMPCELL_PRICECHANGE]];
                break;
            case ENBPumpPriceChangeStatusRunning:
                [_pumpStatusLeft setImage:[UIImage imageNamed:PUMPCELL_PRICECHANGE]];
                [Common showFlashAnimationOnLayer:_pumpStatusLeft.layer];
                break;
            case ENBPumpPriceChangeStatusIdle:
                [_pumpStatusLeft.layer removeAnimationForKey:ANIMATION_FLASH];
                [_pumpStatusLeft setImage:nil];
                [_pumpImage setAlpha:1];
                break;
            default:
                break;
        }
    };
    
    [Common updateUI:block];
}

/**
 *  block, auth, and stop
 */
- (void)updateStatusImage {
    dispatch_block_t block = ^{
        // reset image
        [_pumpStatusRight setImage:nil];
        
        // check auth
        if ([_currentPump isCurrentTransaction]) {
            if ([[_currentPump currentTransaction] state] ==
                ENBTransactionStateAuthorised) {
                [_pumpStatusRight setImage:[UIImage imageNamed:PUMPCELL_AUTHRISED]];
            }
        }
        
        // check block
        if (_currentPump.isBlocked) {
            [_pumpStatusRight setImage:[UIImage imageNamed:PUMPCELL_BLOCKED]];
        }
        
        // check nozzle block
        [self setNozzleBlock];
        
        // check stop
        if (_currentPump.state == ENBPumpStateDeliveryStopped) {
            [_pumpStatusRight setImage:[UIImage imageNamed:PUMPCELL_STOPPED]];
        }
        
    };
    
    [Common updateUI:block];
}

/**
 *  Update Pump Image
 */
- (void)updatePumpImage {
    dispatch_block_t block = ^{
        [_pumpImage.layer removeAllAnimations];
        [_pumpImage setImage:[UIImage imageNamed:PUMPCELL_PUMPIMAGE]];
        
        switch ((ENBPumpState)_currentPump.state) {
            case ENBPumpStateAuthorising:
            case ENBPumpStateAuthorisingFailed:
            case ENBPumpStateManual:
            case ENBPumpStateNotInstalled:
                break;
            case ENBPumpStateNotAllowed: {
                [Common showCallingAnimationOnLayer:_pumpImage.layer WithError:YES];
                [Common showFlashAnimationOnLayer:_pumpStatusRight.layer];
                break;
            }
            case ENBPumpStateError:
                [_pumpImage setImage:[UIImage imageNamed:PUMPCELL_ERROR]];
                break;
            case ENBPumpStateBusy:
                [_pumpImage setImage:[UIImage imageNamed:PUMPCELL_PUMPBUSY]];
                break;
            case ENBPumpStateNotResponding:
                [_pumpImage setImage:[UIImage imageNamed:PUMPWIDGET_DISCONNECT]];
                break;
            case ENBPumpStateDeliveryPaused:
            case ENBPumpStateDelivering:
                [Common showDeliveringAnimationOnLayer:_pumpImage.layer];
                break;
            case ENBPumpStateCalling:
                [Common showCallingAnimationOnLayer:_pumpImage.layer WithError:NO];
                break;
            case ENBPumpStateLocked:
            case ENBPumpStateDeliveryFinished:
                // remove the status animation if there was a blocked nozzle lifted.
                [_pumpStatusRight.layer removeAnimationForKey:ANIMATION_FLASH];
                [Common showLockAnimationOnLayer:_pumpImage.layer];
                break;
            default:
                break;
        }
    };
    [Common updateUI:block];
}

/**
 *  If there is a transaction, then we update the UI to display the transaction
 */
- (void)updateTrans {
    dispatch_block_t block = ^{
        if ([_currentPump isCurrentTransaction] == NO) {
            return;
        }
        
        switch ([_currentPump currentTransaction].state) {
            case ENBTransactionStateFuelling:
                _pumpRunningTotalValue.hidden = NO;
                _pumpRunningTotalQuantity.hidden = NO;
                [self updateRunningTotal:_currentPump.currentTransaction.deliveryData
                 .money
                             QuantityOne:_currentPump.currentTransaction.deliveryData
                 .quantity
                             QuantityTwo:nil];
                break;
            case ENBTransactionStateCompleted:
                _pumpRunningTotalValue.hidden = NO;
                _pumpRunningTotalQuantity.hidden = NO;
                [self transCompleted:[_currentPump currentTransaction]];
                break;
            default:
                _pumpRunningTotalQuantity.hidden = YES;
                _pumpRunningTotalValue.hidden = YES;
                break;
        }
        
        if ([[_currentPump transactionStack] count] > 0) {
            [_pumpView setBackgroundColor:[UIColor colorWithRed:212 / 255.0
                                                          green:238 / 255.0
                                                           blue:249 / 255.0
                                                          alpha:1]];
        } else {
            [_pumpView setBackgroundColor:[UIColor clearColor]];
        }
    };
    [Common updateUI:block];
}

#pragma mark Support functions
- (void)updateRunningTotal:(NSDecimalNumber*)value
               QuantityOne:(NSDecimalNumber*)quantity1
               QuantityTwo:(NSDecimalNumber*)quantity2 {
    dispatch_block_t block = ^{
        _pumpRunningTotalQuantity.hidden = NO;
        _pumpRunningTotalValue.hidden = NO;
        [_pumpRunningTotalQuantity setTextColor:runningTotalTextColor];
        [_pumpRunningTotalValue setTextColor:runningTotalTextColor];
        
        unitSym = [Common getGradeUnitFromCurrentPump:_currentPump];
        
        _pumpRunningTotalValue.text =
        [NSString stringWithFormat:@"%@ %.2f", currencySym, [value floatValue]];
        _pumpRunningTotalQuantity.text =
        [NSString stringWithFormat:@"%@ %.2f", unitSym, [quantity1 floatValue]];
    };
    
    [Common updateUI:block];
}

/**
 *  update running totals and background color if a transaction is completed.
 *
 */
- (void)transCompleted:(ENBTransaction*)trans {
    [_pumpView setBackgroundColor:[UIColor colorWithRed:212 / 255.0
                                                  green:238 / 255.0
                                                   blue:249 / 255.0
                                                  alpha:1]];
    
    [_pumpRunningTotalQuantity setTextColor:[UIColor blackColor]];
    [_pumpRunningTotalValue setTextColor:[UIColor blackColor]];
    
    unitSym = [Common getGradeUnitFromCurrentPump:_currentPump];
    
    [_pumpRunningTotalValue
     setText:[NSString
              stringWithFormat:@"%@ %.2f", currencySym,
              [trans.deliveryData.money floatValue]]];
    [_pumpRunningTotalQuantity
     setText:[NSString
              stringWithFormat:@"%@ %.2f", unitSym,
              [trans.deliveryData.quantity floatValue]]];
}
@end