//
//  PumpWidgetView.m
//  Enabler Pump Manager
//
//  Created by Raymond Li on 30/03/15.
//  Copyright © 2015 Integration Technologies Limited. All rights reserved.
//

#import "PumpWidgetView.h"
#import "ImageNames.h"
#import "Common.h"
//@import EnablerApi;
#import <EnablerApi/EnablerApi.h>
/**
 *  This class represents a pump object
 */
@implementation PumpWidgetView {
    // Image Set
    UIImage* _pumpImage;
    UIImage* _authoriseImage;
    UIImage* _stopImage;
    UIImage* _priceChangeImage;
    UIImage* _pumpBusyImage;
    UIImage* _invalidPriceImage;
    UIImage* _pumpErrorImage;
    UIImage* _disconnectImage;
    UIImage* _stackTransImage;
    UIImage* _blockImage;
    
    // Image View set
    UIImageView* _pumpImageView;
    UIImageView* _authImageView;
    UIImageView* _priceChangeImageView;
    UIImageView* _pumpErrorImageView;
    UIImageView* _stackedTransImageView;
    UIImageView* _blockImageView;
    
    UILabel* _valueLabel;   // Value: 11
    UILabel* _volumeLabel;  // Volume: 12.6
    UILabel* _transLable;
    UILabel* _pumpInfo;  // display Pump ID and current grade if has
    
    ENBPump* _currentPump;
    
    // Split a cell unit into several small units, in order to locate emelemts as
    // we need
    float widthUnit;  // 1/5 of the viewWidth
    float heighUnit;  // 1/6 of the viewHeigh
    
    NSString* currencySymbol;
    NSString* gradeUnit;
    
    BOOL reloadRequired;
}

#pragma mark - Init functions
- (instancetype)init {
    self = [super init];
    if (self) {
        reloadRequired = YES;
        [self initialization];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        reloadRequired = YES;
        [self initialization];
    }
    return self;
}

- (void)reloadLayout {
    reloadRequired = YES;
}

/**
 *  Initialize all images, imageviews and labels here
 */
- (void)initialization {
    if (reloadRequired) {
        heighUnit = self.frame.size.height / 6;
        widthUnit = self.frame.size.width / 5;
        
        currencySymbol = [Common getLocaleCurrencySymbol];
        
        [self initAllImages];
        [self initAllImageViews];
        [self initAllLabels];
        
        CALayer* roundCorner = [self layer];
        
        [roundCorner setMasksToBounds:YES];
        
        [roundCorner setBorderColor:[UIColor colorWithRed:39 / 255.0
                                                    green:170 / 255.0
                                                     blue:225 / 255.0
                                                    alpha:1].CGColor];
        [roundCorner setBorderWidth:1];
        
        reloadRequired = NO;
    }
}

#pragma mark Init images, views and labels functions
- (void)initAllImages {
    _pumpImage = [UIImage imageNamed:PUMPWIDGET_PUMPIMAGE];
    _authoriseImage = [UIImage imageNamed:PUMPWIDGET_AUTHORISED];
    _stopImage = [UIImage imageNamed:PUMPWIDGET_STOPPED];
    _disconnectImage = [UIImage imageNamed:PUMPWIDGET_DISCONNECT];
    _stackTransImage = [UIImage imageNamed:PUMPWIDGET_STACK];
    _blockImage = [UIImage imageNamed:PUMPWIDGET_BLOCKED];
    _pumpBusyImage = [UIImage imageNamed:PUMPWIDGET_PUMPBUSY];
    _invalidPriceImage = [UIImage imageNamed:PUMPWIDGET_INVALIDPRICE];
    _pumpErrorImage = [UIImage imageNamed:PUMPWIDGET_ERROR];
    _priceChangeImage = [UIImage imageNamed:PUMPWIDGET_PRICECHANGE];
}

/**
 *  Init all image views with frame
 */
- (void)initAllImageViews {
    CGFloat maxUnit = MAX(widthUnit, heighUnit);
    _pumpImageView = [[UIImageView alloc]
                      initWithFrame:CGRectMake(widthUnit, heighUnit, maxUnit * 3, maxUnit * 3)];
    [_pumpImageView setImage:nil];
    [_pumpImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:_pumpImageView];
    
    _authImageView = [[UIImageView alloc]
                      initWithFrame:CGRectMake(widthUnit / 3, heighUnit * 4, widthUnit * 1.5,
                                               heighUnit * 1.5)];
    [_authImageView setImage:nil];
    [_authImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:_authImageView];
    
    _priceChangeImageView = [[UIImageView alloc]
                             initWithFrame:CGRectMake(widthUnit * 1, heighUnit * 1, widthUnit * 1,
                                                      heighUnit * 1)];
    [_priceChangeImageView setImage:nil];
    [_priceChangeImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:_priceChangeImageView];
    
    _stackedTransImageView = [[UIImageView alloc]
                              initWithFrame:CGRectMake(widthUnit * 4, heighUnit, widthUnit, heighUnit)];
    [_stackedTransImageView setImage:nil];
    [_stackedTransImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:_stackedTransImageView];
    
    _blockImageView = [[UIImageView alloc]
                       initWithFrame:CGRectMake(0, heighUnit, widthUnit, heighUnit)];
    [_blockImageView setImage:nil];
    [_blockImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:_blockImageView];
}

- (void)initAllLabels {
    _valueLabel = [[UILabel alloc]
                   initWithFrame:CGRectMake(widthUnit, heighUnit * 4.5, widthUnit * 3,
                                            heighUnit * 0.6)];
    [_valueLabel setFont:[UIFont systemFontOfSize:15]];
    _valueLabel.textAlignment = NSTextAlignmentCenter;
    _valueLabel.textColor = [UIColor colorWithRed:0 / 255.0
                                            green:84 / 255.0
                                             blue:112 / 255.0
                                            alpha:1];
    _valueLabel.hidden = YES;
    
    _volumeLabel = [[UILabel alloc]
                    initWithFrame:CGRectMake(widthUnit, heighUnit * 5.2, widthUnit * 3,
                                             heighUnit * 0.6)];
    [_volumeLabel setFont:[UIFont systemFontOfSize:15]];
    _volumeLabel.textColor = [UIColor colorWithRed:0 / 255.0
                                             green:84 / 255.0
                                              blue:112 / 255.0
                                             alpha:1];
    _volumeLabel.textAlignment = NSTextAlignmentCenter;
    _volumeLabel.hidden = YES;
    
    _transLable = [[UILabel alloc]
                   initWithFrame:CGRectMake(0, heighUnit * 4, widthUnit * 5, heighUnit * 2)];
    [_transLable setFont:[UIFont systemFontOfSize:15]];
    _transLable.textColor = [UIColor blackColor];
    _transLable.textAlignment = NSTextAlignmentCenter;
    _transLable.hidden = YES;
    
    _pumpInfo = [[UILabel alloc]
                 initWithFrame:CGRectMake(0, 0, widthUnit * 5, heighUnit)];
    [_pumpInfo setFont:[UIFont systemFontOfSize:12]];
    _pumpInfo.textColor = [UIColor blackColor];
    _pumpInfo.textAlignment = NSTextAlignmentCenter;
    _pumpInfo.hidden = NO;
    
    [self addSubview:_valueLabel];
    [self addSubview:_volumeLabel];
    [self addSubview:_pumpInfo];
    [self addSubview:_transLable];
}

#pragma mark - Setup Pump
/**
 *  Set up associated pump and add delegation
 */
- (void)setPump:(ENBPump*)pump {
    _currentPump = pump;
    [_currentPump addDelegate:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _pumpInfo.text =
        [NSString stringWithFormat:@"Pump %li", (long)_currentPump.number];
    });
    
    [self updatePumpImage];
    [self updateStatusImages];
    [self updateTransactions];
}

#pragma mark - Update Functions
// Update pump image: Pump, Error, Busy, Disconenct, Stop
- (void)updatePumpImage {
    dispatch_block_t block = ^{
        
        [_pumpImageView setImage:_pumpImage];
        _pumpInfo.text =
        [NSString stringWithFormat:@"Pump %li", (long)_currentPump.number];
        
        switch ((ENBPumpState)[_currentPump state]) {
            case ENBPumpStateBusy:
                [_pumpImageView setImage:_pumpBusyImage];
                break;
            case ENBPumpStateError:
                [_pumpImageView setImage:_pumpErrorImage];
                break;
            case ENBPumpStateNotInstalled:
            case ENBPumpStateNotResponding:
                [_pumpImageView setImage:_disconnectImage];
                break;
            case ENBPumpStateAuthorising:
                //  _authImageView.hidden = NO;
                break;
            case ENBPumpStateCalling: {
                _pumpInfo.text = [NSString
                                  stringWithFormat:@"Pump %li: %@", (long)_currentPump.number,
                                  _currentPump.currentHose.grade.name];
                [Common showCallingAnimationOnLayer:_pumpImageView.layer WithError:NO];
            } break;
            case ENBPumpStateDelivering: {
                _pumpInfo.text = [NSString
                                  stringWithFormat:@"Pump %li: %@", (long)_currentPump.number,
                                  _currentPump.currentHose.grade.name];
                [Common showDeliveringAnimationOnLayer:_pumpImageView.layer];
            } break;
            case ENBPumpStateDeliveryStopped:
                [_pumpImageView setImage:_stopImage];
                break;
            case ENBPumpStateDeliveryPaused:
                break;
            case ENBPumpStateLocked:
                [_pumpImageView.layer removeAllAnimations];
                [_blockImageView.layer removeAnimationForKey:ANIMATION_FLASH];
                break;
            case ENBPumpStateDeliveryFinished:
                [Common showLockAnimationOnLayer:_pumpImageView.layer];
                break;
            case ENBPumpStateNotAllowed: {
                // show a sloping pump with a flash block sign
                [Common showCallingAnimationOnLayer:_pumpImageView.layer WithError:YES];
                [Common showFlashAnimationOnLayer:_blockImageView.layer];
                break;
            }
            default:
                break;
        }
    };
    
    [Common updateUI:block];
}

// Update images for: price changing, invalid price, block, auth
- (void)updateStatusImages {
    dispatch_block_t block = ^{
        
        // block
        if (_currentPump.isBlocked) {
            [_blockImageView setImage:_blockImage];
        } else {
            [_blockImageView setImage:nil];
            
            for (ENBHose* hose in _currentPump.hoses) {
                if (hose.isBlocked) {
                    [_blockImageView setImage:_blockImage];
                    break;
                }
            }
        }
        
        // auth
        if ([_currentPump isCurrentTransaction]) {
            if (_currentPump.currentTransaction.state ==
                ENBTransactionStateAuthorised) {
                [_authImageView setImage:_authoriseImage];
            }
        } else {
            [_authImageView setImage:nil];
        }
    };
    [Common updateUI:block];
    
    // price changing
    [self updatePriceSign:_currentPump.priceChangeStatus];
}

- (void)updateTransactions {
    NSString* imageName;
    dispatch_block_t block;
    
    // check stacked transactions
    if (_currentPump.transactionStack.count > 0) {
        if (_currentPump.transactionStack.count <= 5) {
            imageName =
            [NSString stringWithFormat:@"%@%ld", PUMPWIDGET_STACK,
             (long)_currentPump.transactionStack.count];
        } else {
            imageName = [NSString stringWithFormat:@"%@5", PUMPWIDGET_STACK];
        }
    }
    
    block = ^{
        [_stackedTransImageView setImage:[UIImage imageNamed:imageName]];
        if ([_currentPump isCurrentTransaction]) {
            [self updateTrans:_currentPump.currentTransaction];
        }
    };
    
    [Common updateUI:block];
}

- (void)updatePriceSign:(ENBPumpEventPriceChangeStatus)status {
    dispatch_block_t block = ^{
        [_priceChangeImageView setImage:nil];
        switch (status) {
            case ENBPumpPriceChangeStatusIdle:
                [_priceChangeImageView.layer
                 removeAnimationForKey:ANIMATION_PRICECHANGE];
                break;
            case ENBPumpPriceChangeStatusInvalidPrice:
                [_priceChangeImageView setImage:_invalidPriceImage];
                break;
            case ENBPumpPriceChangeStatusPending:
                [_priceChangeImageView setImage:_priceChangeImage];
                break;
            case ENBPumpPriceChangeStatusRunning:
                [_priceChangeImageView setImage:_priceChangeImage];
                [Common showPriceChangeAnimationOnLayer:_priceChangeImageView.layer];
                break;
            default:
                break;
        }
    };
    [Common updateUI:block];
}

#pragma mark - Pump Delegates
- (void)OnFuellingProgress:(ENBPump*)pump
                     Value:(NSDecimalNumber*)value
                  Quantity:(NSDecimalNumber*)quantity
                 Quantity2:(NSDecimalNumber*)quantity2 {
    [self updateRunningTotal:value QuantityOne:quantity QuantityTwo:quantity2];
}

- (void)OnStatusDidChangeEvent:(ENBPump*)pump
                     EventType:(ENBPumpStatusEventType)eventType {
    if (pump) {
        if (_currentPump.ID != pump.ID) {
            return;
        }
    }
    _currentPump = pump;
    
    switch (eventType) {
        case ENBPumpStatusEventTypeBlocked:
            [self updateStatusImages];
            break;
        case ENBPumpStatusEventTypeState:
            [self updatePumpImage];
            [self updateStatusImages];
            break;
        default:
            break;
    }
}

- (void)OnTransactionEvent:(ENBPump*)pump
                 EventType:(ENBTransactionEventType)eventType
             TransactionID:(NSInteger)transactionId
               Transaction:(ENBTransaction*)trans {
    if (pump) {
        if (_currentPump.ID == pump.ID) {
            _currentPump = pump;
            switch (eventType) {
                case ENBTransactionEventTypeAuthorised:
                case ENBTransactionEventTypeFuelling:
                case ENBTransactionEventTypeCompleted:
                case ENBTransactionEventTypeCleared:
                    [self updateTrans:trans];
                    break;
                default:
                    break;
            }
            [self updateTransactions];
        }
    }
}

- (void)OnPriceChangeEvent:(ENBPump*)pump
                    Status:(ENBPumpEventPriceChangeStatus)status {
    _currentPump = pump;
    [self updatePriceSign:status];
}

- (void)OnHoseEvent:(ENBPump*)pump EventType:(ENBHoseEventType)eventType {
    _currentPump = pump;
    
    switch (eventType) {
        case ENBHoseEventTypeBlock:
            [self updateStatusImages];
            break;
        case ENBHoseEventTypeDeliveryGradeTimeout:
        case ENBHoseEventTypeHoseChange:
        case ENBHoseEventTypeLeftOut:
        case ENBHoseEventTypeLifted:
        case ENBHoseEventTypeReplaced:
            break;
        default:
            break;
    }
}

#pragma mark Support functions
- (void)updateRunningTotal:(NSDecimalNumber*)money
               QuantityOne:(NSDecimalNumber*)quantity1
               QuantityTwo:(NSDecimalNumber*)quantity2 {
    dispatch_async(dispatch_get_main_queue(), ^{
        _valueLabel.hidden = NO;
        _volumeLabel.hidden = NO;
        gradeUnit = [Common getGradeUnitFromCurrentPump:_currentPump];
        [_valueLabel setText:[NSString stringWithFormat:@"%@ %.2f", currencySymbol,
                              [money floatValue]]];
        [_volumeLabel setText:[NSString stringWithFormat:@"%@ %.2f", gradeUnit,
                               [quantity1 floatValue]]];
    });
}

- (void)updateTrans:(ENBTransaction*)trans {
    dispatch_block_t block = ^{
        _transLable.hidden = YES;
        _authImageView.hidden = YES;
        switch (trans.state) {
            case ENBTransactionStateAuthorised:
                [_authImageView setImage:_authoriseImage];
                _authImageView.hidden = NO;
                _valueLabel.text = nil;
                _volumeLabel.text = nil;
                break;
                
            case ENBTransactionStateFuelling: {
                [self updateRunningTotal:trans.deliveryData.money
                             QuantityOne:trans.deliveryData.quantity
                             QuantityTwo:nil];
            } break;
                
            case ENBTransactionStateCompleted: {
                _transLable.hidden = NO;
                gradeUnit = [Common getGradeUnitFromCurrentPump:_currentPump];
                _valueLabel.hidden = YES;
                _volumeLabel.hidden = YES;
                _transLable.text = [NSString
                                    stringWithFormat:@"%@ %.2f %@ %.2f", currencySymbol,
                                    [trans.deliveryData.money floatValue], gradeUnit,
                                    [trans.deliveryData.quantity floatValue]];
            } break;
                
            case ENBTransactionStateCleared: {
                if ([_currentPump isCurrentTransaction]) {
                    if ([_currentPump currentTransaction].ID == trans.ID) {
                        _transLable.text = nil;
                    } else if (_currentPump.currentTransaction.state ==
                               ENBTransactionStateCompleted) {
                        _transLable.hidden = NO;
                    }
                }
            } break;
                
            case ENBTransactionStateCancelled:
                break;
                
            case ENBTransactionStateReserved:
                break;
                
            default:
                break;
        }
    };
    [Common updateUI:block];
}

@end
